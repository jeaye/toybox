%ifndef sys_inc
  %define sys_inc

  %define sys_exit 0x1
  %define sys_write 0x4
  %define sys_open 0x5
  %define sys_close 0x6
  %define sys_socketcall 0x66
  %define sys_getcwd 0xb7
  %define sys_sendfile 0xbb
  %define sys_fstat64 0xc5

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

  ;struc stat
  ;  .st_dev resq 1
  ;  .__pad1 resb 2
  ;  .st_ino resd 1
  ;  .st_mode resd 1
  ;  .st_nlink resd 1
  ;  .st_uid resd 1
  ;  .st_gid resd 1
  ;  .st_rdev resq 1
  ;  .st_size resd 1
  ;  .st_blksize resd 1
  ;  .st_blocks resd 1
  ;  .st_atime resd 1
  ;  .st_atime_nsec resd 1
  ;  .st_mtime resd 1
  ;  .st_mtime_nsec resd 1
  ;  .st_ctime resd 1
  ;  .st_ctime_nsec resd 1
  ;endstruc
  ;%define sizeof_stat 88

  struc stat
   .st_dev resq 1
   .st_ino resd 1
   .st_nlink resd 1
   .st_mode resd 1
   .pad0 resb 8
   .st_uid resd 1
   .st_gid resd 1
   .st_rdev resq 1
   .st_size resq 1
   .st_blksize resq 1
   .st_blocks resq 1
   .st_atime resq 1
   .st_atime_nsec resq 1
   .st_mtime resq 1
   .st_mtime_nsec resq 1
   .st_ctime resq 1
   .st_ctime_nsec resq 1
   .st_unused resb 24
  endstruc
  %define sizeof_stat 144
%endif
