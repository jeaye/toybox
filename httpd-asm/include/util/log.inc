%ifndef log_inc
  %define log_inc

  %macro log_debug 1
    %if (DEBUG && LOGGING)
      ; We use this internally, so save it.
      push eax
        push ebx
          mov eax, str_debug_log_prefix
          mov ebx, %1
          call log_line
        pop ebx
      pop eax
    %endif
  %endmacro

  %macro log_error 1
    %if LOGGING
      ; We use this internally, so save it.
      push eax
        push ebx
          mov eax, str_error_log_prefix
          mov ebx, %1
          call log_line
        pop ebx
      pop eax
    %endif
  %endmacro
%endif
