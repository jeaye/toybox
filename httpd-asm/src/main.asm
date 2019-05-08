global main

extern socket
extern bind
extern listen
extern accept
extern recv
extern write
extern close

%define buf_size 1024

%include "data.inc"
%include "error.inc"
%include "http.inc"
%include "util/log.inc"

; TODO:
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
          ; int socket(int domain, int type, int protocol);
          call socket
        add esp, 3 * 4
        mov [ebp - 4], eax ; listening_socket

        cmp eax, -1
        je failed_to_create_socket

        log_debug str_created_socket

        ; Bind the socket.
        push sizeof_local_address
        push local_address
        mov eax, [ebp - 4] ; listening_socket
        push eax
          call bind
        add esp, 3 * 4

        cmp eax, -1
        je failed_to_bind_socket

        log_debug str_bound_socket

        listen_forever:
          push SOMAXCONN
          mov eax, [ebp - 4] ; listening_socket
          push eax
            call listen
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
            call accept
          add esp, 3 * 4
          mov [ebp - 8], eax ; incoming_socket

          cmp eax, -1
          je failed_to_accept

          log_debug str_accepted

          mov eax, [ebp - 8] ; incoming_socket
          push eax
            call http_process_request
          add esp, 4

          push len_str_http_200
          push str_http_200
          mov eax, [ebp - 8] ; incoming_socket
          push eax
            call write
          add esp, 3 * 4

          ; Close the client socket.
          mov eax, [ebp - 8] ; incoming_socket
          push eax
            call close
          add esp, 4

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
