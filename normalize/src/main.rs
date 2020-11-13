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

const EQUALISH_LENIENCY: f32 = 1.0;
fn equalish((l_r, l_g, l_b): Channels, (r_r, r_g, r_b): Channels) -> bool {
  (r_r - l_r).abs() <= EQUALISH_LENIENCY
    && (r_g - l_g).abs() <= EQUALISH_LENIENCY
    && (r_b - l_b).abs() <= EQUALISH_LENIENCY
}

fn process_file(just_check: bool, input: &str, output: &str) -> bool {
  let mut is_changed = false;
  let mut img = image::open(input).unwrap().to_rgb();

  img.enumerate_pixels_mut().for_each(|(_x, _y, pixel)| {
    let input_channels = (pixel[0] as f32, pixel[1] as f32, pixel[2] as f32);
    let tmp = scale_down(input_channels);
    let tmp = decode(tmp);
    let tmp = normalize(tmp);
    let tmp = encode(tmp);
    let tmp = scale_up(tmp);
    let output_channels = round(tmp);

    is_changed |= !equalish(input_channels, output_channels);

    *pixel = image::Rgb([
      output_channels.0 as u8,
      output_channels.1 as u8,
      output_channels.2 as u8,
    ]);
  });

  if !just_check {
    img.save(output).unwrap();
  }

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
      clap::Arg::with_name("check")
        .short("c")
        .long("check")
        .help("Perform a dry run and check if the input is normalized"),
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
  let just_check = matches.is_present("check");

  let is_changed = process_file(just_check, input_file, output_file);

  if is_changed {
    if just_check {
      println!("needs normalizing: {}", input_file);
    } else {
      /* Perform a second pass, to account for floating point issues. */
      process_file(just_check, output_file, output_file);

      println!("normalized: {}", input_file);
    }
  }
}
