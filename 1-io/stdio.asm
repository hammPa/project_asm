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
    lea edi, [BUFFER_INT + 11]  ; Point to end of buffer
    mov byte [edi], 0           ; Null terminator
    mov ebx, 10                 ; Divisor

.convert_loop:
    dec edi                     ; Move back in buffer
    xor edx, edx                ; Clear remainder
    div ebx                     ; Divide by 10
    add dl, '0'                 ; Convert to ASCII
    mov [edi], dl               ; Store character
    test eax, eax               ; Check if zero
    jnz .convert_loop

    ; Calculate length
    mov ecx, edi                ; Start of string
    mov edx, BUFFER_INT + 11    ; End of buffer
    sub edx, ecx                ; Calculate length
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

    mov [ecx + eax - 1], byte 0         ; setelah syscall int 0x80 untuk read, EAX akan berisi jumlah byte yang berhasil dibaca.
    ret
