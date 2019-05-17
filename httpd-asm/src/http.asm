%include "data.inc"
%include "error.extern.inc"
%include "sys.inc"
%include "util/string.extern.inc"
%include "util/log.inc"
%include "util/log.extern.inc"

section .text
  ; eax = incoming_socket
  global http_process_request
  http_process_request:
    push ebp
      mov ebp, esp

      ; ebp - 4: int incoming_socket;
      sub esp, 4
        mov [ebp - 4], eax ; incoming_socket

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
        ;call http_find_resources
        ;call http_write_response
      add esp, 4
    pop ebp
    ret

http_parse_request:
  push ebp
    mov ebp, esp

    ; Parse out the method.
    mov eax, request_buffer
    mov ebx, space
    call string_find_first

    ; Verify the method fits within its buffer.
    cmp ecx, max_http_method_length
    jge http_parse_request_bad_request

    ; ecx = method length
    mov esi, request_buffer
    lea edi, [request_context + http_request_context.method]
    call string_copy

    ; Now check the method against those supported.
    ; TODO

    ; Everything's good.
    jmp http_parse_request_end

    http_parse_request_bad_request:
      mov eax, request_context
      mov dword [eax + http_request_context.status_code], http_status_bad_request

http_parse_request_end:
  pop ebp
  ret

failed_to_recv:
  log_error str_failed_to_receive_data
  mov eax, 1
  jmp error_die
