use async_std::fs::{canonicalize, metadata};
use async_std::io::Result;
use async_std::path::Path;
use async_std::path::PathBuf;
use futures::executor::block_on;
use futures::future::join_all;
use futures::join;
use std::cmp::Eq;
use std::collections::{HashMap, HashSet};
use std::env;
use std::hash::Hash;
use std::io;
use std::io::LineWriter;
use std::time::UNIX_EPOCH;
use std::{
    fs::File,
    io::{prelude::*, BufReader},
};
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
#[structopt(name = "example", about = "An example of StructOpt usage.")]
struct Opt {
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
    let (input_entries_result, mru_entries_result) =
        join!(entries_from_stdin(), load_mru_file(&opt));

    let mru_entries = mru_entries_result?;
    let unique_input_entries = unique_by_key(input_entries_result?, |mru_entry| {
        mru_entry.filename.clone()
    });

    let input_entries = update_last_used_times(unique_input_entries, mru_entries);

    Ok(strip_cwd_from_filenames(input_entries)?)
}

fn update_last_used_times(
    input_entries: Vec<MruEntry>,
    mru_entries: Vec<MruEntry>,
) -> Vec<MruEntry> {
    let mru_map: HashMap<String, MruEntry> = mru_entries
        .into_iter()
        .map(|f| (f.filename.clone(), f))
        .collect();

    let mut updated_entries: Vec<MruEntry> = input_entries
        .into_iter()
        .map(|f| match mru_map.get(&f.filename) {
            Some(mru_entry) => mru_entry.clone(),
            None => f,
        })
        .collect();

    updated_entries.sort_by_key(|f| -(f.time_last_used as i64));

    return updated_entries;
}

async fn load_mru_file(opt: &Opt) -> Result<Vec<MruEntry>> {
    let mru_entries: Vec<MruEntry> = read_mru_file(&opt)?;

    Ok(filter_extant_entries(mru_entries).await)
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
    return joined.into_iter().filter_map(|e| e).collect();
}

#[derive(Debug, Eq, PartialEq, Clone)]
struct MruEntry {
    filename: String,
    time_last_used: u64,
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
                    let time: u64 = time_str.parse().map_err(|_err| {
                        std::io::Error::new(
                            std::io::ErrorKind::Other,
                            format!("Could not parse time from line: {}", line),
                        )
                    })?;

                    MruEntry {
                        filename: String::from(filename),
                        time_last_used: time,
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
    Ok(
        for mru_entry in mru_entries.into_iter().take(opt.max_mru_size).rev() {
            let line = format!("{:} {:}\n", mru_entry.time_last_used, mru_entry.filename);
            line_writer.write_all(line.as_bytes())?
        },
    )
}

fn lines_from_stdin() -> Result<Vec<String>> {
    let stdin = io::stdin();
    let buf = stdin.lock();

    buf.lines().collect()
}

async fn load_mru_entry(filename: String) -> Result<MruEntry> {
    let absolute_filename = canonicalize(&filename).await?;
    let md = metadata(&absolute_filename).await?;

    Ok(MruEntry {
        filename: absolute_filename.to_string_lossy().to_string(),
        time_last_used: md.modified()?.duration_since(UNIX_EPOCH).unwrap().as_secs(),
    })
}

async fn entries_from_stdin() -> Result<Vec<MruEntry>> {
    let filenames = lines_from_stdin()?;

    let joined = join_all(filenames.into_iter().map(load_mru_entry)).await;

    joined.into_iter().collect()
}

fn strip_cwd_from_filenames<'a>(mru_entries: Vec<MruEntry>) -> Result<Vec<MruEntry>> {
    let current_dir = env::current_dir()?;
    let cwd = format!(
        "{:}/",
        current_dir.to_str().ok_or_else(|| std::io::Error::new(
            std::io::ErrorKind::Other,
            format!("Could not convert current_dir into string")
        ))?
    );
    let cwd_length = cwd.len();

    Ok(mru_entries
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
        .collect())
}

fn unique_by_key<I, O: Hash + Eq>(items: Vec<I>, key: fn(&I) -> O) -> Vec<I> {
    let mut already_added = HashSet::new();
    items
        .into_iter()
        .filter(|i| already_added.insert(key(i)))
        .collect()
}
