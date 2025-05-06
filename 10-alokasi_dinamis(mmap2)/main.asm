section .data
    addr db "Alamat: ", 0
    val db ",  Nilainya: ", 0

section .text
    global _start
    extern print
    extern print_int
    extern newline
    extern scan

_start:
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




    mov eax, 1
    xor ebx, ebx
    int 0x80
