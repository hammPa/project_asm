section .data
    array db 1, 2, 3, 4, 5, 6

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

    ; PRINT value perindex
    ; Calculate the index in the 1D array as [ecx * 3 + edx]
    ; First, multiply ecx by 3 (each row has 3 columns)
    mov eax, ecx                ; eax = ecx
    imul eax, 3                 ; eax = ecx * 3
    add eax, edx                ; eax = ecx * 3 + edx

    ; Now eax holds the index in the 1D array
    mov al, [array + eax]       ; Load the value at the calculated index

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
