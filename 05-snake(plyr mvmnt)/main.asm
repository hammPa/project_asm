section .data
    hor_line db "-"
    ver_line db "|"
    newline_char db 0xA
    space_char db " "
    ask db "Masukkan input: ", 0
    x db "x: ", 0
    y db "y: ", 0

    clear_screen db 0x1B, '[', '2', 'J', 0x1B, '[', 'H'

section .bss
    MAP resb 210                            ; 10 baris, 11 kolom (ke11 untuk newline), yang terakhir untuk 0
    user_input resb 3
    playerPos resb 2

section .text
    global _start
    extern print_int
    extern print
    extern newline
    extern scan

_start:
    mov byte [playerPos], 2                 ; column
    mov byte [playerPos + 1], 5             ; row

game_loop:
    ; debugging print x dan y
    ; print posisi x
    mov ecx, x
    call print
    movzx eax, byte [playerPos]             ; ambil nilai x sebagai 1 byte dan convert ke 4 byte 
    call print_int
    call newline

    ; print posisi y
    mov ecx, y
    call print
    movzx eax, byte [playerPos + 1]
    call print_int
    call newline

    call initiate_map
    call player
    call render

    ; input handling
    mov ecx, ask
    call print
    mov ecx, user_input
    call scan

    cmp ecx, 'q'
    je exit
    
    call move

    mov ecx, clear_screen
    call print

    jmp game_loop

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80






initiate_map:
    xor ecx, ecx                            ; i = 0

.outer_loop:
    cmp ecx, 10                             ; i < 10
    jge .end_outer
    
    xor edx, edx                            ; j = 0

.inner_loop:
    cmp edx, 21                             ; j < 21
    jge .end_inner

    push ecx
    push edx

    mov eax, ecx                            ; eax = ecx * 21 + edx
    imul eax, 21
    add eax, edx

    cmp edx, 20                             ; newline
    je .insert_newline

    ; jika baris pertama atau terakhir
    cmp ecx, 0
    je .insert_hline
    cmp ecx, 9
    je .insert_hline

    ; jika kolom pertama atau terakhir
    cmp edx, 0
    je .insert_vline
    cmp edx, 19
    je .insert_vline

    ; selain itu isi spasi
    mov dl, [space_char]
    mov [MAP + eax], dl
    jmp .continue

.insert_newline:
    mov dl, [newline_char]
    mov [MAP + eax], dl
    jmp .continue

.insert_hline:
    mov dl, [hor_line]
    mov [MAP + eax], dl
    jmp .continue

.insert_vline:
    mov dl, [ver_line]
    mov [MAP + eax], dl
    jmp .continue

.continue:
    pop edx
    pop ecx

    inc edx
    jmp .inner_loop

.end_inner:
    inc ecx
    jmp .outer_loop

.end_outer:
    mov byte[MAP + 210], 0
    ret



player:
    mov esi, MAP
    mov edi, playerPos

    movzx ecx, byte [edi]           ; ambil nilai posisi x
    movzx edx, byte [edi + 1]       ; ambil nilai posisi y

    mov eax, edx
    imul eax, 21
    add eax, ecx

    mov byte [MAP + eax], '*'    
    ret



move:
    movzx eax, byte [user_input]
    cmp al, 'a'
    je .left

    cmp al, 's'
    je .down

    cmp al, 'w'
    je .top

    cmp al, 'd'
    je .right

    ret                             ; jika tidak ada

.left:
    movzx ebx, byte [playerPos]
    cmp ebx, 1                      ; Batas kiri
    jle .exit
    dec ebx
    mov [playerPos], bl
    jmp .exit

.right:
    movzx ebx, byte [playerPos]
    cmp ebx, 18                     ; Batas kanan
    jge .exit
    inc ebx
    mov [playerPos], bl
    jmp .exit

.top:
    movzx ebx, byte [playerPos + 1]
    cmp ebx, 1                      ; Batas atas
    jle .exit
    dec ebx
    mov [playerPos + 1], bl
    jmp .exit

.down:
    movzx ebx, byte [playerPos + 1]
    cmp ebx, 8                      ; Batas bawah
    jge .exit
    inc ebx
    mov [playerPos + 1], bl

.exit:
    ret


render:
    mov ecx, MAP                    ; Alamat MAP
    call print
    ret

