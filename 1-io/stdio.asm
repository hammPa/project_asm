section .data
    BUFFER_INT times 12 db 0                    ; buffer untuk mengubah int menjadi string 32bit 
    BUFFER_SIZE db 100                          ; maksimal buffer untuk scan input
    newln db 0xA

section .text
    global newline
    global int_to_string
    global print
    global print_int
    global scan


; newline
newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newln
    mov edx, 1
    int 0x80
    ret

; int to string
int_to_string:
.convert_loop:
    xor edx, edx                    ; clear edx untuk menghilangkan remains
    mov ecx, 10                     ; basis 10
    div ecx                         ; eax / ecx, hasil di eax, sisa remains di edx

    add dl, '0'                     ; ubah ke ascii
    dec edi                         ; mundur 1 posisi di buffer
    mov [edi], dl                   ; masukkan ascii sebagai nilai di alamat yang di tunjuk edi sekarang

    test eax, eax
    jnz .convert_loop

.done:
    ; edi sekarang berisi string hasil konversi
    ret




; fungsi output
print:
    xor edx, edx                    ; reset edx

.count_loop:                        ; menghitung panjang untuk edx
    cmp byte [ecx + edx], 0         ; cek null terminator
    je .count_done
    inc edx
    jmp .count_loop

.count_done:
    mov eax, 4                      ; tampilkan
    mov ebx, 1
    int 0x80
    ret



; print angka
print_int:
    lea edi, [BUFFER_INT + 11]      ; pointer akhir buffer
    mov byte [edi], 0               ; null terminator di belakang
    call int_to_string

    mov ecx, edi
    call print
    ret



; fungsi input
scan:
    mov edx, BUFFER_SIZE            ; mengambil input dengan maksimal 100byte
    mov ebx, 0
    mov eax, 3
    int 0x80

    mov [ecx + eax], byte 0         ; setelah syscall int 0x80 untuk read, EAX akan berisi jumlah byte yang berhasil dibaca.
    ret
