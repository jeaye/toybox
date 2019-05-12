%ifndef http_inc
  %define http_inc

  %define max_http_method_length 8
  struc http_request
    .socket: resb 4
    .method: resb max_http_method_length
    .path: resb 1024
  endstruc
  %define sizeof_http_request (4 + max_http_method_length + 1024)
%endif
