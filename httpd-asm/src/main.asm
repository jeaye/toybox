global main

extern printf
extern socket
extern exit

%define AF_INET 0x2
%define SOCK_STREAM 0x1
%define IPPROTO_IP 0x0

%define buf_size 1024

%include "data.inc"
%include "util/log.inc"

section .text
  main:
    push ebp
      mov ebp, esp

      log_debug server_starting_str

      ; ebp - 4: int create_socket;
      sub esp, 4
        push IPPROTO_IP
        push SOCK_STREAM
        push AF_INET
          ; int socket(int domain, int type, int protocol);
          call socket
          mov [ebp - 4], eax
        add esp, 3 * 4

        cmp eax, -1
        je failed_to_create_socket

        log_debug created_socket_str
      add esp, 4

      mov eax, 0 ; Program exit status.
    pop ebp
    ret

failed_to_create_socket:
  sub esp, 4
    mov eax, failed_to_create_socket_str
    mov [esp], eax
    call printf
  add esp, 4

  mov eax, 1
  jmp die

die: ; eax = status code
  push eax
  call exit
