%include "data.extern.inc"
%include "sys.inc"
%include "util/log.inc"
%include "util/log.extern.inc"

section .text
  global error_failed_allocation
  error_failed_allocation:
    log_error str_failed_to_allocate_memory
    mov eax, 1
    jmp error_die

  ; eax = status code
  global error_die
  error_die:
    mov ebx, eax
    mov eax, sys_exit
    int 0x80
