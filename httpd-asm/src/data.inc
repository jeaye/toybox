%define newline 0xA
%define null 0x0

%define color_orange {0x1b,0x5b,0x39,0x31,0x6d}

%macro str_orange 2
  %1: db 0x1b,0x5b,0x39,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
%endmacro

section .data
  ; Debug strings.
  str_orange debug_log_prefix_str,'>>> '

  ; Info strings.
  server_starting_str: db 'httpd is starting…',newline,null
  created_socket_str: db 'socket created',newline,null

  ; Error strings.
  failed_to_create_socket_str: db 'failed to create socket',newline,null
