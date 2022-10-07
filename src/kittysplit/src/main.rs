use structopt::StructOpt;
use std::path::PathBuf;
use std::io::{
    prelude::*,
    Result
};
use std::{
    self,
    fs::File,
    io::BufReader,
    io::BufWriter
};
use regex::Regex;

#[derive(Debug, StructOpt)]
#[structopt(name = "example", about = "An example of StructOpt usage.")]
struct Opt {
    #[structopt(parse(from_os_str))]
    filename: PathBuf,

    #[structopt(parse(from_os_str))]
    output_directory: PathBuf,
}

struct OutFiles {
    directory: PathBuf,
    last_file_index: usize,
    extension: String
}

impl OutFiles {
    fn new(directory: PathBuf, extension: String) -> OutFiles {
        OutFiles {
            directory,
            last_file_index: 0,
            extension
        }
    }

    fn next(&mut self) -> BufWriter<File> {
        self.last_file_index += 1;
        let path = self.directory
            .join(format!("{:03}", self.last_file_index))
            .with_extension(&self.extension);

        return BufWriter::new(File::create(path).unwrap())
    }
}

fn main() {
    let opt = Opt::from_args();
    let file = File::open(opt.filename).unwrap();
    let reader = BufReader::new(file);
    let color_escapes = Regex::new(r"\x1b\[[0-9;]*m").unwrap();

    let mut out_files = OutFiles::new(opt.output_directory, "log".to_string());
    let mut out_file = out_files.next();

    for l in reader.lines() {
        let line = l.unwrap();
        let without_closing_escape = line.replace("\x1b]133;A\x1b\\", "");

        if line.len() > without_closing_escape.len() {
            if !color_escapes.replace_all(&without_closing_escape, "").is_empty() {
                write_line(&mut out_file, &without_closing_escape).unwrap()
            }

            out_file = out_files.next();
        } else {
            write_line(&mut out_file, &line).unwrap();
        }
    }
}

fn write_line(file: &mut BufWriter<File>, line: &String) -> Result<()> {
    let without_opening_escape = line.replace("\x1b]133;C\x1b\\", "");

    writeln!(file, "{}", without_opening_escape)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic() {
        let buffer: Vec<u8> = Vec::new();
        let mut writer: BufWriter<Vec<u8>> = BufWriter::new(buffer);
        writeln!(writer, "{}", "hi").unwrap();
        assert_eq!(String::from_utf8(writer.into_inner().unwrap()).unwrap(), "hi\n");
    }
}
