## A static file server in x86 Assembly

Features and qualities:

* Purely x86 NASM source
* No libc (batteries included)
* No allocations
* Release binary is 8.4KB

### References
* HTTP 1.1 spec: https://www.w3.org/Protocols/rfc2616/rfc2616.html
* Register preservation: https://en.wikipedia.org/wiki/X86_calling_conventions#Register_preservation
* Syscalls: https://en.wikibooks.org/wiki/X86_Assembly/Interfacing_with_Linux
* Fast syscalls: https://blog.packagecloud.io/eng/2016/04/05/the-definitive-guide-to-linux-system-calls/#fast-system-calls
* Simple C server: http://blog.manula.org/2011/05/writing-simple-web-server-in-c.html
* Beej's guide: https://beej.us/guide/bgnet/html/single/bgnet.html
* HTTP server in Python: https://ruslanspivak.com/lsbaws-part1/
