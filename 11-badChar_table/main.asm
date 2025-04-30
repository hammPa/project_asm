section .data
    askInput db "Masukkan teks yang akan dijadikan kalimat: ", 0
    askPattern db "Masukkan pola yang akan di cari: ", 0
    minusSign db "-", 0

    space db " ", 0
    newline db 0xA, 0
    bufferSize db 32
    badcharArray times 256 dw -1             ; array badchar nilai awal -1

    indexText db ", index: ", 0


section .bss
    input_text resb 32              ; 32 byte
    pattern resb 32
    WORD_BUFFER_INT resw 6          ; buffer print int berukuran 2 byte, 5 angka, 1 null

section .text
    global _start

_start:
    ; input text
    mov ecx, askInput
    call print
    mov ecx, input_text
    call scan

    ; input pola
    mov ecx, askPattern
    call print
    mov ecx, pattern
    call scan


    ; buat badchar table
    mov eax, pattern                ; pindahkan pola ke eax dulu
    call badchar

    ; print badchar table
    call print_badchar_array

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
; int_to_string_word - Konversi 16-bit integer (AX) ke string ASCII
;
; Input:
;   AX - Nilai integer 16-bit yang akan dikonversi (bertanda/signed)
;
; Output:
;   EDI - Pointer ke awal string hasil konversi
;   EDX - Panjang string hasil (tidak termasuk null terminator)
;
; Register yang dimodifikasi:
;   EAX, EDX, EDI, BX
;
; Buffer yang digunakan:
;   WORD_BUFFER_INT - Buffer 6 byte (5 digit + null terminator)
; ================================================================
int_to_string_word:
    test ax, ax                      ; Cek tanda nilai input
    jns .positive                   ; Jika positif, lompat ke konversi
    
    ; Handle nilai negatif:
    push ax                         ; Simpan nilai asli
    mov ecx, minusSign              ; Cetak tanda minus ('-')
    call print
    pop ax                          ; Ambil kembali nilai
    
    neg ax                          ; Konversi ke nilai absolut

.positive:
    lea edi, [WORD_BUFFER_INT + 5]  ; Pointer ke akhir buffer
    mov byte [edi], 0               ; Null terminator
    mov bx, 10                      ; Basis 10 untuk konversi

.convert_loop:
    dec edi                         ; Mundur ke posisi sebelumnya di buffer
    xor dx, dx                      ; Clear DX untuk DIV
    div bx                          ; AX/10, hasil di AX, sisa di DX
    add dl, '0'                     ; Konversi digit ke ASCII
    mov [edi], dl                   ; Simpan digit ke buffer
    test ax, ax                     ; Sudah habis? (AX == 0)
    jnz .convert_loop               ; Jika belum, lanjutkan

    ; Hitung panjang string hasil:
    mov ecx, edi                    ; Awal string (digit pertama)
    mov edx, WORD_BUFFER_INT + 5    ; Akhir buffer
    sub edx, ecx                    ; EDX = panjang string
    ret                             ; Kembali dengan EDI=string, EDX=panjang






; ================================================================
; print_word_int - Mencetak integer 16-bit (signed) ke stdout
;
; Input:
;   AX - Nilai integer yang akan dicetak
;
; Register yang dimodifikasi:
;   EAX, ECX, EDX (melalui fungsi-fungsi yang dipanggil)
; ================================================================
print_word_int:
    call int_to_string_word         ; Konversi AX ke string (EDI)
    mov ecx, edi                    ; Set parameter string untuk print
    call print                      ; Cetak string
    ret





; ================================================================
; scan - Membaca input dari stdin (standard input)
;
; Input:
;   ecx - Alamat buffer untuk menyimpan input
;   [bufferSize] - Ukuran maksimum buffer (termasuk null terminator)
;
; Output:
;   Input pengguna disimpan di buffer yang ditunjuk oleh ecx
;   Mengganti newline (\n) dengan null terminator (\0)
;
; Register yang dimodifikasi:
;   eax, ebx, edx (melalui syscall)
; ================================================================
scan:
    mov eax, 3                  ; Syscall read
    mov ebx, 0                  ; File descriptor stdin (0)
    movzx edx, byte [bufferSize] ; Ukuran buffer
    int 0x80                    ; Panggil kernel

    ; Ganti newline dengan null terminator
    mov [ecx + eax - 1], byte 0 ; Timpa \n di akhir dengan \0
    ret


