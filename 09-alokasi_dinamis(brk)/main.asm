section .data
    newline db 0xA

section .text
    global _start

_start:
    ; ambil program break saat ini (NULL argument), hasil di eax
    mov eax, 45
    xor ebx, ebx    ; arg = NULL
    int 0x80
    mov esi, eax    ; simpan break awal ke esi

    ; tambah heap 6 bytes
    add eax, 6
    mov ebx, eax    ; naikkan argument baru untuk brk (end heap yang di inginkan)
    mov eax, 45
    int 0x80
    cmp eax, ebx
    jne .fail

    mov byte [esi], 'H'
    mov byte [esi + 1], 'e'
    mov byte [esi + 2], 'l'
    mov byte [esi + 3], 'l'
    mov byte [esi + 4], 'o'
    mov byte [esi + 5], 0

    mov ecx, esi
    mov edx, 6
    mov ebx, 1
    mov eax, 4
    int 0x80


    ; bersihkan
    mov byte [esi], 0
    mov byte [esi + 1], 0
    mov byte [esi + 2], 0
    mov byte [esi + 3], 0
    mov byte [esi + 4], 0
    mov byte [esi + 5], 0

    ; kuranig offset
    sub eax, 6
    mov ebx, eax
    mov eax, 45
    int 0x80
    mov esi, eax

    ; coba tampilkan (harusnya tidak tampil)
    mov ecx, esi
    mov edx, 6
    mov ebx, 1
    mov eax, 4
    int 0x80
.fail:
    mov eax, 1
    xor ebx, ebx
    int 0x80
