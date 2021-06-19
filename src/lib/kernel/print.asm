;   打印函数
;   1.  备份寄存器现场
;   2.  获取光标位置
;   3.  获取待打印字符
;   4.  判断是否为控制字符。如果是回车、换行、退格之一，则进入相应的控制流程
;   5.  判断是否需要滚屏
;   6.  恢复寄存器现场，退出

VIDEO_SELECTOR equ 0x18

[bits 32]
section .text

global put_string
put_string:
    push ebx
    push ecx

    xor ecx, ecx
    mov ebx, [esp + 12]     ;基地址

go_on:
    mov cl, [ebx]
    cmp cl, 0
    je put_str_end
    push ecx
    call put_char
    add esp, 4
    inc ebx
    jmp go_on

put_str_end:
    pop ecx
    pop ebx
    ret


global put_char
put_char:
    pushad      ; 保存寄存器现场

    mov ax, VIDEO_SELECTOR
    mov gs, ax

    ; 获取光标当前的位置
    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    in al, dx
    mov ah, al          ;获取高8位

    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    in al, dx           ;获取低8位

    mov bx, ax

    ;获取待打印字符
    mov ecx, [esp + 36] ; pushad 压入32字节，主调函数的地址4字节，一共36字节

    cmp cl, 0xd         ; 是否为CR（回车符）
    je is_cr
    cmp cl,0xa          ; 是否为LF（换行符）
    je is_lf
    cmp cl, 0x8         ; 是否是BS（回退符）
    je is_bs
    jmp put_other

is_bs:
    dec bx
    shl bx, 1

    mov dword [gs:bx], 0x0720   ; 将回退位置的字符设置为空格
    shr bx, 1
    jmp set_cursor

put_other:
    shl bx, 1
    mov [gs:bx], cl
    inc bx
    mov byte [gs:bx], 0x07
    shr bx, 1
    inc bx
    jmp set_cursor

is_lf:      ; 换行处理
is_cr:      ; 回车处理
    xor dx, dx
    mov ax, bx      ; bx 保存光标位置
    mov si, 80      ; 每行80个字符
    div si          ; 余数存储在dx中
    sub bx, dx

is_cr_end:
    add bx, 80
    cmp bx, 2000

is_cl_end:
    jl set_cursor   ;如果小于，就设置光标，如果 大于，则滚屏

roll_screen:
    cld
    mov ecx, 960
    mov esi, 0xb80a0
    mov edi, 0xb8000
    rep movsd

    mov ebx, 3840
    mov ecx, 80

clear_last_row:
    mov word [gs:ebx], 0x0720   ;0x0720是黑底白字的空格键
    add ebx, 2
    loop clear_last_row
    mov bx, 1920

set_cursor:

    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    mov al, bh
    out dx, al


    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    mov al, bl
    out dx, al

put_char_end:
    popad
    ret
