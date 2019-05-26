%ifndef sys_inc
  %define sys_inc

  %define sys_exit 0x1
  %define sys_write 0x4
  %define sys_open 0x5
  %define sys_close 0x6
  %define sys_lseek 0x13
  %define sys_access 0x21
  %define sys_socketcall 0x66
  %define sys_sendfile 0xbb

  %define sys_socketcall_socket 1
  %define sys_socketcall_bind 2
  %define sys_socketcall_connect	3
  %define sys_socketcall_listen 4
  %define sys_socketcall_accept 5
  %define sys_socketcall_send 9
  %define sys_socketcall_recv 10
  %define sys_socketcall_setsockopt 14

  %define sys_sol_socket 1
  %define sys_so_reuseaddr 2

  %define sys_r_ok 4

  %define sys_seek_set 0
  %define sys_seek_end 2

  %define stdout 1
  %define stderr 2
%endif
