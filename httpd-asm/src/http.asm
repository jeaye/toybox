%include "data.inc"
%include "error.inc"
%include "util/log.inc"

extern malloc
extern recv

global http_process_request

section .text
  ; eax = incoming_socket
  http_process_request:
    push ebp
      mov ebp, esp

      ; ebp - 4: int incoming_socket;
      ; ebp - 8: char *buffer;
      sub esp, 8
        mov [ebp - 4], eax

        push 1024 ; TODO: constant
          call malloc
          mov [ebp - 8], eax ; buffer
        add esp, 4

        test eax, eax
        jz error_failed_allocation

        ; TODO: Read the full request, based on:
        ; https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5
        push 0 ; flags
        push 1024 ; TODO: constant
        mov eax, [ebp - 8] ; buffer
        push eax
        mov eax, [ebp - 4] ; incoming_socket
        push eax
          call recv
        add esp, 4 * 4

        cmp eax, -1
        je failed_to_recv

        log_debug [ebp - 8]
      add esp, 8
    pop ebp
    ret

failed_to_recv:
  log_error str_failed_to_receive_data
  mov eax, 1
  jmp error_die
