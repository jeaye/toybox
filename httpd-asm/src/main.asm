global main

extern socket
extern bind
extern exit

%define buf_size 1024

%include "data.inc"
%include "util/log.inc"

section .text
  main:
    push ebp
      mov ebp, esp

      log_debug str_server_starting

      ; ebp - 4: int create_socket;
      sub esp, 4
        ; Create the socket.
        push IPPROTO_IP
        push SOCK_STREAM
        push AF_INET
          ; int socket(int domain, int type, int protocol);
          call socket
          mov [ebp - 4], eax
        add esp, 3 * 4

        cmp eax, -1
        je failed_to_create_socket

        log_debug str_created_socket

        ; Bind the socket.
        push sizeof_socket_address
        push socket_address
        mov eax, [ebp - 4]
        push eax
        call bind
        add esp, 3 * 4

        cmp eax, -1
        je failed_to_bind_socket

        log_debug str_bound_socket
      add esp, 4

      mov eax, 0 ; Program exit status.
    pop ebp
    ret

failed_to_create_socket:
  log_error str_failed_to_create_socket
  mov eax, 1
  jmp die

failed_to_bind_socket:
  log_error str_failed_to_bind_socket
  mov eax, 1
  jmp die

die: ; eax = status code
  push eax
  call exit
