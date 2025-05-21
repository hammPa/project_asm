; untuk algoritma algoritma pindahkan ke file masing masing, misal aray ke array, linkedlist ke linkedlist, jangan digabung, tapi buat mereka support ke final stdio

; keknya lebih baik menetapkan ukuran:
; char 1 byte
; float, int 4 byte

section .data
    msg db "hello", 0
    nwln db 0xA, 0

section .bss
    buffer_itoa resb 11

section .text
    global newline
    global strlen
    global print_str
    global itoa
    global print_int
    global alloc
    global dealloc





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





; ======================================== STRCMP ========================================
strcmp:
    push ebp
    mov ebp, esp
    push esi
    push edi

    mov esi, [ebp + 12]                     ; arg 1
    mov edi, [ebp + 8]                      ; arg 2
    xor eax, eax

.compare:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .not_equal                                  ; tidak sama

    test al, al                                     ; apakah sudah  \0
    jz .equal                                      ; sama

    inc esi
    inc edi
    jmp .compare

.not_equal:
    movzx eax, al
    movzx ebx, bl
    sub eax, ebx                                    ; s1[i] - s2[i]
    jmp .exit_cmp

.equal:
    xor eax, eax

.exit_cmp:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
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









; ======================================== SCAN_STR ========================================
scan_str:
    push ebp
    mov ebp, esp
    push esi

    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp + 12]                             ; variabel
    mov edx, [ebp + 8]                              ; len
    int 0x80

    ; cek apakah ukuran 0, karna ukuran akan disimpan di eax
    test eax, eax
    jle .exit_scan_str

    mov esi, ecx
    add esi, eax
    dec esi                                         ; akhir buffer, cari \n, ubah jadi \0

    cmp byte [esi], 0xA
    jne .exit_scan_str
    mov byte [esi], 0

.exit_scan_str:
    pop esi
    mov esp, ebp
    pop ebp
    ret



; ======================================== STOI ========================================
stoi:
    push ebp
    mov ebp, esp
    push esi

    xor edx, edx
    xor ecx, ecx
    mov esi, [ebp + 8]
    
.loop_stoi:
    mov al, [esi + ecx]
    cmp al, 0
    je .exit_stoi

    sub al, '0'
    imul edx, edx, 10
    add edx, eax                                 ; edx = edx * 10 + al
    
    inc ecx
    jmp .loop_stoi

.exit_stoi:
    mov eax, edx
    pop esi
    mov esp, ebp
    pop ebp
    ret




; ======================================== SCAN_INT ========================================
scan_int:
    push ebp
    mov ebp, esp

    ; input string
    push buffer_itoa
    push 11
    call scan_str
    add esp, 8                                      ; untuk menghapus 2 args

    ; stack :
    ; new new ebp
    ; return scan str
    ; push len (disini 11)
    ; push buffer itoa (untuk buffer str)
    ; new ebp
    ; return scan int
    ; addr angka



    ; stoi
    ; ubah ke angka, hasil di eax
    ; karna hasil buffer_itoa di ecx, langsung push saja
    push ecx
    call stoi
    add esp, 4                                      ; menghapus 1 args, hasil di eax
    

    ; stack :
    ; new new ebp
    ; return scan stoi
    ; push buffer itoa (untuk buffer str)
    ; new ebp
    ; return scan int
    ; addr angka


    mov [ebp + 8], eax                             ; pindahkan nilai di eax ke alamat variabel int

    mov esp, ebp
    pop ebp
    ret






; ======================================== STRCPY ========================================
strcpy:
    push ebp
    mov ebp, esp
    push esi
    push edi

    mov esi, [ebp + 12]                 ; arg 1 : destination
    mov edi, [ebp + 8]                  ; source

.loop_cpy:
    mov al, [edi]                       ; ambil perhuruf
    cmp al, 0
    je .exit_cpy

    mov [esi], al

    inc esi
    inc edi
    jmp .loop_cpy

.exit_cpy:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
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




