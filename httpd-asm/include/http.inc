%ifndef http_inc
  %define http_inc

  %define http_status_bad_request 400
  %define http_status_line_len 32

  %define max_http_method_length 8
  struc http_request_context
    .socket: resb 4
    .method: resb max_http_method_length
    .path: resb 1024
    .status_code: resb 4
  endstruc
  %define sizeof_http_request_context (4 + max_http_method_length + 1024 + 4)
%endif
