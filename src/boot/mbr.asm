  
; MBR的主要功能：
;   1. 检查磁盘分区表并寻找可以引导的“活动”分区
;   2. 将活动分区的第一逻辑扇区内容装入内存

boot_loader_addr equ 0x900

org 0x7c00
bits 16
    
    ; 设置各个段寄存器
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7c00
    mov si, sp
    mov es, ax
    mov ds, ax
    sti

    cld ;存储器地址自动增加
    
    ; 清屏
    mov ah,0x00
    mov al,0x03
    int 0x10

    mov si, DPT      ; 0x7c10

find_active_section:
    cmp si, 0x7DEF     
    jge active_section_err
    mov al, [si]
    cmp al, 0x80
    jne next_section_elem  ; 不是活动扇区，继续向上扫描

    xor eax, eax
    mov eax, [si + 0x3]      ; 起始扇区
    mov cx, [si + 0xc]      ; 扇区数
    cmp bx, dx      ;0x7c29
    jng load_section    ;bx不大于dx时，说明扇区有效，即找到有效的活动扇区
    jmp active_section_err

next_section_elem:  ;0x7c2f
    add si, 0x10
    jmp find_active_section


load_section:   ;0x7c34
    mov ebx, boot_loader_addr
    call ReadLBA
    jmp boot_loader_addr + 0x200    ; bootloader头部预留了512字节的数据区


active_section_err: ; 0x7c3d
    jmp $

ReadLBA:    ;该函数借鉴《操作系统真相还原》
;-------------------------------------------------------------------------------
				       ; eax=LBA扇区号
				       ; ebx=将数据写入的内存地址
				       ; ecx=读入的扇区数
      mov esi,eax	  ;备份eax
      mov di,cx		  ;备份cx
;读写硬盘:
;第1步：设置要读取的扇区数
      mov dx,0x1f2
      mov al,cl
      out dx,al            ;读取的扇区数

      mov eax,esi	   ;恢复ax

;第2步：将LBA地址存入0x1f3 ~ 0x1f6

      ;LBA地址7~0位写入端口0x1f3
      mov dx,0x1f3                       
      out dx,al                          

      ;LBA地址15~8位写入端口0x1f4
      mov cl,8
      shr eax,cl
      mov dx,0x1f4
      out dx,al

      ;LBA地址23~16位写入端口0x1f5
      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al,0x0f	   ;lba第24~27位
      or al,0xe0	   ; 设置7～4位为1110,表示lba模式
      mov dx,0x1f6
      out dx,al

;第3步：向0x1f7端口写入读命令，0x20 
      mov dx,0x1f7
      mov al,0x20                        
      out dx,al

;第4步：检测硬盘状态
  .not_ready:
      ;同一端口，写时表示写入命令字，读时表示读入硬盘状态
      nop
      in al,dx
      and al,0x88	   ;第4位为1表示硬盘控制器已准备好数据传输，第7位为1表示硬盘忙
      cmp al,0x08
      jnz .not_ready	   ;若未准备好，继续等。

;第5步：从0x1f0端口读数据
      mov ax, di
      mov dx, 256
      mul dx
      mov cx, ax	   ; di为要读取的扇区数，一个扇区有512字节，每次读入一个字，
			   ; 共需di*512/2次，所以di*256
      mov dx, 0x1f0
  .go_on_read:
      in ax,dx
      mov [bx],ax
      add bx,2		  
      loop .go_on_read
      ret   

    times 446 - ($-$$) db 0
    ;--------------------- 分区表占64字节---------------------
DPT:
    db 0x80 ; 代表活动扇区
    db 0x00, 0x00, 0x10 ;LBA寻址 第二扇区
    db 0x00 ; 不知道是啥文件系统（随便都行？）
    db 0x00, 0x00, 0x19 ;结束的扇区LBA逻辑地址
    dd 0x00 ; 本分区之前已用了的扇区数
    dd 0xA ; 本分区的总扇区数


    times  510 - ($-$$) db 0
    dw 0xaa55