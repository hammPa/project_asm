section .data
    addr db "Alamat: ", 0
    val db ",  Nilainya: ", 0

section .bss
    address1 resd 1
    address2 resd 1
    address3 resd 1

section .text
    global _start
    extern print
    extern print_int
    extern newline
    extern scan

_start:
    ;|============================================================================================
    ;|                                                                                           |
    ;|                                     ALOKASI MEMORI                                        |
    ;|                                                                                           |
    ;|============================================================================================
    mov eax, 192         ; syscall number 192 - mmap2 (pemetaan memori/file)
    xor ebx, ebx         ; ebx = 0, alamat NULL -> biarkan kernel memilih alamat
    mov ecx, 4           ; ecx = 4, ukuran memori yang akan dialokasikan (4 byte)
    mov edx, 0x3         ; edx = 0x3, proteksi PROT_READ | PROT_WRITE
    mov esi, 0x22        ; esi = 0x22, flag MAP_PRIVATE | MAP_ANONYMOUS
    mov edi, -1          ; edi = -1, file descriptor -1 karena MAP_ANONYMOUS
    xor ebp, ebp         ; ebp = 0, offset file = 0
    int 0x80             ; panggil interrupt untuk menjalankan syscall

    ; hasil alokasi terletak di eax
    mov [eax], dword 1234
    mov [address1], eax

    push eax
    mov ecx, addr
    call print
    pop eax
    
    push eax
    call print_int
    mov ecx, val
    call print
    pop eax
    
    mov eax, [eax]
    call print_int
    call newline




    mov eax, 192         ; syscall number 192 - mmap2 (pemetaan memori/file)
    xor ebx, ebx         ; ebx = 0, alamat NULL -> biarkan kernel memilih alamat
    mov ecx, 4           ; ecx = 4, ukuran memori yang akan dialokasikan (4 byte)
    mov edx, 0x3         ; edx = 0x3, proteksi PROT_READ | PROT_WRITE
    mov esi, 0x22        ; esi = 0x22, flag MAP_PRIVATE | MAP_ANONYMOUS
    mov edi, -1          ; edi = -1, file descriptor -1 karena MAP_ANONYMOUS
    xor ebp, ebp         ; ebp = 0, offset file = 0
    int 0x80             ; panggil interrupt untuk menjalankan syscall

    ; hasil alokasi terletak di eax
    mov [eax], dword 9876
    mov [address2], eax

    push eax
    mov ecx, addr
    call print
    pop eax

    push eax
    call print_int
    mov ecx, val
    call print
    pop eax

    mov eax, [eax]
    call print_int
    call newline







    mov eax, 192         ; syscall number 192 - mmap2 (pemetaan memori/file)
    xor ebx, ebx         ; ebx = 0, alamat NULL -> biarkan kernel memilih alamat
    mov ecx, 4           ; ecx = 4, ukuran memori yang akan dialokasikan (4 byte)
    mov edx, 0x3         ; edx = 0x3, proteksi PROT_READ | PROT_WRITE
    mov esi, 0x22        ; esi = 0x22, flag MAP_PRIVATE | MAP_ANONYMOUS
    mov edi, -1          ; edi = -1, file descriptor -1 karena MAP_ANONYMOUS
    xor ebp, ebp         ; ebp = 0, offset file = 0
    int 0x80             ; panggil interrupt untuk menjalankan syscall

    ; hasil alokasi terletak di eax
    mov [eax], dword 4532
    mov [address3], eax

    push eax
    mov ecx, addr
    call print
    pop eax

    push eax
    call print_int
    mov ecx, val
    call print
    pop eax

    mov eax, [eax]
    call print_int
    call newline








    ;|============================================================================================
    ;|                                                                                           |
    ;|                                     DEALOKASI MEMORI                                      |
    ;|                                                                                           |
    ;|============================================================================================


    mov eax, 91
    mov ebx, [address1]
    mov ecx, 4
    int 0x80




    mov eax, 91
    mov ebx, [address2]
    mov ecx, 4
    int 0x80



    mov eax, 91
    mov ebx, [address3]
    mov ecx, 4
    int 0x80



    ;  TES SALAH SATU MEMORI APA SUDAH DI DEALOKASI, KALAU SEGMENTATION FAULT BERARTI BISA
    mov eax, [address1]
    mov eax, [eax]
    call print_int


    mov eax, 1
    xor ebx, ebx
    int 0x80
