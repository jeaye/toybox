%define newline 0xA
%define null 0x0

%define color_orange {0x1b,0x5b,0x39,0x31,0x6d}

%macro str_green 2
  %1: db 0x1b,0x5b,0x33,0x32,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro
%macro str_orange 2
  %1: db 0x1b,0x5b,0x39,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro
%macro str_red 2
  %1: db 0x1b,0x5b,0x33,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro

section .data
  ; Debug strings.
  str_green str_debug_log_prefix,'>>> '
  str_red str_error_log_prefix,'>>> '

  ; Info strings.
  str_server_starting: db 'httpd is starting…',newline,null
  str_created_socket: db 'socket created',newline,null

  ; Error strings.
  str_failed_to_create_socket: db 'failed to create socket',newline,null
