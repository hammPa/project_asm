section .data
    array db 90, 30, 11, 60, 40
    len equ $ - array
    displayArray db "Isi array: 90, 30, 11, 60, 40", 0xA, 0
    askInput db "Masukkan angka yang ingin di cari: ", 0
    result db "Ditemukan pada index ke-", 0

section .bss
    input resb 10

section .text
    global _start
    extern print
    extern print_int
    extern scan
    extern newline

_start:
    mov ecx, displayArray
    call print

    ; input angka sebagai string lalu ubah ke int
    mov ecx, askInput
    call print
    mov ecx, input
    call scan
    call string_to_int

    push eax             ; angka yang dicari masuk ke stack
    mov ecx, result
    call print

    pop eax              ; ambil dari stack
    mov ebx, eax
    mov eax, array
    call linear_search   ; hasil index ada di eax
    call print_int
    call newline

    mov eax, 1
    xor ebx, ebx
    int 0x80


; INPUT:
; eax = alamat array
; ebx = angka yang dicari
linear_search:
    xor ecx, ecx         ; index = 0

.loop:
    cmp ecx, len
    je .exit             ; kalau sudah habis, keluar dengan -1

    mov dl, [eax + ecx]  ; ambil array[ecx] ke dl
    cmp dl, bl           ; bandingkan dengan angka dicari
    je .found

    inc ecx
    jmp .loop

.found:
    mov eax, ecx         ; ketemu, kembalikan index di eax
    ret

.exit:
    mov eax, -1          ; tidak ketemu
    ret



; ecx = alamat string angka
; hasil di eax

string_to_int:
    xor eax, eax        ; result = 0
    xor edx, edx        ; edx untuk sementara simpan digit

.loop:
    mov dl, [ecx]       ; ambil 1 karakter dari string
    cmp dl, 0           ; cek null-terminator
    je .done            ; kalau habis, selesai

    sub dl, '0'         ; konversi ASCII ke angka
    imul eax, eax, 10   ; result *= 10
    add eax, edx        ; result += digit baru

    inc ecx             ; maju ke karakter berikutnya
    jmp .loop

.done:
    ret
