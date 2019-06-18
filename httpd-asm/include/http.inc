%ifndef http_inc
  %define http_inc

  %define http_status_bad_request 400
  %define http_response_line_len 32

  %define max_http_method_length 8
  %define max_http_path_length 1024
  struc http_request_context
    .socket: resb 4
    .method: resb max_http_method_length
    .path: resb max_http_path_length
    .resource_file: resb 4
    .resource_file_len: resb 4
    .status_code: resb 4
  endstruc
  %define sizeof_http_request_context (4 + max_http_method_length + max_http_path_length + 4 + 4 + 4)
%endif
