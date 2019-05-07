%define newline 0xA
%define null 0x0

%macro str_green 2
  %1: db 0x1b,0x5b,0x33,0x32,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro
%macro str_orange 2
  %1: db 0x1b,0x5b,0x39,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro
%macro str_red 2
  %1: db 0x1b,0x5b,0x33,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro

%define AF_INET 0x2
%define SOCK_STREAM 0x1
%define IPPROTO_IP 0x0
%define SOMAXCONN 128

struc sockaddr_in
  .sin_family: resw 1
  .sin_port: resw 1
  .sin_addr: resd 1
  .sin_zero: resb 8
endstruc

section .data
  ; Debug strings.
  str_green str_debug_log_prefix,'>>> '
  str_red str_error_log_prefix,'>>> '
  str_200: db 'HTTP/1.1 200 OK',newline,null
  str_content_length: db 'Content-Length: 29',newline,null
  str_content_type: db 'Content-Type: text/html',newline,newline,null
  str_hello: db '<html><h3>Success</h3></html>',newline,null

  ; Info strings.
  str_server_starting: db 'httpd is starting…',newline,null
  str_created_socket: db 'socket created',newline,null
  str_bound_socket: db 'socket bound',newline,null
  str_listening: db 'listening…',newline,null
  str_accepted: db 'accepted new client…',newline,null

  ; Error strings.
  str_failed_to_create_socket: db 'failed to create socket',newline,null
  str_failed_to_bind_socket: db 'failed to bind socket',newline,null
  str_failed_to_listen: db 'failed to listen',newline,null
  str_failed_to_accept: db 'failed to accept',newline,null

  ; Listening socket properties.
  local_address: istruc sockaddr_in
    at sockaddr_in.sin_family, dw AF_INET
    at sockaddr_in.sin_port, dw 0x983a ; htons(1500)
    at sockaddr_in.sin_addr, dd 0x0
    at sockaddr_in.sin_zero, dd 0x0
  iend
  %define sizeof_local_address 16

  ; Remove client properties. This is reused for each client.
  remote_address: istruc sockaddr_in
    at sockaddr_in.sin_family, dw AF_INET
    at sockaddr_in.sin_port, dw 0x0
    at sockaddr_in.sin_addr, dd 0x0
    at sockaddr_in.sin_zero, dd 0x0
  iend
  %define sizeof_remote_address 16
