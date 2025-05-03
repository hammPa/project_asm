section .data
    MAX_SIZE dd 10
    rear dd 0
    front dd 0
    minusSign db "-", 0
    emptyMessage db "Queue is empty", 0XA, 0
    fullMessage db "Queue is full", 0xA, 0
    dequeueMessage db "The value had been taken is: ", 0
    queueMessage db "Queue: ", 0
    space db " ", 0
    newline db 0xA, 0

    inputAngkaMessage db "Masukkan angka yang akan di input: ", 0
    showPilihan db "Pilihan:", 0xA, "1. Enqueue(insert)", 0xA, "2. Dequeue(remove)", 0xA, "3. Exit (0)", 0xA, "Kamu Memilih: ", 0
    BUFFER_SIZE db 100
    BUFFER_SCAN times 100 db ""

section .bss
    pilihan resd 1
    queue resd 10
    WORD_BUFFER_INT resd 6          ; buffer print int berukuran 4 byte, 5 angka, 1 null
    buffer resd 1

section .text
    global _start

_start:
    mov dword [pilihan], -1  ; Inisialisasi pilihan

.menu_utama:
    ; Tampilkan menu
    call show
    mov ecx, showPilihan
    call print

    ; Baca input pilihan user
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer     ; 
    mov edx, 2          ; Baca 2 byte (1 karakter + newline)
    int 0x80

    ; Konversi ke integer
    movzx eax, byte [buffer]
    sub eax, '0'
    mov [pilihan], eax

    ; Pengecekan pilihan
    cmp eax, 1
    je .proses_input
    cmp eax, 2
    je .proses_del
    cmp eax, 0
    je .exit_program
    jmp .menu_utama     ; Input invalid, ulang menu

.proses_input:
    ; Proses enqueue
    mov ecx, inputAngkaMessage
    call print
    
    mov ecx, BUFFER_SCAN
    call scan

    mov ecx, BUFFER_SCAN
    call string_to_int

    call enqueue
    jmp .menu_utama     ; Kembali ke menu utama

.proses_del:
    ; Proses dequeue
    call dequeue
    jmp .menu_utama     ; Kembali ke menu utama

.exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80








enqueue:
    mov esi, [rear]
    cmp esi, [MAX_SIZE]                 ; jikka index rear = maxsize, berarti penuh
    jge .full

    mov [queue + esi * 4], eax          ; masukkan nilai ke dalam queue dengan index rear
    inc dword [rear]                    ; rear++

    jmp .exit

.full:
    mov ecx, fullMessage
    call print
    jmp .exit

.exit:
    ret





; hasil bisa di ambil di eax
dequeue:
    mov edi, [front]                        ; nilai front 
    mov esi, [rear]                         ; nilai rear
    cmp edi, esi                            ; jika sama, berarti kosong
    je .empty

    mov eax, [queue + edi * 4]
    inc dword [front]                       ; front++

    push eax
    mov ecx, dequeueMessage
    call print

    pop eax
    push eax
    call print_dword_int

    mov ecx, newline
    call print

    pop eax
    jmp .exit

.empty:
    mov ecx, emptyMessage
    call print

.exit:
    ret




show:
    mov ecx, queueMessage
    call print
    
    mov edi, [front]    ; Load front index
    mov esi, [rear]     ; Load rear index

.loop:
    cmp edi, esi        ; Jika front >= rear, keluar (kosong)
    jge .exit

    push edi
    mov eax, [queue + edi * 4]  ; Ambil nilai dari antrian
    call print_dword_int         ; Cetak nilai

    mov ecx, space
    call print

    pop edi
    inc edi                    ; Pindah ke indeks berikutnya
    jmp .loop                  ; Ulangi

.exit:
    mov ecx, newline
    call print
    ret




reset_queue:
    mov [front], dword 0
    mov [rear], dword 0
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




; fungsi input
scan:
    mov edx, BUFFER_SIZE            ; mengambil input dengan maksimal 100byte
    mov ebx, 0
    mov eax, 3
    int 0x80

    mov [ecx + eax - 1], byte 0         ; setelah syscall int 0x80 untuk read, EAX akan berisi jumlah byte yang berhasil dibaca.
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
