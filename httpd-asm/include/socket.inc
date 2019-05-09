%ifndef socket_inc
  %define socket_inc

  %define AF_INET 0x2
  %define SOCK_STREAM 0x1
  %define IPPROTO_IP 0x0
  %define SOMAXCONN 128

  struc sockaddr_in
    .sin_family: resw 1
    .sin_port: resw 1
    .sin_addr: resd 1
    .sin_zero: resb 8
  endstruc
  %define sizeof_sockaddr_in 16
%endif
