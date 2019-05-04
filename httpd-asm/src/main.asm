global main

extern printf

section .data
  fmt_str:  db 'hello, world',0xA,0

section .text
main:
  sub esp, 4
  lea eax, [fmt_str]
  mov [esp], eax
  call printf
  add esp, 4

  ret
