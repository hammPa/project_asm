section .data
    space db " ", 0
    newline db 0xA, 0
    minusSign db "-", 0
    arrow db "-->", 0
    NULL db "NULL", 0

    welcomeMessage db "Selamat datang di linkedlist dengan assembly :D", 0xA, 0
    pilihanMessage db "Pilihan Tersedia:", 0xA, "1. Push", 0xA, "2. Pop", 0xA, "Masukkan pilihan anda: ", 0
    inputMessage db "Masukkan nilai yang ingin anda masukkan ke list: ", 0

    BUFFER_SIZE db 100

section .bss
    BUFFER_SCAN resb 100
    WORD_BUFFER_INT resd 6

    pilihan resd 1
    buffer_pilihan resd 1

    ALLOC_BUFFER resd 2
    head resd 2

section .text
    global _start

_start:
    mov dword [pilihan], 0
    mov dword [head], 0
    mov ecx, welcomeMessage
    call print

.main_loop:
    call show
    mov ecx, pilihanMessage
    call print

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer_pilihan
    mov edx, 2
    int 0x80

    movzx eax, byte [buffer_pilihan]
    sub eax, '0'
    mov [pilihan], eax

    cmp eax, 1
    je .input

    cmp eax, 2
    je .pop

    cmp eax, 3
    je .done_loop

    jmp .main_loop


.input:
    mov ecx, inputMessage
    call print

    mov ecx, BUFFER_SCAN
    call scan
    call string_to_int
    mov ebx, eax                ; pindahkan input yang sudah jadi angka ke ebx
    
    ; alokasi
    call alloc
    mov eax, [ALLOC_BUFFER]
    ; masukkan nilai
    mov dword [eax], ebx
    ; masukkan nextnya null
    mov dword [eax + 4], 0

    cmp [head], dword 0
    je .input_head
    jne .input_node

.input_head:
    mov [head], eax             ; head menunjuk ke alamat alokasi yang tersimpan di eax
    jmp .exit_input

.input_node:
    mov ebx, [head]      ; ambil alamat alokasi yang tersimpan di alamat head (ebx)

.____loop_node:
        cmp [ebx + 4], dword 0          ; temp->next != 0
        je .____exit_loop_node          ; inputkan alamat ke next alamat terakhir

        mov ebx, [ebx + 4]  ; temp = temp->next
        jmp .____loop_node

.____exit_loop_node:
        mov [ebx + 4], eax  ; alamat memori baru yang sudah berisi nilai dimasukkan ke next dari list paling belakang

.exit_input:
    mov ecx, newline
    call print
    jmp .main_loop



.pop:
.exit_pop:
    mov ecx, newline
    call print
    jmp .main_loop


.done_loop:
    mov eax, 1
    xor ebx, ebx
    int 0x80





alloc:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    mov eax, 192
    xor ebx, ebx
    mov ecx, 8              ; byte
    mov edx, 0x3
    mov esi, 0x22
    mov edi, -1
    xor ebp, ebp
    int 0x80

    mov [ALLOC_BUFFER], eax    ; simpan alamat alokasi di alamat alloc buffer

    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret





show:
    mov ebx, [head]             ; mulai dari head

.loop:
    cmp ebx, 0                  ; kalau NULL, keluar
    je .exit

    mov eax, [ebx]              ; ambil nilai dari node
    
    push eax
    push ebx

    call print_dword_int        ; cetak nilainya
    mov ecx, space
    call print
    
    mov ecx, arrow
    call print

    mov ecx, space
    call print

    pop ebx
    pop eax

    mov ebx, [ebx + 4]          ; pindah ke node berikutnya
    jmp .loop

.exit:
    mov ecx, NULL
    call print

    mov ecx, newline
    call print
    ret





; fungsi input
scan:
    mov edx, BUFFER_SIZE            ; mengambil input dengan maksimal 100byte
    mov ebx, 0
    mov eax, 3
    int 0x80

    mov [ecx + eax - 1], byte 0         ; setelah syscall int 0x80 untuk read, EAX akan berisi jumlah byte yang berhasil dibaca.
    ret




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
