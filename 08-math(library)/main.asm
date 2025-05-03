section .data
    div_by_zero_err db "Error: Divided by Zero", 0xA, 0

section .bss


section .text
    global _start
    extern print
    extern print_int
    extern scan
    extern newline

_start:
    mov eax, 400
    call sqrt
    call print_int

    mov eax, 1
    xor ebx, ebx
    int 0x80




; eax = base
; ecx = exponent
; hasil = eax
pow:
    mov ebx, eax
.loop:
    cmp ecx, 1
    je .pow_exit

    imul ebx        ; eax = eax * ebx
    dec ecx
    jmp .loop

.pow_exit:
    ret



; eax = base
; ebx = divider
; hasil di eax
mod:
    cmp ebx, 0
    je .div_zero_err

    idiv ebx        ; eax = eax / ebx, eax = hasil bagi
    mov eax, edx    ; edx adalah sisa bagi, pindahkan ke eax
    ret

.div_zero_err:
    mov ecx, div_by_zero_err    ; cetak pesan error
    call print
    mov eax, 1
    xor ebx, ebx
    int 0x80
    


; ; eax = base
; Input:  eax = N
; Output: eax = sqrt(N) (dalam integer, dibulatkan ke bawah)
sqrt:
    mov esi, eax        ; simpan N di ESI
    shr eax, 1          ; tebakan awal Xn = N / 2
    mov ebx, eax        ; EBX = Xn

.loop:
    mov eax, esi        ; EAX = N
    xor edx, edx        ; wajib 0 sebelum div
    div ebx             ; EAX = N / Xn
    add eax, ebx        ; EAX = Xn + (N / Xn)
    shr eax, 1          ; EAX = (Xn + N / Xn) / 2

    cmp eax, ebx        ; apakah Xn+1 == Xn?
    je .sqrt_exit            ; jika ya, selesai
    mov ebx, eax        ; update Xn
    jmp .loop


.sqrt_exit:
    ret


; eax = angka
fact:
    mov ecx, eax
    mov eax, 1

.loop:
    cmp ecx, 1
    je .fact_exit

    imul eax, ecx
    dec ecx
    jmp .loop

.fact_exit:
    ret


; eax = angka
absol:
    cmp eax, 0
    jge .abs_exit

    neg eax

.abs_exit:
    ret


