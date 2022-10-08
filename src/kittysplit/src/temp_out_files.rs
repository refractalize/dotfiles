use std::path::PathBuf;

use crate::split_lines::OutFiles;

use std::{
    self,
    fs::File,
    io::BufWriter
};

pub struct TempOutFiles {
    directory: PathBuf,
    last_file_index: usize,
    extension: String,
    last_buffer: Option<BufWriter<File>>
}

impl TempOutFiles {
    pub fn new(directory: PathBuf, extension: String) -> TempOutFiles {
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::prelude::*;
    use std::fs;

    #[test]
    fn test_creates_numbered_files_in_directory() -> std::io::Result<()> {
        fs::remove_dir_all("tmp/out").unwrap_or(());
        fs::create_dir_all("tmp/out")?;

        {
            let mut files = TempOutFiles::new(PathBuf::from("tmp/out"), "log".to_string());

            let file1 = files.next();
            writeln!(file1, "{}", "file1")?;

            let file2 = files.next();
            writeln!(file2, "{}", "file2")?;

            let file3 = files.next();
            writeln!(file3, "{}", "file3")?;
        }

        let mut files: Vec<(PathBuf, String)> = fs::read_dir("tmp/out")?.map(|entry_result| {
            let entry = entry_result.unwrap();
            (entry.path(), fs::read_to_string(entry.path()).unwrap())
        }).collect();

        files.sort_by(|a, b| a.partial_cmp(b).unwrap());

        assert_eq!(
            files,
            vec![
                (PathBuf::from("tmp/out/001.log"), "file1\n".to_string()),
                (PathBuf::from("tmp/out/002.log"), "file2\n".to_string()),
                (PathBuf::from("tmp/out/003.log"), "file3\n".to_string())
            ]
        );

        fs::remove_dir_all("tmp/out")?;

        Ok(())
    }
}
