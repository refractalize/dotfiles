use async_std::fs::metadata;
use async_std::io::Result;
use async_std::path::Path;
use async_std::path::PathBuf;
use chrono::{DateTime, TimeZone, Utc};
use futures::executor::block_on;
use futures::future::join_all;
use futures::join;
use std::cmp::Eq;
use std::collections::HashSet;
use std::env;
use std::hash::Hash;
use std::io;
use std::io::LineWriter;
use std::{
    fs::File,
    io::{prelude::*, BufReader},
};
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
#[structopt(name = "example", about = "An example of StructOpt usage.")]
struct Opt {
    #[structopt(short, long)]
    cwd_only: bool,

    #[structopt(long)]
    always_include: Option<PathBuf>,

    #[structopt(long = "no-compress", parse(from_flag = std::ops::Not::not))]
    compress_mru_file: bool,

    #[structopt(long, default_value = "1000")]
    max_mru_size: usize,

    #[structopt(parse(from_os_str))]
    mru_filename: PathBuf,
}

fn main() {
    let opt = Opt::from_args();

    let mru_entries = match block_on(load_entries(&opt)) {
        Ok(entries) => entries,
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    };

    for entry in mru_entries {
        println!("{:}", entry.filename);
    }
}

async fn load_entries(opt: &Opt) -> Result<Vec<MruEntry>> {
    let (local_entries_result, mru_entries_result) = join!(entries_from_stdin(), load_mru_file(&opt));

    let mut mru_entries = mru_entries_result?;
    let mut local_entries = local_entries_result?;

    mru_entries.append(&mut local_entries);

    Ok(unique_by_key(mru_entries, |mru_entry| mru_entry.filename.clone()))
}

async fn load_mru_file(opt: &Opt) -> Result<Vec<MruEntry>> {
    let mru_entries: Vec<MruEntry> = read_mru_file(&opt)?;

    Ok(
        filter_extant_entries(optionally_filter_out_non_local_filenames(
            &opt,
            strip_cwd_from_filenames(mru_entries)?,
        )?)
        .await
    )
}

async fn mru_entry_exists(mru_entry: MruEntry) -> Option<MruEntry> {
    if Path::new(&mru_entry.filename).exists().await {
        Some(mru_entry)
    } else {
        None
    }
}

async fn filter_extant_entries(mru_entries: Vec<MruEntry>) -> Vec<MruEntry> {
    let joined = join_all(mru_entries.into_iter().map(mru_entry_exists)).await;
    return joined
        .into_iter()
        .filter_map(|e| e)
        .collect();
}

#[derive(Debug, Eq, PartialEq)]
struct MruEntry {
    filename: String,
    time_last_used: DateTime<Utc>,
}

fn read_mru_file(opt: &Opt) -> Result<Vec<MruEntry>> {
    let file = File::open(&opt.mru_filename)?;
    let buf = BufReader::new(file);
    let mru_entries_result: Result<Vec<MruEntry>> = buf
        .lines()
        .map(|l| {
            let line = l?;

            Ok(match line.split_once(" ") {
                Some((time_str, filename)) => {
                    let time: i64 = time_str.parse().map_err( |_err| std::io::Error::new(std::io::ErrorKind::Other, format!("Could not parse time from line: {}", line)) )?;

                    MruEntry {
                        filename: String::from(filename),
                        time_last_used: Utc.timestamp(time, 0),
                    }
                }
                None => {
                    panic!("Could not parse MRU file");
                }
            })
        })
        .collect();

    let mru_entries = mru_entries_result?;

    let file_len = mru_entries.len();

    let latest_first = mru_entries.into_iter().rev().collect();
    let unique_entries = unique_by_key(latest_first, |mru_entry| mru_entry.filename.clone());

    if opt.compress_mru_file && file_len > opt.max_mru_size * 2 {
        let _ = compress_mru_file(opt, &unique_entries, &opt.mru_filename)?;
    }

    return Ok(unique_entries);
}

