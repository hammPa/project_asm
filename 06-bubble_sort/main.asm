section .data
    array db 90, 41, 10, 30, 50
    space db " ", 0

section .text
    global _start
    extern print_int
    extern newline
    extern print

_start:
    ; print array awal
    mov edx, 5
    mov eax, array
    call print_array
    call newline

    mov eax, array
    mov edx, 5
    call bubble_sort

    ; print array yang sudah terurut
    mov edx, 5
    mov eax, array
    call print_array
    call newline

    mov eax, 1
    xor ebx, ebx
    int 0x80


print_array:
    mov esi, eax
    xor ebx, ebx
    ; len di edx

.loop:
    cmp ebx, edx
    je .end
    
    push edx
    xor eax, eax
    push ebx
    
    movzx eax, byte[esi + ebx]
    call print_int              ; karna print int ada mengubah edi, maka pakai esi saja
    
    mov ecx, space
    call print

    pop ebx
    inc ebx
    pop edx
    jmp .loop


.end:
    ret





bubble_sort:
    mov edi, eax                ; pindahkan array ke edi
    mov esi, edx                ; pindahkan ukuran ke esi
    xor ecx, ecx                ; i = 0

.outer_loop:
    xor edx, edx                ; j = 0
    cmp ecx, esi                ; i < esi
    je .end_outer

    mov ebx, esi
    dec ebx
    
.inner_loop:
    cmp edx, ebx                ; j < esi - 1
    je .end_inner

    mov al, [edi + edx]
    mov ah, [edi + edx + 1]
    
    cmp al, ah
    jle .skip

    mov [edi + edx], ah
    mov [edi + edx + 1], al

.skip:
    inc edx
    jmp .inner_loop

.end_inner:
    inc ecx
    jmp .outer_loop

.end_outer:
    ret
