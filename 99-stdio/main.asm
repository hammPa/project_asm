; untuk algoritma algoritma pindahkan ke file masing masing, misal aray ke array, linkedlist ke linkedlist, jangan digabung, tapi buat mereka support ke final stdio

; keknya lebih baik menetapkan ukuran:
; char 1 byte
; float, int 4 byte

section .data
    msg db "hello", 0
    nwln db 0xA, 0

section .bss
    buffer_itoa resb 11
    angka1 resd 1

section .text
    global _start

_start:
    mov ecx, msg
    call print_str

    push 100
    call print_int
    add esp, 4              ; pop manual untuk menghapus push
    call newline



    mov ecx, msg
    call print_str
    call newline



    push 4
    call alloc
    add esp, 4

    mov [angka1], eax
    mov [angka1], dword 7432
    mov eax, [angka1]
    
    push eax
    call print_int
    add esp, 4
    call newline


    push angka1
    push 4

    call dealloc            ; nilai dealloc belum diset 0
    add esp, 8

mov eax, [angka1]
    
    push eax
    call print_int
    add esp, 4
    call newline


.exit_start:
    mov eax, 1
    xor ebx, ebx
    int 0x80





; ======================================== NEWLINE ========================================
newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, nwln
    mov edx, 1
    int 0x80
    ret


; ======================================== STRLEN ========================================
strlen:
    push esi
    xor edx, edx
    mov esi, [esp + 8]          ; kalau esp + 4  itu untuk esi, makanya pakai 8, ingat esp letaknya dipaling atas stack

.search_len:
    mov al, byte [esi + edx]
    cmp al, 0
    je .exit_len

    inc edx
    jmp .search_len

.exit_len:
    pop esi
    ret



; ======================================== PRINT STR ========================================
print_str:
    push ecx
    call strlen
    pop ecx

    mov eax, 4
    mov ebx, 1
    int 0x80
    ret





; ======================================== ITOA ========================================
itoa:
    push ebp
    mov ebp, esp
    push esi

    mov esi, 9
    mov eax,[ebp + 8]                      ; ebp + 8 untuk parameter pertama karena ebp + 4 return address
    mov ebx, 10

    mov [buffer_itoa + 11], byte 0

.loop_itoa:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [buffer_itoa + esi], dl

    dec esi
    cmp eax, 0
    jne .loop_itoa

    inc esi
    lea eax, [buffer_itoa + esi]            ; menunjuk ke alamat awal string

    pop esi
    mov esp, ebp
    pop ebp
    ret






; ======================================== PRINT INT ========================================
print_int:
    mov eax, [esp + 4]                      ; Ambil parameter dari stack, soalnya esp saat pemanggilan print int itu menunjuk ke return address print int
    push eax                                ; Siapkan parameter untuk itoa
    call itoa
    add esp, 4                              ; Bersihkan stack dari parameter untuk itoa
    mov ecx, eax
    call print_str
    ret












; ======================================== ALLOC ========================================
alloc:
    push ebp
    mov ebp, esp

    mov eax, 192
    xor ebx, ebx
    mov ecx, [ebp + 8]
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    int 0x80

    mov esp, ebp
    pop ebp
    ret



; ======================================== DEALLOC ========================================
dealloc:
    push ebp
    mov ebp, esp

    mov eax, 91
    mov ebx, [ebp + 8]
    mov ecx, [ebp + 12]
    int 0x80

    mov esp, ebp
    pop ebp
    ret
