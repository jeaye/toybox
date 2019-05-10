global main

%define buf_size 1024

%include "data.inc"
%include "error.inc"
%include "socket.inc"
%include "sys.inc"
%include "http.inc"
%include "util/log.inc"

; TODO:
;   - Remove libc
;   - File IO
;   - Dynamic HTTP responses

section .text
  main:
    push ebp
      mov ebp, esp

      log_debug str_server_starting

      ; ebp - 4: int listening_socket;
      ; ebp - 8: int incoming_socket;
      ; ebp - 12: socklen_t addrlen;
      sub esp, 12
        ; Create the socket.
        push IPPROTO_IP
        push SOCK_STREAM
        push AF_INET
          mov eax, sys_socketcall
          mov ebx, sys_socketcall_socket
          mov ecx, esp
          int 0x80
        add esp, 3 * 4
        mov [ebp - 4], eax ; listening_socket

        cmp eax, -1
        je failed_to_create_socket

        log_debug str_created_socket

        ; Set up the local address.
        mov eax, local_address
        mov word [eax + sockaddr_in.sin_family], AF_INET
        ; TODO: Read this from the command line.
        mov word [eax + sockaddr_in.sin_port], 0x983a ; htons(1500)

        ; Allow address reuse.
        push 1 ; true
        push 4 ; sizeof(int)
        lea eax, [esp + 4] ; address of the true
        push eax
        push so_reuseaddr
        push sol_socket
        mov eax, [ebp - 4] ; listening_socket
        push eax
          mov eax, sys_socketcall
          mov ebx, sys_socketcall_setsockopt
          mov ecx, esp
          int 0x80
        add esp, 6 * 4

        ; Bind the socket.
        push sizeof_sockaddr_in
        push local_address
        mov eax, [ebp - 4] ; listening_socket
        push eax
          mov eax, sys_socketcall
          mov ebx, sys_socketcall_bind
          mov ecx, esp
          int 0x80
        add esp, 3 * 4

        cmp eax, -1
        je failed_to_bind_socket

        log_debug str_bound_socket

        listen_forever:
          push SOMAXCONN
          mov eax, [ebp - 4] ; listening_socket
          push eax
            mov eax, sys_socketcall
            mov ebx, sys_socketcall_listen
            mov ecx, esp
            int 0x80
          add esp, 2 * 4

          cmp eax, -1
          je failed_to_listen

          log_debug str_listening

          ; Block and wait for a client.
          lea eax, [ebp - 12] ; &addrlen (ignored)
          push eax
          push remote_address
          mov eax, [ebp - 4] ; listening_socket
          push eax
            mov eax, sys_socketcall
            mov ebx, sys_socketcall_accept
            mov ecx, esp
            int 0x80
          add esp, 3 * 4
          mov [ebp - 8], eax ; incoming_socket

          cmp eax, -1
          je failed_to_accept

          log_debug str_accepted

          mov eax, [ebp - 8] ; incoming_socket
          push eax
            call http_process_request
          add esp, 4

          mov eax, sys_write
          mov ebx, [ebp - 8] ; incoming_socket
          mov ecx, str_http_200
          mov edx, len_str_http_200
          int 0x80

          ; Close the client socket.
          mov eax, sys_close
          mov ebx, [ebp - 8] ; incoming_socket
          int 0x80

          ; Forever…
          jmp listen_forever
      add esp, 12

      mov eax, 0 ; Program exit status.
    pop ebp
    ret

failed_to_create_socket:
  log_error str_failed_to_create_socket
  mov eax, 1
  jmp error_die

failed_to_bind_socket:
  log_error str_failed_to_bind_socket
  mov eax, 1
  jmp error_die

failed_to_listen:
  log_error str_failed_to_listen
  mov eax, 1
  jmp error_die

failed_to_accept:
  log_error str_failed_to_accept
  mov eax, 1
  jmp error_die
