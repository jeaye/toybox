%if LOGGING
  %include "data.extern.inc"
  %include "sys.inc"
  %include "util/string.extern.inc"

  section .text
    ; eax = prefix to log
    ; ebx = string to log
    global log_line
    log_line:
      push ebp
        mov ebp, esp
        ; [ebp - 4]: char *prefix;
        ; [ebp - 8]: char *msg;
        ; [ebp - 16]: size_t prefix_length;
        sub esp, 16
          mov [ebp - 4], eax ; prefix
          mov [ebp - 8], ebx ; msg

          ; Log the prefix first.
          call string_length
          mov [ebp - 16], ecx ; prefix_length

          mov ecx, [ebp - 4] ; prefix
          mov eax, sys_write
          mov ebx, stdout
          mov edx, [ebp - 16] ; prefix_length
          int 0x80

          ; Now log the actual message.
          mov eax, [ebp - 8] ; msg
          call string_length
          mov [ebp - 16], ecx ; prefix_length

          mov eax, sys_write
          mov ebx, stdout
          mov ecx, [ebp - 8] ; msg
          mov edx, [ebp - 16] ; prefix_length
          int 0x80
        add esp, 16
      pop ebp
      ret
%endif
