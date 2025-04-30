section .data
    text db "Hello World", 0

    char1 db "oi", 0
    char2 db "oi", 0

section .text
    global _start
    extern print
    extern print_int
    extern scan
    extern newline

_start:
    mov ecx, text                           ; alamat string "Hello World" di eax
    call strlen                             ; panggil fungsi strlen untuk menghitung panjang
    mov eax, ecx                            ; pindahkan ke eax agar bisa di print
    call print_int                          ; print panjang string
    call newline

    mov eax, char1
    mov ebx, char2
    call strcmp                             ; hasil compare di eax, jadi langsung panggil print
    call print_int
    call newline

    ; membandingkan kegunaan movzx dan movsx
    mov al, -1
    movzx eax, al
    call print_int
    call newline

    mov al, -1
    movsx eax, al
    call print_int                          ; hasilnya ada 2, bisa 4294967295 atau -1
    call newline

    ; exit
    mov eax, 1                              ; kode keluar dari sistem
    xor ebx, ebx                            ; status keluar 0
    int 0x80



; Fungsi strlen untuk menghitung panjang string
strlen:
    mov edi, ecx                            ; pindahkan alamat string ke edi
    xor ecx, ecx                            ; set counter ecx ke 0

.loop_len:
    cmp byte [edi + ecx], 0                 ; bandingkan byte pada posisi ecx dengan null terminator (0)
    je .exit                                ; jika null terminator, keluar dari loop
    inc ecx                                 ; increment counter
    jmp .loop_len                           ; ulangi perulangan

.exit:
    ; hasil panjang string ada di ecx, pindahkan ke eax
    ret


; fungsi compare string, kalau 0 berarti sama
strcmp:
    mov edi, eax
    mov esi, ebx

.loop_cmp:
    mov al, [edi]
    mov bl, [esi]
    cmp al, bl
    jne .exit

    test al, al
    je .equal

    inc edi
    inc esi
    jmp .loop_cmp

.equal:
    xor eax, eax                            ; return 0 / sama
    ret

.exit:
    ; konversi ke int 
    ; movzx bikin hasil 8-bit jadi 32-bit tanpa merusak nilai
    ;Di C/C++, ini seperti casting implisit dari char ke int
    movzx eax, al
    movzx ebx, bl
    sub eax, ebx
    ret
