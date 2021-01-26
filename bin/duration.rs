use std::env;

fn main() {
  let args: Vec<String> = env::args().collect();

  if args.len() >= 2 {
    let mut duration: u32 = args[1].parse().unwrap();
    let mut units: Vec<String> = Vec::new();

    let hours: u32 = duration / 3600000;
    duration = duration % 3600000;
    if hours > 0 {
      units.push(format!("{}", hours));
    }

    let minutes: u32 = duration / 60000;
    duration = duration % 60000;
    if minutes > 0 {
      if units.len() > 0 {
        units.push(format!("{:02}", minutes));
      } else {
        units.push(format!("{}", minutes));
      }
    }

    let seconds: u32 = duration / 1000;
    duration = duration % 1000;
    let ms: u32 = duration;
    if units.len() > 0 {
      units.push(format!("{:02}.{:03}", seconds, ms));
    } else {
      units.push(format!("{}.{:03}", seconds, ms));
    }

    println!("{}", units.join(":"));
  }
}
