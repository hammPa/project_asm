section .data
    hello db "Helo World", 0           ; kalau di bawahnya input tidak usah pakai 0xA
    num times 10 db ""

section .text
    global _start
    extern print
    extern print_int
    extern scan
    extern newline

_start:
    mov eax, 1234
    call print_int
    call newline

    mov ecx, hello
    call print

    mov ecx, num
    call scan

    mov ecx, num
    call print


    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