; ================================================================
; badchar - Membuat tabel bad character untuk algoritma Boyer-Moore
;
; Input:
;   eax - Alamat pola (pattern) yang akan diproses
;
; Output:
;   badcharArray - Tabel berisi posisi terakhir setiap karakter dalam pola
;                  (Diinisialisasi dengan -1 untuk karakter yang tidak ada dalam pola)
;
; Register yang dimodifikasi:
;   eax, ebx, ecx, edx
; ================================================================
badchar:
    mov ecx, eax            ; Salin alamat pola ke ecx untuk strlen

    push eax                ; Simpan alamat pola (karena strlen modifikasi register)
    call strlen             ; Hitung panjang pola (hasil di edx)
    pop eax                 ; Kembalikan alamat pola

    xor ebx, ebx            ; Inisialisasi counter (i = 0)

.loop:
    cmp ebx, edx            ; Bandingkan counter dengan panjang pola
    je .exit                ; Jika i == len, keluar loop
    
    ; Proses setiap karakter dalam pola
    movzx ecx, byte [eax + ebx]  ; Ambil karakter ke-i dari pola
    mov [badcharArray + ecx * 2], bx  ; Simpan posisi karakter dalam badcharArray
    
    inc ebx                 ; Increment counter
    jmp .loop               ; Ulangi untuk karakter berikutnya

.exit:
    ; Setelah selesai, badcharArray berisi:
    ;   -1 untuk karakter yang tidak ada dalam pola
    ;   Posisi indeks (0-based) untuk karakter yang ada dalam pola
    ret







; ================================================================
; print_badchar_array - Mencetak isi tabel bad character (Boyer-Moore)
;
; Output:
;   Mencetak format: [nilai] [index] untuk setiap karakter yang valid
;   Hanya mencetak entri yang nilainya bukan -1
;
; Register yang dimodifikasi:
;   eax, ecx, esi, edi (serta register yang dimodifikasi oleh fungsi print)
;
; Variabel eksternal yang digunakan:
;   badcharArray - Array 256 word (2 byte) berisi tabel bad character
;   space        - String spasi (" ")
;   indexText    - String penanda index
;   newline      - String newline ("\n")
; ================================================================
print_badchar_array:
    xor esi, esi                     ; Inisialisasi counter (i = 0)
    mov edi, 256                     ; Batas atas loop (256 karakter ASCII)

.loop_badchar:
    cmp esi, edi                     ; Cek apakah sudah mencapai akhir array
    je .exit_loop                   ; Jika ya, keluar dari loop

    ; Ambil nilai dari badcharArray
    movsx eax, word [badcharArray + esi * 2]  ; Load nilai (sign-extended)
    cmp eax, -1                      ; Cek apakah nilai -1 (karakter tidak ada dalam pola)
    je .next_element                 ; Lewati pencetakan jika -1

    ; Cetak nilai array (eax)
    push eax                         ; Simpan nilai (karena print_word_int modifikasi register)
    push edi                         ; Simpan batas loop
    call print_word_int              ; Cetak nilai
    pop edi                          ; Restore batas loop
    pop eax                          ; Restore nilai array

    ; Cetak spasi pemisah
    mov ecx, space                   ; Set parameter untuk print
    call print                       ; Cetak spasi

    ; Cetak label index
    mov ecx, indexText               ; Set parameter teks label
    call print                       ; Cetak label

    ; Cetak index saat ini (esi)
    mov eax, esi                     ; Set parameter index untuk dicetak
    push eax                         ; Simpan nilai (karena print_word_int modifikasi register)
    push edi                         ; Simpan batas loop
    call print_word_int              ; Cetak index
    pop edi                          ; Restore batas loop
    pop eax                          ; Restore nilai array

    ; Cetak newline
    mov ecx, newline                 ; Set parameter newline
    call print                       ; Cetak baris baru

.next_element:
    inc esi                          ; Increment counter (i++)
    cmp esi, edi                     ; Bandingkan dengan batas atas
    jl .loop_badchar                 ; Lanjutkan loop jika i < 256

.exit_loop:
    ret11
