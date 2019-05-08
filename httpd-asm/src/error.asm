%include "data.inc"
%include "util/log.inc"

extern exit

global error_failed_allocation
global error_die

section .text
  error_failed_allocation:
    log_error str_failed_to_allocate_memory
    mov eax, 1
    jmp error_die

  ; eax = status code
  error_die:
    push eax
    call exit
