%include "data.inc"
%include "sys.inc"
%include "util/log.inc"

global error_failed_allocation
global error_die

section .text
  error_failed_allocation:
    log_error str_failed_to_allocate_memory
    mov eax, 1
    jmp error_die

  ; eax = status code
  error_die:
    mov ebx, eax
    mov eax, sys_exit
    int 0x80
