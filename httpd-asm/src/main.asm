%include "data.extern.inc"
%include "error.extern.inc"
%include "socket.inc"
%include "sys.inc"
%include "http.extern.inc"
%include "util/log.inc"
%include "util/log.extern.inc"

section .text
  global _start
  _start:
    mov ebp, esp

    log_debug str_server_starting

    call get_working_directory

    ; ebp - 4: int listening_socket;
    ; ebp - 8: int incoming_socket;
    ; ebp - 12: socklen_t addrlen;
    sub esp, 12
      ; Create the socket.
      push socket_ipproto_ip
      push socket_sock_stream
      push socket_af_inet
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
      mov word [eax + sockaddr_in.sin_family], socket_af_inet
      ; TODO: Read this from the command line.
      mov word [eax + sockaddr_in.sin_port], 0x983a ; htons(1500)

      ; Allow address reuse.
      push 1 ; true
      push 4 ; sizeof(int)
      lea eax, [esp + 4] ; address of the true
      push eax
      push sys_so_reuseaddr
      push sys_sol_socket
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

      ; Ignore the fate of children.
      mov eax, sys_signal
      mov ebx, sys_sigchild
      mov ecx, sys_sig_ign
      int 0x80

      cmp eax, -1
      je failed_to_bind_signal_handler

      listen_forever:
        push socket_somaxconn
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

        mov eax, sys_fork
        int 0x80

        test eax, eax
        jz _start_child

        _start_parent:
          ; The parent doesn't need the incoming socket.
          mov eax, sys_close
          mov ebx, [ebp - 8] ; incoming_socket
          int 0x80

          ; Forever…
          jmp listen_forever

        _start_child:
          ; The child doesn't need the listening socket.
          mov eax, sys_close
          mov ebx, [ebp - 4] ; listening_socket
          int 0x80

          mov eax, [ebp - 8] ; incoming_socket
          call http_process_request

          ; Close the client socket.
          mov eax, sys_close
          mov ebx, [ebp - 8] ; incoming_socket
          int 0x80
    add esp, 12

    mov eax, sys_exit
    xor ebx, ebx
    int 0x80

failed_to_create_socket:
  log_error str_failed_to_create_socket
  mov eax, 1
  jmp error_die

failed_to_bind_socket:
  log_error str_failed_to_bind_socket
  mov eax, 1
  jmp error_die

failed_to_bind_signal_handler:
  log_error str_failed_to_bind_signal_handler
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

get_working_directory:
  mov eax, sys_getcwd
  mov ebx, str_working_dir
  mov ecx, len_str_working_dir
  int 0x80
  ret
