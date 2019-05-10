%ifndef socket_inc
  %define socket_inc

  %define socket_af_inet 0x2
  %define socket_sock_stream 0x1
  %define socket_ipproto_ip 0x0
  %define socket_somaxconn 128

  struc sockaddr_in
    .sin_family: resw 1
    .sin_port: resw 1
    .sin_addr: resd 1
    .sin_zero: resb 8
  endstruc
  %define sizeof_sockaddr_in 16
%endif
