global string_length

section .text
  ; input:
  ;   eax = char *str;
  ; clobbers:
  ;   ecx, edx
  ; ret:
  ;   length in eax
  string_length:
    xor ecx, ecx

    test_char:
      mov byte dl, [eax]
      test dl, dl
      jz found_null
      inc eax
      inc ecx
      jmp test_char

    found_null:
      ret
