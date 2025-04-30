section .data


section .text
    global _start
    extern print_int
    extern print
    extern newline
    
_start:
    xor ecx, ecx                ; outer loop counter, i = 0
.outer_loop:
    cmp ecx, 2                  ; if ecx >= 2
    jge .end_program

    xor edx, edx                ; inner loop counter, j = 0
.inner_loop:
    cmp edx, 3                  ; if edx >= 3
    jge .end_inner

    push ecx                    ; simpan ecx (i)
    push edx                    ; simpan edx (j)

    ; PRINT i
    mov eax, ecx
    call print_int

    ; PRINT j
    pop edx                     ; restore edx (j)
    push edx                    ; simpan lagi edx (j)
    mov eax, edx
    call print_int

    call newline

    pop edx                     ; restore edx (j)
    pop ecx

    inc edx
    jmp .inner_loop

.end_inner:
    inc ecx
    jmp .outer_loop

.end_program:
    ; exit syscall
    mov eax, 1
    xor ebx, ebx
    int 0x80
