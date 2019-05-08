%include "data.inc"

extern printf

global log_line

section .text
  ; eax = prefix to log
  ; ebx = string to log
  log_line:
    sub esp, 4
      ; Log the prefix first.
      mov [esp], eax
      call printf

      ; Now log the string.
      mov [esp], ebx
      call printf
    add esp, 4
    ret
