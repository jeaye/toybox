%ifndef data_inc
  %define data_inc

  %define null 0x0
  %define cr 0xD
  %define lf 0xA
  %define space 0x20

  %macro str_green 2
    global %1
    %1: db 0x1b,0x5b,0x33,0x32,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro
  %macro str_orange 2
    global %1
    %1: db 0x1b,0x5b,0x39,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro
  %macro str_red 2
    global %1
    %1: db 0x1b,0x5b,0x33,0x31,0x6d,%2,0x1b,0x5b,0x6d,0x0f,null
  %endmacro

  %macro def_str 2+
    global str_%1
    str_%1: db %2,null
    global len_str_%1
    len_str_%1: equ $ - str_%1 - 1 ; Always decrement for the null.
  %endmacro

  %macro def_extern_str 1
    extern str_%1
    extern len_str_%1
  %endmacro
%endif
