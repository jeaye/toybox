extern log_debug_impl

%define color_orange 

%macro log_debug 1
  %if DEBUG
    push eax ; We use this internally, so save it.
      mov eax, %1
      call log_debug_impl
    pop eax
  %endif
%endmacro
