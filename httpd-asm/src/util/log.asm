%include "./data.inc"

extern printf

global log_debug_impl

section .text
  ; eax = string to log
  log_debug_impl:
    push eax
      ; Log the prefix first.
      sub esp, 4
        mov eax, debug_log_prefix_str
        mov [esp], eax
        call printf
      add esp, 4
    pop eax

    ; Now log the string.
    sub esp, 4
      mov [esp], eax
      call printf
    add esp, 4
    ret
