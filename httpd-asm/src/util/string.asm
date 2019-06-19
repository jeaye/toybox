%include "data.extern.inc"

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
  ;   ecx = length of the source string, in bytes
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
  ;   ecx = length of the source string, in bytes
  ;   esi = address of the source, aligned to a dword
  ;   edi = address of the destination, aligned to a dword
  ; output:
  ;   edi
  global string_append
  string_append:
    ; Find the length of the destination string first.
    push ebp
      mov ebp, esp
      push ecx
        mov eax, edi
        call string_length
        add edi, ecx
      pop ecx

      ; Now copy the new string from the end.
      call string_copy
    pop ebp
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

        string_compare_not_equal:
          mov eax, 0
          jmp string_compare_end
        string_compare_equal:
          mov eax, 1
          jmp string_compare_end
  string_compare_end:
      add esp, 4
    pop ebp
    ret

  ; input:
  ;   eax = value to write
  ;   ecx = number of bytes to write
  ;   edi = address of the destination, aligned to a dword
  ; output:
  ;   edi
  global string_fill
  string_fill:
    ; Do as much as possible using dwords.
    push ecx
      shr ecx, 2
      rep stosd
    pop ecx
    ; Do everything else using bytes.
    and ecx, 3
    rep stosb
    ret

  ; input:
  ;   eax = unsigned value
  ;   ebx = base of output
  ; output:
  ;   ecx = length of value in chars
  global string_integer_length
  string_integer_length:
    ; TODO: This fn wouldn't be needed if string_from_integer used an in-place
    ; swap. Division isn't cheap.
    push ebp
      mov ebp, esp
      ; ebp - 4: unsigned value;
      push eax
        push edx
          xor ecx, ecx
          string_integer_length_loop:
            inc ecx
            xor edx, edx
            mov eax, [ebp - 4] ; value
            div ebx
            mov [ebp - 4], eax ; value

            test eax, eax
            jnz string_integer_length_loop
        pop edx
      pop eax
    pop ebp
    ret

  ; input:
  ;   eax = unsigned value to write
  ;   ebx = base of output
  ;   ecx = length of edi buffer
  ;   edi = address of the destination, aligned to a dword
  ; output:
  ;   edi = ascii version of value
  ;   ecx = length of string
  global string_from_integer
  string_from_integer:
    push ebp
      mov ebp, esp
      ; ebp - 4: unsigned value;
      push eax
        ; ebp - 8: unsigned base;
        push ebx
          ; ebp - 12: size_t length;
          push ecx
            ; Check how long the string needs to be.
            call string_integer_length
            cmp ecx, [ebp - 12] ; length
            jge string_from_integer_end
            mov [ebp - 12], ecx ; length

            ; Zero the end of the string first.
            lea ecx, [edi + ecx]
            mov dword [ecx], 0

            string_from_integer_loop:
              xor edx, edx
              mov eax, [ebp - 4] ; value
              mov ebx, [ebp - 8] ; base
              div ebx
              mov [ebp - 4], eax ; value

              mov byte bl, [str_base_chars + edx]
              dec ecx
              mov byte [ecx], bl

              test eax, eax
              jnz string_from_integer_loop

  string_from_integer_end:
          pop ecx
        pop ebx
      pop eax
    pop ebp
    ret
