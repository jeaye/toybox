extern crate clap;
extern crate image;

type Channels = (f32, f32, f32);

fn decode_channel(chan: f32) -> f32 {
  (chan * 2.0) - 1.0
}

fn decode((r, g, b): Channels) -> Channels {
  (decode_channel(r), decode_channel(g), decode_channel(b))
}

fn encode_channel(chan: f32) -> f32 {
  (chan + 1.0) / 2.0
}

fn encode((r, g, b): Channels) -> Channels {
  (encode_channel(r), encode_channel(g), encode_channel(b))
}

fn scale_up((r, g, b): Channels) -> Channels {
  let scale = u8::MAX as f32;
  (r * scale, g * scale, b * scale)
}

fn scale_down((r, g, b): Channels) -> Channels {
  let scale = u8::MAX as f32;
  (r / scale, g / scale, b / scale)
}

fn normalize((r, g, b): Channels) -> Channels {
  let length = ((r * r) + (g * g) + (b * b)).sqrt();
  (r / length, g / length, b / length)
}

fn round((r, g, b): Channels) -> Channels {
  (r.round(), g.round(), b.round())
}

fn process_file(input: &str, output: &str) -> bool {
  let mut is_changed = false;
  let mut img = image::open(input).unwrap().to_rgb();

  img.enumerate_pixels_mut().for_each(|(_x, _y, pixel)| {
    let channels = (pixel[0] as f32, pixel[1] as f32, pixel[2] as f32);
    let channels = scale_down(channels);
    let channels = decode(channels);
    let channels = normalize(channels);
    let channels = encode(channels);
    let channels = scale_up(channels);
    let (r, g, b) = round(channels);

    is_changed |= (r as u8, g as u8, b as u8) != (pixel[0], pixel[1], pixel[2]);

    *pixel = image::Rgb([r as u8, g as u8, b as u8]);
  });

  img.save(output).unwrap();

  is_changed
}

fn main() {
  let matches = clap::App::new(clap::crate_name!())
    .author(clap::crate_authors!("\n"))
    .version(clap::crate_version!())
    .about(clap::crate_description!())
    .arg(
      clap::Arg::with_name("output")
        .short("o")
        .long("output")
        .value_name("FILE")
        .help("The output image path (default modifies the input in place)")
        .takes_value(true),
    )
    .arg(
      clap::Arg::with_name("INPUT")
        .help("The input image to use")
        .required(true)
        .index(1),
    )
    .get_matches();

  let input_file = matches.value_of("INPUT").unwrap();
  let output_file = matches.value_of("output").unwrap_or(input_file);

  let is_changed = process_file(input_file, output_file);

  if is_changed {
    /* Perform a second pass, to account for floating point issues. */
    process_file(output_file, output_file);

    println!("normalized: {}", input_file);
  }
}
