[bits 32]

%define ERR_CODE nop
%define ZERO push 0

%macro VECTOR 2
section .text
intr_%1_entry:
    %2
    push intr_str
    call put_string
    add esp, 0x4

    mov al, 0x20
    out 0xa0, al
    out 0x20, al

    add esp, 4          ; 跳过err_code
    iret

section .data
    dd  intr_%1_entry
%endmacro

extern put_string

section .data
intr_str db "interrupt occur!", 0xa, 0

global handle_func_table

handle_func_table:
VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO
VECTOR 0x03, ZERO
VECTOR 0x04, ZERO
VECTOR 0x05, ZERO
VECTOR 0x06, ZERO
VECTOR 0x07, ZERO
VECTOR 0x08, ERR_CODE
VECTOR 0x09, ZERO
VECTOR 0x0a, ERR_CODE
VECTOR 0x0b, ERR_CODE
VECTOR 0x0c, ZERO
VECTOR 0x0d, ERR_CODE
VECTOR 0x0e, ERR_CODE
VECTOR 0x0f, ZERO
VECTOR 0x10, ZERO
VECTOR 0x11, ERR_CODE
VECTOR 0x12, ZERO
VECTOR 0x13, ZERO
VECTOR 0x14, ZERO
VECTOR 0x15, ZERO
VECTOR 0x16, ZERO
VECTOR 0x17, ZERO
VECTOR 0x18, ERR_CODE
VECTOR 0x19, ZERO
VECTOR 0x1a, ERR_CODE
VECTOR 0x1b, ERR_CODE
VECTOR 0x1c, ZERO
VECTOR 0x1d, ZERO
VECTOR 0x1e, ERR_CODE
VECTOR 0x1f, ZERO
VECTOR 0x20, ZERO
