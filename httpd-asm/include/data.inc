; TODO: Including this in multiple places is causing file bloat; why?
%ifndef data_inc
  %define data_inc

  %include "socket.inc"
  %include "http.inc"
  %include "sys.inc"

  %define null 0x0
  %define cr 0xD
  %define lf 0xA
  %define space 0x20

  %macro str_green 2
    %1: db 0x1b,0x5b,0x33,0x32,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro
  %macro str_orange 2
    %1: db 0x1b,0x5b,0x39,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro
  %macro str_red 2
    %1: db 0x1b,0x5b,0x33,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro

  %macro def_str 2+
    str_%1: db %2,null
    len_str_%1: equ $ - str_%1 - 1 ; Always decrement for the null.
  %endmacro

  section .data
    ; TODO: Use literals for logs
    %if LOGGING
      %if DEBUG
        ; Debug strings.
        str_green str_debug_log_prefix,'>>> '
        def_str server_starting, 'httpd is starting…',cr,lf
        def_str created_socket, 'socket created',cr,lf
        def_str bound_socket, 'socket bound',cr,lf
        def_str listening, 'listening…',cr,lf
        def_str accepted, 'accepted new client…',cr,lf
      %endif

      ; Error strings.
      str_red str_error_log_prefix,'>>> '
      def_str failed_to_create_socket, 'failed to create socket',cr,lf
      def_str failed_to_bind_socket, 'failed to bind socket',cr,lf
      def_str failed_to_listen, 'failed to listen',cr,lf
      def_str failed_to_accept, 'failed to accept',cr,lf
      def_str failed_to_receive_data, 'failed to receive data',cr,lf
      def_str failed_to_allocate_memory, 'failed to allocate memory',cr,lf
    %endif

    ; Misc strings.
    def_str empty, ''
    def_str cr_lf_cr_lf, cr,lf,cr,lf
    def_str base_chars, '0123456789ABCDEF'

    ; HTTP strings.
    def_str http_method_get, 'GET'
    def_str http_version, 'HTTP/1.1 '
    def_str http_ignored, ' Ignored',cr,lf
    def_str http_content_length, 'Content-Length: '
    def_str http_index_html, 'index.html'
    def_str http_200, 'HTTP/1.1 200 OK',cr,lf

  section .bss
    ; The CWD of the server.
    str_working_dir: resb 1024
    len_str_working_dir: equ $ - str_working_dir - 1 ; Always space for a null.

    ; Listening socket properties.
    local_address: resb sizeof_sockaddr_in
    ; Remote client properties. This is reused for each client.
    remote_address: resb sizeof_sockaddr_in

    ; Stores the received HTTP request.
    request_buffer: resb 1024
    len_request_buffer: equ $ - request_buffer - 1 ; Always space for a null.

    request_context: resb sizeof_http_request_context

    ; Used for general file lookups.
    file_stat: resb sizeof_stat

%endif
