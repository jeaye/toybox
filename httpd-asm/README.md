## A static file server in x86 Assembly [![Build Status](https://travis-ci.org/jeaye/toybox.svg?branch=master)](https://travis-ci.org/jeaye/toybox)

Features and qualities:

* Just under 1K lines of x86 NASM source
* No libc (all batteries included)
* No allocations
* Release binary weighs in at 8.4KB (half the size of a C++ hello world)
* Parallelized request handling via fork
* Automatic directory index handling
* Continuous testing suite

### Building for release
You can make a tiny build using the following command. The generated binary is
`build/httpd`. The server will serve from its working directory on port 15000
when started.

```bash
$ LOGGING=0 RELEASE=1 make -B
```

### Building for development
This project compiles instantly, so just using `make run` will build and run the
latest code.

### Why build this?
I wanted to know what it was like to build a super bare-bones web server in x86
Assembly. Now I know.
