[bits 32]

%define ERR_CODE nop
%define ZERO push 0

extern handle_func_table
extern put_string

section .data
intr_str db "interrupt occur!", 0xa, 0

global handle_entry_table
handle_entry_table:
%macro VECTOR 2
section .text
intr_%1_entry:
    %2				 ; 中断若有错误码会压在eip后面 
; 以下是保存上下文环境
    
    pushad			 ; PUSHAD指令压入32位寄存器,其入栈顺序是: EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI
    push es
    push fs
    push gs
    push ds
 

    push %1			
    call [handle_func_table + %1*4]       ; 调用handle_func_table中的C版本中断处理函数
    jmp intr_exit

section .data
    dd  intr_%1_entry
%endmacro

section .text
global intr_exit
intr_exit:	     
; 以下是恢复上下文环境
    ; add esp, 4			   ; 跳过参数
    add esp, 4			   ; 跳过中断号

    pop ds
    pop gs
    pop fs
    pop es
    popad

    ; 如果是从片上进入的中断,除了往从片上发送EOI外,还要往主片上发送EOI 
    mov al,0x20                   ; 中断结束命令EOI
    out 0xa0,al                   ; 向从片发送
    out 0x20,al                   ; 向主片发送

    add esp, 4			   ; 跳过error_code
    iret

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
