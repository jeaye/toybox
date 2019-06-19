%include "http.inc"
%include "data.inc"
%include "data.extern.inc"
%include "error.extern.inc"
%include "sys.inc"
%include "util/string.extern.inc"
%include "util/log.inc"
%include "util/log.extern.inc"

section .text
  ; input:
  ;   eax = incoming socket
  global http_process_request
  http_process_request:
    push ebp
      mov ebp, esp

      ; ebp - 4: int incoming_socket;
      sub esp, 4
        mov [ebp - 4], eax ; incoming_socket

        ; Clear the request context.
        xor eax, eax
        mov ecx, sizeof_http_request_context
        mov edi, request_context
        call string_fill

        ; TODO: Read the full request, based on:
        ; https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5
        push 0 ; flags
        push len_request_buffer
        mov eax, request_buffer
        push eax
        mov eax, [ebp - 4] ; incoming_socket
        push eax
          mov eax, sys_socketcall
          mov ebx, sys_socketcall_recv
          mov ecx, esp
          int 0x80
        add esp, 4 * 4

        cmp eax, -1
        je failed_to_recv

        ; Always cut the buffer off with a null. This is safe, since we only
        ; ever read the max length - 1 into the buffer.
        mov byte [request_buffer + eax], 0

        log_debug request_buffer

        mov eax, request_context
        mov ebx, [ebp - 4] ; incoming_socket
        mov [eax + http_request_context.socket], ebx

        call http_parse_request
        call http_find_resource
        call http_write_response
        call http_cleanup
      add esp, 4
    pop ebp
    ret

  http_parse_request:
    push ebp
      mov ebp, esp

      ; ebp - 4: char *request_buffer_ptr;
      sub esp, 4
        mov dword [ebp - 4], request_buffer ; request_buffer_ptr

        ; Parse out the method.
        mov eax, request_buffer
        mov ebx, space
        call string_find_first

        ; Verify the method fits within its buffer.
        cmp ecx, max_http_method_length
        jge http_parse_request_bad_request

        ; ecx = method length
        mov esi, [ebp - 4] ; request_buffer_ptr
        lea edi, [request_context + http_request_context.method]
        call string_copy

        ; Move our buffer ptr to the start of the path.
        inc esi ; Skip the space between the method and path.
        mov [ebp - 4], esi ; request_buffer_ptr

        ; Now check the method against those supported.
        lea esi, [request_context + http_request_context.method]
        mov edi, str_http_method_get
        call string_compare
        test eax, eax
        jz http_parse_request_bad_request

        ; Parse out the path.
        mov eax, [ebp - 4] ; request_buffer_ptr
        mov ebx, space
        call string_find_first

        ; Verify the path fits within its buffer.
        cmp ecx, max_http_path_length
        jge http_parse_request_bad_request

        ; ecx = path length
        push ecx
          ; We want to copy the path, but we'll prefix the CWD before it.
          mov ecx, len_str_working_dir
          mov esi, str_working_dir
          lea edi, [request_context + http_request_context.path]
          call string_copy
        pop ecx
        mov esi, [ebp - 4] ; request_buffer_ptr
        lea edi, [request_context + http_request_context.path]
        call string_append

        ; Move our buffer ptr to the start of the path.
        inc esi ; Skip the space between the path and version.
        mov [ebp - 4], esi ; request_buffer_ptr

        ; TODO: validate path
        ; TODO: validate version

        ; Everything's good.
        jmp http_parse_request_end

        http_parse_request_bad_request:
          log_debug str_bad_request
          mov eax, request_context
          mov dword [eax + http_request_context.status_code], http_status_bad_request

  http_parse_request_end:
      add esp, 4
    pop ebp
    ret

  failed_to_recv:
    log_error str_failed_to_receive_data
    mov eax, 1
    jmp error_die

  http_find_resource:
    push ebp
      mov ebp, esp

      ; ebp - 4: char *path;
      sub esp, 4
        ; If we already have a status code, skip this.
        mov dword eax, [request_context + http_request_context.status_code]
        test eax, eax
        jnz http_find_resource_end

        lea eax, [request_context + http_request_context.path]
        ;inc eax ; Skip leading slash to make the path relative.
        mov [ebp - 4], eax ; path

        ; TODO: It's possible to climb outside the web root using ../

        ; TODO: sys_openat relative and enforce it's below the CWD
        ; Open the file and hang onto the descriptor. We'll never read this into
        ; user space; it'll just get piped right to the socket in kernel space.
        mov eax, sys_open
        mov ebx, [ebp - 4] ; path
        xor ecx, ecx
        xor edx, edx
        int 0x80

        cmp eax, 0
        jl http_find_resource_error

        mov [request_context + http_request_context.resource_file], eax

        ; Look up the file info.
        mov ebx, eax
        mov eax, sys_fstat64
        mov ecx, file_stat
        int 0x80

        test eax, eax
        jnz http_find_resource_error

        mov eax, [file_stat + stat.st_mode]
        and eax, sys_s_ifmt
        cmp eax, sys_s_ifdir
        je http_find_resource_directory

        mov eax, [file_stat + stat.st_size]
        mov [request_context + http_request_context.resource_file_len], eax

        jmp http_find_resource_end

        http_find_resource_directory:
          ; If we've loaded a directory, check for an index. To do this, we'll
          ; append index.html to the context path and recurse.
          mov ecx, len_str_http_index_html
          mov esi, str_http_index_html
          lea edi, [request_context + http_request_context.path]
          ; TODO: Check length before appending
          call string_append

          ; Close the directory.
          mov eax, sys_close
          mov ebx, [request_context + http_request_context.resource_file]
          int 0x80

          ; Recurse.
          call http_find_resource
          jmp http_find_resource_end

        http_find_resource_error:
          mov dword [request_context + http_request_context.status_code], 404

  http_find_resource_end:
      add esp, 4
    pop ebp
    ret

  http_write_response:
    push ebp
      mov ebp, esp
      ; ebp - http_response_line_len: char *status_line;
      sub esp, http_response_line_len
        mov dword eax, [request_context + http_request_context.status_code]
        cmp eax, 400
        jge http_write_response_error

        http_write_response_200:
          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_http_200
          mov edx, len_str_http_200
          int 0x80

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_http_content_length
          mov edx, len_str_http_content_length
          int 0x80

          mov eax, [request_context + http_request_context.resource_file_len]
          mov ebx, 10
          mov ecx, http_response_line_len
          lea edi, [ebp - http_response_line_len]
          call string_from_integer

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov edx, ecx
          mov ecx, edi
          int 0x80

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_cr_lf_cr_lf
          mov edx, len_str_cr_lf_cr_lf
          int 0x80

          mov eax, sys_sendfile
          mov ebx, [request_context + http_request_context.socket]
          xor edx, edx
          mov ecx, [request_context + http_request_context.resource_file]
          mov esi, [request_context + http_request_context.resource_file_len]
          int 0x80

          jmp http_write_response_end

        http_write_response_error:
          ; No body sent with errors.
          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_http_version
          mov edx, len_str_http_version
          int 0x80

          mov dword eax, [request_context + http_request_context.status_code]
          mov ebx, 10
          mov ecx, http_response_line_len
          lea edi, [ebp - http_response_line_len]
          call string_from_integer

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov edx, ecx
          mov ecx, edi
          int 0x80

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_http_ignored
          mov edx, len_str_http_ignored
          int 0x80

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_http_content_length
          mov edx, len_str_http_content_length
          int 0x80

          xor eax, eax
          mov ebx, 10
          mov ecx, http_response_line_len
          lea edi, [ebp - http_response_line_len]
          call string_from_integer

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov edx, ecx
          mov ecx, edi
          int 0x80

          mov eax, sys_write
          mov ebx, [request_context + http_request_context.socket]
          mov ecx, str_cr_lf_cr_lf
          mov edx, len_str_cr_lf_cr_lf
          int 0x80

  http_write_response_end:
      add esp, http_response_line_len
    pop ebp
    ret

  http_cleanup:
    mov eax, sys_close
    mov ebx, [request_context + http_request_context.resource_file]
    int 0x80
    ret
