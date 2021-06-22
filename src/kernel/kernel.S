%line 1+1 kernel.asm
[bits 32]

%line 5+1 kernel.asm

%line 24+1 kernel.asm

[extern put_string]

[section .data]
intr_str db "interrupt occur!", 0xa, 0

[global handle_func_table]

handle_func_table:
[section .text]
%line 33+0 kernel.asm
intr_0x00_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x00_entry
%line 34+1 kernel.asm
[section .text]
%line 34+0 kernel.asm
intr_0x01_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x01_entry
%line 35+1 kernel.asm
[section .text]
%line 35+0 kernel.asm
intr_0x02_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x02_entry
%line 36+1 kernel.asm
[section .text]
%line 36+0 kernel.asm
intr_0x03_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x03_entry
%line 37+1 kernel.asm
[section .text]
%line 37+0 kernel.asm
intr_0x04_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x04_entry
%line 38+1 kernel.asm
[section .text]
%line 38+0 kernel.asm
intr_0x05_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x05_entry
%line 39+1 kernel.asm
[section .text]
%line 39+0 kernel.asm
intr_0x06_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x06_entry
%line 40+1 kernel.asm
[section .text]
%line 40+0 kernel.asm
intr_0x07_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x07_entry
%line 41+1 kernel.asm
[section .text]
%line 41+0 kernel.asm
intr_0x08_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x08_entry
%line 42+1 kernel.asm
[section .text]
%line 42+0 kernel.asm
intr_0x09_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x09_entry
%line 43+1 kernel.asm
[section .text]
%line 43+0 kernel.asm
intr_0x0a_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0a_entry
%line 44+1 kernel.asm
[section .text]
%line 44+0 kernel.asm
intr_0x0b_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0b_entry
%line 45+1 kernel.asm
[section .text]
%line 45+0 kernel.asm
intr_0x0c_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0c_entry
%line 46+1 kernel.asm
[section .text]
%line 46+0 kernel.asm
intr_0x0d_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0d_entry
%line 47+1 kernel.asm
[section .text]
%line 47+0 kernel.asm
intr_0x0e_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0e_entry
%line 48+1 kernel.asm
[section .text]
%line 48+0 kernel.asm
intr_0x0f_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x0f_entry
%line 49+1 kernel.asm
[section .text]
%line 49+0 kernel.asm
intr_0x10_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x10_entry
%line 50+1 kernel.asm
[section .text]
%line 50+0 kernel.asm
intr_0x11_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x11_entry
%line 51+1 kernel.asm
[section .text]
%line 51+0 kernel.asm
intr_0x12_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x12_entry
%line 52+1 kernel.asm
[section .text]
%line 52+0 kernel.asm
intr_0x13_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x13_entry
%line 53+1 kernel.asm
[section .text]
%line 53+0 kernel.asm
intr_0x14_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x14_entry
%line 54+1 kernel.asm
[section .text]
%line 54+0 kernel.asm
intr_0x15_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x15_entry
%line 55+1 kernel.asm
[section .text]
%line 55+0 kernel.asm
intr_0x16_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x16_entry
%line 56+1 kernel.asm
[section .text]
%line 56+0 kernel.asm
intr_0x17_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x17_entry
%line 57+1 kernel.asm
[section .text]
%line 57+0 kernel.asm
intr_0x18_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x18_entry
%line 58+1 kernel.asm
[section .text]
%line 58+0 kernel.asm
intr_0x19_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x19_entry
%line 59+1 kernel.asm
[section .text]
%line 59+0 kernel.asm
intr_0x1a_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1a_entry
%line 60+1 kernel.asm
[section .text]
%line 60+0 kernel.asm
intr_0x1b_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1b_entry
%line 61+1 kernel.asm
[section .text]
%line 61+0 kernel.asm
intr_0x1c_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1c_entry
%line 62+1 kernel.asm
[section .text]
%line 62+0 kernel.asm
intr_0x1d_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1d_entry
%line 63+1 kernel.asm
[section .text]
%line 63+0 kernel.asm
intr_0x1e_entry:
 nop
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1e_entry
%line 64+1 kernel.asm
[section .text]
%line 64+0 kernel.asm
intr_0x1f_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x1f_entry
%line 65+1 kernel.asm
[section .text]
%line 65+0 kernel.asm
intr_0x20_entry:
 push 0
 push intr_str
 call put_string
 add esp, 0x4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr_0x20_entry
