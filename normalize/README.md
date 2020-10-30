## A normal map normalizer in Rust [![Build Status](https://travis-ci.org/jeaye/toybox.svg?branch=master)](https://travis-ci.org/jeaye/toybox)

This tool can normalize normal maps in place or into a new image. Many image
formats are supported by default, thanks to
[image-rs](https://github.com/image-rs/image).

The reason this tool may be necessary is that sometimes normal maps need some
manual tweaking. If you're painting a normal map, or manipulating it in some
way, it's very likely that the values will no longer be normalized. When
bringing your normal map back into your rendering engine, you may run into
issues with the normals. A quick solution is to run it through this tool.

### Usage
```
USAGE:
    normalize [OPTIONS] <INPUT>

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -o, --output <FILE>    The output image path (default modifies the input in place)

ARGS:
    <INPUT>    The input image to use
```

### Building for release
```bash
$ cargo build --release
```

### Building for development
Assuming you have a `normal.png` file with which you want to test:

```bash
$ cargo watch --ignore output.png -x "run -- -o output.png normal.png"
```
