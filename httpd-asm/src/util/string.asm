section .text
  ; input:
  ;   eax = char *str;
  ; clobbers:
  ;   ecx, edx
  ; ret:
  ;   ecx = length
  global string_length
  string_length:
    xor ecx, ecx

    string_length_test_char:
      mov byte dl, [eax]
      test dl, dl
      jz string_length_found_null
      inc eax
      inc ecx
      jmp string_length_test_char

    string_length_found_null:
      ret

  ; input:
  ;   eax = char *str;
  ;   ebx = char search_term;
  ; clobbers:
  ;   ecx, edx
  ; ret:
  ;   ecx = offset of first occurrence or -1 if not found
  global string_find_first
  string_find_first:
    xor ecx, ecx

    string_find_first_test_char:
      mov byte dl, [eax]

      ; Check for the end of the string.
      test dl, dl
      jz string_find_first_found_null

      ; Check for the match.
      cmp dl, bl
      je string_find_first_found_char

      inc eax
      inc ecx
      jmp string_find_first_test_char

    string_find_first_found_char:
      ret
    string_find_first_found_null:
      ret

  ; input:
  ;   ecx = length of the string in bytes
  ;   esi = address of the source, aligned to a dword
  ;   edi = address of the destination aligned to a dword
  global string_copy
  string_copy:
    ; Move as much as possible using dwords.
    push ecx
      shr ecx, 2
      rep movsd
    pop ecx
    ; Move everything else using bytes.
    and ecx, 3
    rep movsb
    ret
