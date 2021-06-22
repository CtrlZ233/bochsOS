;   打印函数
;   1.  备份寄存器现场
;   2.  获取光标位置
;   3.  获取待打印字符
;   4.  判断是否为控制字符。如果是回车、换行、退格之一，则进入相应的控制流程
;   5.  判断是否需要滚屏
;   6.  恢复寄存器现场，退出
TI_GDT equ  0
RPL0  equ   0
VIDEO_SELECTOR equ 0x18


section .data
put_int_buffer    dq    0     ; 定义8字节缓冲区用于数字到字符的转换

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


;--------------------   将小端字节序的数字变成对应的ascii后，倒置   -----------------------
;输入：栈中参数为待打印的数字
;输出：在屏幕上打印16进制数字,并不会打印前缀0x,如打印10进制15时，只会直接打印f，不会是0xf
;------------------------------------------------------------------------------------------
global put_int
put_int:
   pushad
   mov ebp, esp
   mov eax, [ebp+4*9]		       ; call的返回地址占4字节+pushad的8个4字节
   mov edx, eax
   mov edi, 7                          ; 指定在put_int_buffer中初始的偏移量
   mov ecx, 8			       ; 32位数字中,16进制数字的位数是8个
   mov ebx, put_int_buffer

;将32位数字按照16进制的形式从低位到高位逐个处理,共处理8个16进制数字
I16based_4bits:			       ; 每4位二进制是16进制数字的1位,遍历每一位16进制数字
   and edx, 0x0000000F		       ; 解析16进制数字的每一位。and与操作后,edx只有低4位有效
   cmp edx, 9			       ; 数字0～9和a~f需要分别处理成对应的字符
   jg is_A2F 
   add edx, '0'			       ; ascii码是8位大小。add求和操作后,edx低8位有效。
   jmp store
is_A2F:
   sub edx, 10			       ; A~F 减去10 所得到的差,再加上字符A的ascii码,便是A~F对应的ascii码
   add edx, 'A'

;将每一位数字转换成对应的字符后,按照类似“大端”的顺序存储到缓冲区put_int_buffer
;高位字符放在低地址,低位字符要放在高地址,这样和大端字节序类似,只不过咱们这里是字符序.
store:
; 此时dl中应该是数字对应的字符的ascii码
   mov [ebx+edi], dl		       
   dec edi
   shr eax, 4
   mov edx, eax 
   loop I16based_4bits

;现在put_int_buffer中已全是字符,打印之前,
;把高位连续的字符去掉,比如把字符000123变成123
ready_to_print:
   inc edi			       ; 此时edi退减为-1(0xffffffff),加1使其为0
skip_prefix_0:  
   cmp edi,8			       ; 若已经比较第9个字符了，表示待打印的字符串为全0 
   je full0 
;找出连续的0字符, edi做为非0的最高位字符的偏移
go_on_skip:   
   mov cl, [put_int_buffer+edi]
   inc edi
   cmp cl, '0' 
   je skip_prefix_0		       ; 继续判断下一位字符是否为字符0(不是数字0)
   dec edi			       ;edi在上面的inc操作中指向了下一个字符,若当前字符不为'0',要恢复edi指向当前字符		       
   jmp put_each_num

full0:
   mov cl,'0'			       ; 输入的数字为全0时，则只打印0
put_each_num:
   push ecx			       ; 此时cl中为可打印的字符
   call put_char
   add esp, 4
   inc edi			       ; 使edi指向下一个字符
   mov cl, [put_int_buffer+edi]	       ; 获取下一个字符到cl寄存器
   cmp edi,8
   jl put_each_num
   popad
   ret