fn compress_mru_file(opt: &Opt, mru_entries: &Vec<MruEntry>, mru_filename: &Path) -> Result<()> {
    let file = File::create(mru_filename)?;
    let mut line_writer = LineWriter::new(file);
    Ok(for mru_entry in mru_entries.into_iter().take(opt.max_mru_size).rev() {
        let line = format!(
            "{:} {:}\n",
            mru_entry.time_last_used.timestamp(),
            mru_entry.filename
        );
        line_writer.write_all(line.as_bytes())?
    })
}

fn lines_from_stdin() -> Result<Vec<String>> {
    let stdin = io::stdin();
    let buf = stdin.lock();

    buf.lines().collect()
}

async fn load_mru_entry(filename: String) -> Result<MruEntry> {
    let md = metadata(&filename).await?;

    Ok(MruEntry {
        filename,
        time_last_used: DateTime::from(md.modified()?),
    })
}

async fn entries_from_stdin() -> Result<Vec<MruEntry>> {
    let filenames = lines_from_stdin()?;

    let joined = join_all(filenames.into_iter().map(load_mru_entry)).await;

    joined
        .into_iter()
        .collect()
}

fn strip_cwd_from_filenames<'a>(mru_entries: Vec<MruEntry>) -> Result<Vec<MruEntry>> {
    let current_dir = env::current_dir()?;
    let cwd = format!("{:}/", current_dir.to_str().ok_or_else(|| std::io::Error::new(std::io::ErrorKind::Other, format!("Could not convert current_dir into string")))?);
    let cwd_length = cwd.len();

    Ok(
        mru_entries
            .into_iter()
            .map(|mru_entry| {
                if mru_entry.filename.starts_with(&cwd) {
                    MruEntry {
                        filename: mru_entry.filename[cwd_length..].to_string(),
                        ..mru_entry
                    }
                } else {
                    mru_entry
                }
            })
            .collect()
    )
}

fn optionally_filter_out_non_local_filenames<'a>(
    opt: &Opt,
    mru_entries: Vec<MruEntry>,
) -> Result<Vec<MruEntry>> {
    if opt.cwd_only {
        let buffers = if opt.always_include.is_some() {
            let buffer_strings: Vec<String> = lines_from_file(&opt.always_include.as_ref().unwrap())?;
            Some(buffer_strings)
        } else {
            None
        };

        return Ok(filter_in_directory(
            mru_entries,
            buffers
                .as_ref()
                .map(|b| b.iter().map(String::as_ref).collect()),
        ));
    }

    return Ok(mru_entries);
}

fn unique_by_key<I, O: Hash + Eq>(items: Vec<I>, key: fn(&I) -> O) -> Vec<I> {
    let mut already_added = HashSet::new();
    items
        .into_iter()
        .filter(|i| already_added.insert(key(i)))
        .collect()
}

fn filter_in_directory<'a>(mru_entries: Vec<MruEntry>, keep: Option<Vec<&str>>) -> Vec<MruEntry> {
    mru_entries
        .into_iter()
        .filter(|mru_entry| {
            !mru_entry.filename.starts_with("/")
                || (keep.is_some()
                    && keep
                        .as_ref()
                        .unwrap()
                        .iter()
                        .any(|to_keep| &mru_entry.filename == to_keep))
        })
        .collect()
}

fn lines_from_file(filename: &Path) -> Result<Vec<String>> {
    let file = File::open(filename)?;
    let buf = BufReader::new(file);
    buf.lines().collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unique_by_key() {
        let items = vec!["one", "two", "three", "two"];

        assert_eq!(unique_by_key(items, |i| *i), vec!["one", "two", "three"]);
    }

    #[test]
    fn test_filter_in_directory_filters_out_strings_not_starting_with_directory() {
        let time_last_used = Utc::now();

        let to_mru_entries = |filenames: Vec<&str>| -> Vec<MruEntry> {
            filenames
                .into_iter()
                .map(|filename| MruEntry {
                    filename: String::from(filename),
                    time_last_used,
                })
                .collect()
        };

        let vec = to_mru_entries(vec!["/cwd/one", "two", "one", "/outside/keep"]);

        assert_eq!(
            filter_in_directory(vec, Some(vec!["/outside/keep"])),
            to_mru_entries(vec!["two", "one", "/outside/keep"])
        );
    }
}
