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
  ;   edi = address of the destination, aligned to a dword
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

  ; input:
  ;   esi = address of the first string
  ;   edi = address of the second string
  ; clobbers:
  ;   ecx, edx
  ; output:
  ;   eax = 1 if equal, 0 otherwise
  global string_compare
  string_compare:
    push ebp
      mov ebp, esp

      ; ebp - 4: size_t first_length;
      sub esp, 4
        mov eax, esi
        call string_length
        mov [ebp - 4], ecx ; first_length

        mov eax, edi
        call string_length

        mov eax, [ebp - 4] ; first_length
        cmp eax, ecx
        jne string_compare_not_equal

        ; ecx = length
        repe cmpsb
        jecxz string_compare_equal

        string_compare_equal:
          mov eax, 1
          jmp string_compare_end
        string_compare_not_equal:
          mov eax, 0
          jmp string_compare_end
  string_compare_end:
      add esp, 4
    pop ebp
    ret

  ; input:
  ;   eax = value to write
  ;   ecx = number of bytes to write
  ;   edi = address of the destination, aligned to a dword
  global string_fill
  string_fill:
    ; Do as much as possible using dwords.
    push ecx
      shr ecx, 2
      rep stosb
    pop ecx
    ; Do everything else using bytes.
    and ecx, 3
    rep stosb
    ret
