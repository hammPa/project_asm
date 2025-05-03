section .data
    size dd 8
    space db " ", 0
    newline db 0xA, 0
    minusSign db "-", 0
    arrow db "-->", 0
    NULL db "NULL", 0

section .bss
    node1 resd 2                        ; struct Node* node1
    node2 resd 2                        ; struct Node* node1
    node3 resd 2                        ; struct Node* node3
    node4 resd 2                        ; struct Node* node4
    WORD_BUFFER_INT resd 6          ; buffer print int berukuran 4 byte, 5 angka, 1 null

section .text
    global _start

_start:
    ; alokasi memori unutk node1
    mov eax, 192
    xor ebx, ebx
    mov ecx, [size]
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    xor ebp, ebp
    int 0x80

    mov [node1], eax                     ; node = malloc(8) 
    mov dword [eax], 12                        ; node->value
    mov dword [eax + 4], 0                     ; node->next = NULL

    ; alokasi memori unutk node2
    mov eax, 192
    xor ebx, ebx
    mov ecx, [size]
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    xor ebp, ebp
    int 0x80

    mov [node2], eax                     ; node = malloc(8) 
    mov dword [eax], 34                        ; node->value
    mov dword [eax + 4], 0                     ; node->next = NULL

    ; alokasi memori unutk node3
    mov eax, 192
    xor ebx, ebx
    mov ecx, [size]
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    xor ebp, ebp
    int 0x80

    mov [node3], eax                     ; node = malloc(8) 
    mov dword [eax], 56                        ; node->value
    mov dword [eax + 4], 0                     ; node->next = NULL

    ; alokasi memori unutk node4
    mov eax, 192
    xor ebx, ebx
    mov ecx, [size]
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    xor ebp, ebp
    int 0x80

    mov [node4], eax                     ; node = malloc(8) 
    mov dword [eax], 78                        ; node->value
    mov dword [eax + 4], 0                     ; node->next = NULL



    ; hubungkan node
    mov eax, [node1]                      ; temp = node1
    mov ebx, [node2]
    mov dword [eax + 4], ebx              ; temp->next = node2

    mov eax, [node2]                      ; temp = node2
    mov ebx, [node3]
    mov dword [eax + 4], ebx              ; temp->next = node3

    mov eax, [node3]                      ; temp = node3
    mov ebx, [node4]
    mov dword [eax + 4], ebx              ; temp->next = node4


    ; tampilkan
    mov ebx, [node1]
.loop:
    cmp ebx, 0
    je .exit_loop

    mov eax, [ebx]
    
    push eax
    push ebx

    call print_dword_int

    mov ecx, space
    call print
    
    mov ecx, arrow
    call print

    mov ecx, space
    call print

    pop ebx
    pop eax

    mov ebx, [ebx + 4]
    jmp .loop

.exit_loop:
    mov ecx, NULL
    call print    

.done:
    mov eax, 1
    xor ebx, ebx
    int 0x80







; ================================================
; strlen - Menghitung panjang string null-terminated
; 
; Input:
;   ecx - Alamat string (pointer ke awal string)
;
; Output:
;   edx - Panjang string (tidak termasuk null terminator)
; 
; Register yang dimodifikasi:
;   edx, al (eax)
; ================================================
strlen:
    xor edx, edx                    ; Inisialisasi counter panjang ke 0

.find_length:
    mov al, byte [ecx + edx]        ; Ambil karakter saat ini
    cmp al, 0                       ; Cek apakah karakter null terminator?
    je .exit                        ; Jika ya, keluar dari loop
    
    inc edx                         ; Increment counter panjang
    jmp .find_length                ; Lanjut ke karakter berikutnya

.exit:
    ret                             ; Kembali dengan panjang di edx




; ================================================
; print - Mencetak string ke output standar (stdout)
;
; Input:
;   ecx - Alamat string yang akan dicetak
;
; Register yang dimodifikasi:
;   eax, ebx, edx (melalui syscall)
; 
; Catatan:
;   Menggunakan syscall write (4) dengan:
;   - fd = 1 (stdout)
;   - Panjang string dihitung dengan strlen
; ================================================
print:
    xor edx, edx                    ; Bersihkan edx sebelum panggil strlen
    call strlen                     ; Hitung panjang string (hasil di edx)

.exit:
    mov eax, 4                      ; Syscall write
    mov ebx, 1                      ; File descriptor stdout (1)
    int 0x80                        ; Panggil kernel
    ret                             ; Kembali ke pemanggil







; ================================================================
; int_to_string_word - Konversi 32-bit integer (EAX) ke string ASCII
;
; Input:
;   EAX - Nilai integer 32-bit yang akan dikonversi (bertanda/signed)
;
; Output:
;   EDI - Pointer ke awal string hasil konversi
;   EDX - Panjang string hasil (tidak termasuk null terminator)
;
; Register yang dimodifikasi:
;   EAX, EDX, EDI, EBX
;
; Buffer yang digunakan:
;   WORD_BUFFER_INT - Buffer 6 byte (5 digit + null terminator)
; ================================================================
int_to_string_word:
    test eax, eax                      ; Cek tanda nilai input
    jns .positive                   ; Jika positif, lompat ke konversi
    
    ; Handle nilai negatif:
    push eax                         ; Simpan nilai asli
    mov ecx, minusSign              ; Cetak tanda minus ('-')
    call print
    pop eax                          ; Ambil kembali nilai
    
    neg eax                          ; Konversi ke nilai absolut

.positive:
    lea edi, [WORD_BUFFER_INT + 5]  ; Pointer ke akhir buffer
    mov byte [edi], 0               ; Null terminator
    mov ebx, 10                      ; Basis 10 untuk konversi

.convert_loop:
    dec edi                         ; Mundur ke posisi sebelumnya di buffer
    xor edx, edx                      ; Clear EDX untuk DIV
    div ebx                          ; EAX/10, hasil di EAX, sisa di EDX
    add dl, '0'                     ; Konversi digit ke ASCII
    mov [edi], dl                   ; Simpan digit ke buffer
    test eax, eax                     ; Sudah habis? (EAX == 0)
    jnz .convert_loop               ; Jika belum, lanjutkan

    ; Hitung panjang string hasil:
    mov ecx, edi                    ; Awal string (digit pertama)
    mov edx, WORD_BUFFER_INT + 5    ; Akhir buffer
    sub edx, ecx                    ; EDX = panjang string
    ret                             ; Kembali dengan EDI=string, EDX=panjang






; ================================================================
; print_dword_int - Mencetak integer 16-bit (signed) ke stdout
;
; Input:
;   EAX - Nilai integer yang akan dicetak
;
; Register yang dimodifikasi:
;   EAX, ECX, EDX (melalui fungsi-fungsi yang dipanggil)
; ================================================================
print_dword_int:
    call int_to_string_word         ; Konversi EAX ke string (EDI)
    mov ecx, edi                    ; Set parameter string untuk print
    call print                      ; Cetak string
    ret
