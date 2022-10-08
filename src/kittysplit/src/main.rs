use std::io::prelude::*;
use std::path::PathBuf;
use std::{self, fs::File, io::BufReader};
use structopt::StructOpt;

mod split_lines;

#[derive(Debug, StructOpt)]
#[structopt(name = "example", about = "An example of StructOpt usage.")]
struct Opt {
    #[structopt(parse(from_os_str))]
    filename: PathBuf,

    #[structopt(parse(from_os_str))]
    output_directory: PathBuf,
}

fn main() {
    let opt = Opt::from_args();
    let file = File::open(opt.filename).unwrap();
    let reader = BufReader::new(file);

    let mut out_files = split_lines::TempOutFiles::new(opt.output_directory, "log".to_string());
    let lines: std::io::Lines<BufReader<File>> = reader.lines();

    split_lines::split_lines(lines.map(|l| l.unwrap()), &mut out_files).unwrap();
}
