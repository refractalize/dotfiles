use std::env;

fn main() {
  let args: Vec<String> = env::args().collect();

  if args.len() >= 2 {
    let mut duration: u32 = args[1].parse().unwrap();

    let hours: u32 = duration / 3600000;
    duration = duration % 3600000;
    let minutes: u32 = duration / 60000;
    duration = duration % 60000;
    let seconds: u32 = duration / 1000;
    duration = duration % 1000;
    let ms: u32 = duration;

    println!("{}:{:02}:{:02}.{:04}", hours, minutes, seconds, ms);
  }
}
