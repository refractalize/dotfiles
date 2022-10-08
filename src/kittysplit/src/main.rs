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

struct TempOutFiles {
    directory: PathBuf,
    last_file_index: usize,
    extension: String,
    last_buffer: Option<BufWriter<File>>
}

trait OutFiles<T>
    where T: Write
{
    fn next(&mut self) -> &mut BufWriter<T>;
}

impl TempOutFiles {
    fn new(directory: PathBuf, extension: String) -> TempOutFiles {
        TempOutFiles {
            directory,
            last_file_index: 0,
            extension,
            last_buffer: None
        }
    }
}

impl OutFiles<File> for TempOutFiles {
    fn next(&mut self) -> &mut BufWriter<File> {
        self.last_file_index += 1;
        let path = self.directory
            .join(format!("{:03}", self.last_file_index))
            .with_extension(&self.extension);

        self.last_buffer = Some(BufWriter::new(File::create(path).unwrap()));
        return self.last_buffer.as_mut().unwrap()
    }
}

fn main() {
    let opt = Opt::from_args();
    let file = File::open(opt.filename).unwrap();
    let reader = BufReader::new(file);

    let mut out_files = TempOutFiles::new(opt.output_directory, "log".to_string());
    let lines: std::io::Lines<BufReader<File>> = reader.lines();

    split_lines(lines.map(|l| l.unwrap()), &mut out_files).unwrap();
}

fn split_lines<I, O, OType>(lines: I, out_files: &mut O) -> Result<()>
    where I: IntoIterator<Item=String>, O: OutFiles<OType>, OType: Write
{
    let color_escapes = Regex::new(r"\x1b\[[0-9;]*m").unwrap();
    let mut out_file = out_files.next();

    for line in lines {
        let without_closing_escape = line.replace("\x1b]133;A\x1b\\", "");

        if line.len() > without_closing_escape.len() {
            if !color_escapes.replace_all(&without_closing_escape, "").is_empty() {
                write_line(out_file, &without_closing_escape)?
            }

            out_file = out_files.next();
        } else {
            write_line(out_file, &line)?;
        }
    }

    Ok(())
}

fn write_line<W>(file: &mut BufWriter<W>, line: &String) -> Result<()>
    where W: Write
{
    let without_opening_escape = line.replace("\x1b]133;C\x1b\\", "");

    writeln!(file, "{}", without_opening_escape)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use indoc::indoc;

    struct StringOutFiles {
        files: Vec<BufWriter<Vec<u8>>>
    }

    impl StringOutFiles {
        fn new() -> StringOutFiles {
            StringOutFiles {
                files: Vec::new()
            }
        }

        fn all_files(self) -> Vec<String> {
            // String::from_utf8(self.files.pop().unwrap().into_inner().unwrap()).unwrap()
            self.files.into_iter().map(move |writer| String::from_utf8(writer.into_inner().unwrap()).unwrap()).collect()
        }
    }

    impl OutFiles<Vec<u8>> for StringOutFiles {
        fn next(&mut self) -> &mut BufWriter<Vec<u8>> {
            let writer = BufWriter::new(Vec::new());
            self.files.push(writer);
            self.files.last_mut().unwrap()
        }
    }

    #[test]
    fn test_out_files() {
        let mut out_files = StringOutFiles::new();
        let buffer = out_files.next();
        writeln!(buffer, "{}", "hi").unwrap();
        assert_eq!(
            out_files.all_files(),
            vec![
                "hi\n".to_string()
            ]
        );
    }

    #[test]
    fn test_writing_to_vec() {
        let buffer: Vec<u8> = Vec::new();
        let mut writer: BufWriter<Vec<u8>> = BufWriter::new(buffer);
        writeln!(writer, "{}", "hi").unwrap();
        assert_eq!(String::from_utf8(writer.into_inner().unwrap()).unwrap(), "hi\n");
    }

    #[test]
    fn test_basic() -> Result<()> {
        let mut out_files = StringOutFiles::new();
        let input = indoc! {"
            output0
            \x1b]133;A\x1b\\
            prompt1
            \x1b]133;C\x1b\\output1
            \x1b]133;A\x1b\\
            prompt2
        "}.to_string();
        let lines = input.lines().map(|s| s.to_string());
        split_lines(lines, &mut out_files)?;

        assert_eq!(
            out_files.all_files(),
            vec![
                indoc! {"
                    output0
                "}.to_string(),
                indoc! {"
                    prompt1
                    output1
                "}.to_string(),
                indoc! {"
                    prompt2
                "}.to_string()
            ]
        );

        Ok(())
    }

    #[test]
    fn test_closing_on_same_line() -> Result<()> {
        let mut out_files = StringOutFiles::new();
        let input = indoc! {"
            output0
            \x1b]133;A\x1b\\
            prompt1
            \x1b]133;C\x1b\\output1
            output1\x1b]133;A\x1b\\
            prompt2
        "}.to_string();
        let lines = input.lines().map(|s| s.to_string());
        split_lines(lines, &mut out_files)?;

        assert_eq!(
            out_files.all_files(),
            vec![
                indoc! {"
                    output0
                "}.to_string(),
                indoc! {"
                    prompt1
                    output1
                    output1
                "}.to_string(),
                indoc! {"
                    prompt2
                "}.to_string()
            ]
        );

        Ok(())
    }
    #[test]
    fn test_closing_with_color_escapes() -> Result<()> {
        let mut out_files = StringOutFiles::new();
        let input = indoc! {"
            output0
            \x1b]133;A\x1b\\
            prompt1
            \x1b]133;C\x1b\\output1
            output1
            \x1b[32m\x1b]133;A\x1b\\
            prompt2
        "}.to_string();
        let lines = input.lines().map(|s| s.to_string());
        split_lines(lines, &mut out_files)?;

        assert_eq!(
            out_files.all_files(),
            vec![
                indoc! {"
                    output0
                "}.to_string(),
                indoc! {"
                    prompt1
                    output1
                    output1
                "}.to_string(),
                indoc! {"
                    prompt2
                "}.to_string()
            ]
        );

        Ok(())
    }
}
