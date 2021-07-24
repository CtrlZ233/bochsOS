; bootloader的主要功能：
;   1. 探测和组织内存
;   2. 开启保护模式
;   3. 从磁盘读取kernel并加载到内存
;   4. 初始化页表和页目录表
;   5. 跳转到kernel入口


;----------------------------------------------------------------------------------------------
; bootloader的内存布局
; ------------------------------------------0x100000-------------------------------------------
; ....
; -------------------------------------------0x9FC00-------------------------------------------
; 存放kernel.bin文件的内存映像 (191 KB)
; -------------------------------------------0x70000-------------------------------------------
; 
; 可用区域 622080B (约 417 KB)
;
; --------------------------------------------0x7E00-------------------------------------------
; MBR被BIOS加载到此处 512 B (加载内核后被内核覆盖)
; --------------------------------------------0x7C00-------------------------------------------
; 内核代码和数据区，此区域可以一直往上扩展，直到0x70000 (442 KB)
; --------------------------------------------0x1500-------------------------------------------
;
; bootloader代码区 (最多2560 B)
;
; ---------------------------------------------0xB00-------------------------------------------
; bootloader数据区，也是GDT、和内存布局等数据结构存放的地方
; ---------------------------------------------0x900-------------------------------------------
; 可用区域 (约 30 KB)
; ---------------------------------------------0x500-------------------------------------------
; BIOS数据区 (256 B)
; ---------------------------------------------0x400-------------------------------------------
; 中断向量表IVT (1 KB)
; ---------------------------------------------0x000-------------------------------------------


;      base 32位, lim 20位

        ; ----------------------------------段描述符格式-----------------------------------
        ; |31--------------24-23--22--21-20--19---16--15-14--13-12-11----8-7------------0|
        ; |   Base 31:24    | G |D/B| L |AVL|seglimit| P | DPL | S | Type |  Base 23:16  | 高字节
        ; |               Base 15:0                |            seglimit 15:0            | 低字节
        ; |31------------------------------------16-15----------------------------------0|

    ;   P = 1, DPL = 00, S = 1
    ;   G = 1, D/B = 1, L = 0, AVL = 0

;   该宏定义参考清华开源项目ucore
%macro SEG_ASM 3      
    dw ((%3) & 0xffff), ((%2) & 0xffff)  
    db (((%2) >> 16) & 0xff), (0x90 | (%1)),  (0xc0 | (((%3) >> 16) & 0xf)), (((%2) >> 24) & 0xff)
%endmacro
;      type的种类
%define STA_X       0x8         ;  可执行段
%define STA_E       0x4         ;  非可执行段
%define STA_C       0x4         ;  只能执行段
%define STA_W       0x2         ;  可写但不能执行
%define STA_R       0x2         ;  可读可执行
%define STA_A       0x1         ;  被访问



; 保护模式下的段选择子（存于段寄存器中）格式
;           |15------------------3--2--1--0|
;           |       Index         | TI |RPL|

; kernel下TI = 0, RPL = 0


;  地址范围描述符（Address Range Descriptor Structure, ARDS)结构
;  ------------------------------------------------------------------------------------
;       字节偏移量      |    属性名称    |               描述
;  ------------------------------------------------------------------------------------
;           0          |  BaseAddrLow  |        基地址的低32位
;  ------------------------------------------------------------------------------------
;           4          |  BaseAddrHigh |        基地址的高32位
;  ------------------------------------------------------------------------------------
;           8          |   LengthLow   |        内存长度的低32位，以字节为单位
;  ------------------------------------------------------------------------------------
;           12         |   LengthHigh  |        内存长度的高32为，以字节为单位
;  ------------------------------------------------------------------------------------
;           16         |      Type     |        本段内存的类型（1：可以被使用；2：被保留）
;  ------------------------------------------------------------------------------------


;   页目录项
;   31----------------12-11--9-8--7--6-5--4---3--2--1--0
;   |   Page Phy Addr   | AVL |G| 0 |D|A|PCD|PWT|US|RW|P|       页目录项
;   |     Phy Addr      | AVL |G|PAT|D|A|PCD|PWT|US|RW|P|       页表项
;   31----------------12-11--9-8--7--6-5--4---3--2--1--0
;   | Page dictory Addr |               |PCD|PWT|       |       PDBR(cr3)

%define PG_P        1b          ; 存在位
%define PG_RW_R     00b         ; 读
%define PG_RW_W     10b         ; 写
%define PG_US_U     000b        ; 用户
%define PG_US_S     100b        ; 超级用户


; program type
%define PT_NULL     0x0         ; 未使用
%define PT_LOAD     0x1         ; 可加载
%define PT_DYNAMIC  0x2         ; 动态链接
%define PT_INTERP   0x3         
%define PT_NOTE     0x4
%define PT_SHLIB    0x5
%define PT_PHDR     0x6

CS_SELECTOR equ 0x8
DS_SELECTOR equ 0x10
VIDEO_SELECTOR equ 0x18

PAGE_DIR_TBALE_ADDR equ 0x100000    ; kernel 目测存储在低1MB的物理内存空间即可
LOADER_STACK_TOP equ 0x900 ;栈向下增长，范围为 0x9000 ~ 0x7E00（事实上个人感觉进入bootLoader后Mbr的代码已经没用，
                            ;因此栈段可以覆盖0x7E00下的地址，但不能一直往下覆盖，下方还有BIOS数据和中断向量表

KERNEL_BIN_START_SECTION equ 0x20
KERNEL_BIN_BASE_ADDR equ 0x70000    ; 随便找个空地方
KERNEL_BIN_SECTION_NUM equ 0xC8
KENREL_ENTRY_POINT equ 0xc0001500  ; 虚拟地址
section bootloader vstart=0x900
    ;---------------------------------------------------------------------------------------
    ;---------------------------------------------------------------------------------------
    ; 预留512 bytes 用来存放GDT和内存相关的数据结构，其中GDT占256个字节
    ; 应放在头部，如果放在尾部，而之后加载kernel到0x1500，如果bootloader的字节数超过0x1500-0x900 = 0x600 = 1536 byte，GDT会被kernel覆盖

GDT:            ;每个段描述符8字节
NULL_SEG:       ;第一个段描述符默认为空
    dd 0, 0
CODE_SEG:
    SEG_ASM (STA_X | STA_R), 0x0, 0xFFFFF   ;base = 0x0, limit = 0xFFFFF(4kb为单位）

DATA_SEG:
    SEG_ASM STA_W, 0x0, 0xFFFFF             ;base = 0x0, limit = 0xFFFFF(4kb为单位）

VIDEO_SEG:
    SEG_ASM STA_W,  0xB8000,0x7

GDT_SIZE equ $ - GDT
GDT_LIMIT equ GDT_SIZE - 1

empty_slot:
    times 256 - ($-GDT) db 0


; 之后的内存管理需要用到该变量，物理地址为 0x900 + 256 = 0xa00
total_mem_size dd 0

GDT_Description:
    dw GDT_LIMIT
    dd GDT 


align 4
ARDS_BUF:
    times 256 - 2- ($ - total_mem_size) db 0

ARDS_NUM:
    dw 0
;   -----------------------------------------------------------------------------------------
;   -----------------------------------------------------------------------------------------
[bits 16]
    
    ;   准备内存
    call MemoryDetect
    call FindMaxMemory

    ; 开启保护模式
    ;   1. 打开A20
    ;   2. 加载GDT   
    ;   3. 使能保护模式
    
    ; Fast A20
    in al, 0x92
    or al, 0x2
    out 0x92, al

    ; load GDT
    lgdt [GDT_Description]
    ; enable protect mode
    cli         ; 在设置IDT之前需要一直关中断，否则会因为时钟中断的无效处理而导致系统重启
    xor eax, eax
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    
    jmp CS_SELECTOR:p_mode_start


;   使用BIOS中断的子功能0xE820探测内存
MemoryDetect:
    
    xor ebx, ebx
    mov edx, 0x534d4150 ; magic number
    mov di, ARDS_BUF

getloop:
    mov eax, 0xE820
    mov ecx, 0x14       ;每次写入的字节数
    int 0x15            ; 会修改eax的值，因此，需要重新设置eax
    jc err_code
    add di, cx
    inc word [ARDS_NUM]
    cmp ebx, 0
    jnz getloop

    ret

FindMaxMemory:
    mov cx, [ARDS_NUM]
    mov ebx, ARDS_BUF
    xor edx, edx

findLoop:
    mov eax, [ebx]  ; BaseAddrLow
    add eax, [ebx + 8] ; BaseAddrLow + LengthLow
    add ebx, 0x14
    cmp edx, eax
    jge next_ARDS
    mov edx, eax    ; edx为总内存大小
    
next_ARDS:
    loop findLoop
    mov [total_mem_size], edx
    ret



    
[bits 32]
p_mode_start:  
    xor eax, eax    
    mov ax, DS_SELECTOR
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, VIDEO_SELECTOR
    mov gs, ax
    
    ; 将内核ELF文件读入内存
    mov eax, KERNEL_BIN_START_SECTION
    mov ebx, KERNEL_BIN_BASE_ADDR
    mov ecx, KERNEL_BIN_SECTION_NUM
    call ReadLBA

    ; 初始化页结构
    call SetPage
    
    sgdt [GDT_Description]

    mov ebx, [GDT_Description + 2] ;得到GDT基址
    mov ecx, 0x3        ; 目前只有三个段
    mov esi, 0x1
    
reset_gdt:
    or dword [ebx + esi * 0x8 + 4], 0xc0000000
    inc esi
    loop reset_gdt

    add dword [GDT_Description + 2], 0xc0000000
    add esp, 0xc0000000

    mov eax, PAGE_DIR_TBALE_ADDR
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [GDT_Description]
    ; mov byte [gs:160], 'V'

    jmp CS_SELECTOR:kernelEntry

kernelEntry:
    call KerelInit
    mov esp, 0xc009f000
    jmp word KENREL_ENTRY_POINT


SetPage:
    mov ecx, 4096
    mov esi, 0

clear_page_dir:
    mov byte [PAGE_DIR_TBALE_ADDR + esi], 0
    inc esi
    loop clear_page_dir

create_pde:
    mov eax, PAGE_DIR_TBALE_ADDR
    add eax, 0x1000    ; 第一个页表的物理地址0x101000 , eax存放页目录项
    mov ebx, eax

    or eax, PG_P | PG_RW_W |PG_US_U
    mov [PAGE_DIR_TBALE_ADDR], eax
    mov [PAGE_DIR_TBALE_ADDR + 0xc00], eax  ; 虚拟地址的3G~4G为内核空间，也就是虚拟地址的高10位为 0xC00~0xFFF

    sub eax, 0x1000
    mov [PAGE_DIR_TBALE_ADDR + 4092], eax   ; 最后一个页目录表项指向自己（自映射）

    ; 创建页表项，写入页表
    mov ecx, 256        ; 低端内存 1M / 每页 4K = 256
    mov esi, 0
    xor edx, edx
    mov edx, PG_P | PG_RW_W |PG_US_U

create_pte:
    mov [ebx + 4 * esi], edx
    add edx, 4096
    inc esi
    loop create_pte

    ; 补全页目录表
    mov eax, PAGE_DIR_TBALE_ADDR
    add eax, 0x2000
    or eax, PG_P | PG_RW_W |PG_US_U

    mov ecx, 254
    mov esi, 0xC04

create_kernel_pde:
    mov [PAGE_DIR_TBALE_ADDR + esi], eax
    add esi, 0x4
    add eax, 0x1000
    loop create_kernel_pde


    

; init_kernel_page:   ; 第1M已经被映射过了，第2M~5M用于存放页表和页目录，因此我们将第6~9M映射到该逻辑页面
;     ; 0x8048000 这一个页面需要映射（从gcc编译后的elf文件的某些segment的虚拟地址在这个页上）
;     mov [PAGE_DIR_TBALE_ADDR + 0x80], eax
;     mov ebx, [PAGE_DIR_TBALE_ADDR + 0x80]
;     and ebx, 0xFFFFF000     ; 需要准备的页表的基地址
;     mov edx, 0x600000        ; 物理页面地址
;     or edx, PG_P | PG_RW_W |PG_US_U
;     mov esi, 0
;     mov ecx, 1024

; create_kernel_pte:
;     mov [ebx + 4 * esi], edx
;     add edx, 4096
;     inc esi
;     loop create_kernel_pte
    
    ret

ReadLBA:    ;该函数借鉴《操作系统真相还原》
;-------------------------------------------------------------------------------
				       ; eax=LBA扇区号
				       ; ebx=将数据写入的内存地址
				       ; ecx=读入的扇区数
      mov esi,eax	  ;备份eax
      mov edi,ecx		  ;备份cx
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
      mov [ebx],ax
      add ebx,2		  
      loop .go_on_read
      ret   


KerelInit:
    xor eax, eax
    xor ebx, ebx
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28]    ; program header offset
    add ebx, KERNEL_BIN_BASE_ADDR
    xor ecx, ecx
    mov cx, [KERNEL_BIN_BASE_ADDR + 44]    ; 程序头部的条目数量
    xor edx, edx
    mov dx, [KERNEL_BIN_BASE_ADDR + 42]     ; size of one program header

each_segment:
    mov eax, [ebx]      ; segment type
    cmp  eax, PT_NULL
    je pt_null

    ;      MemCpy(dst, src, size)
    
    push dword [ebx + 16]     ; size

    mov eax, [ebx + 4] ; offset
    add eax, KERNEL_BIN_BASE_ADDR 
    push eax  ; src

    push dword [ebx + 8] ; dst

    call MemCpy  
    add esp, 12     ; 清理参数

pt_null:
    add ebx, edx
    loop each_segment

    ret

MemCpy:
    push ebp
    mov ebp, esp
    push ecx

    mov edi, [ebp + 8]      ; dst
    mov esi, [ebp + 12]     ; src
    mov ecx, [ebp + 16]     ; size
    rep movsb		   ; 逐字节拷贝

    pop ecx
    pop ebp

    ret

err_code:
    jmp $


    ;         ELF文件格式
    ; -------------------------
    ; |       ELF Header      |
    ; | Program Header Table  |
    ; |       Section 1       |
    ; |       Section 2       |        
    ; |         ...           |
    ; |       Section n       |
    ; | Section Header Tbale  |
    ; -------------------------

;typedef struct elf32_hdr{                                                     size   0ffset
;     unsigned char e_ident[EI_NIDENT];     /* 魔数和相关信息 */                16       0
;     Elf32_Half    e_type;                 /* 目标文件类型 */                  2        16
;     Elf32_Half    e_machine;              /* 硬件体系 */                      2        18
;     Elf32_Word    e_version;              /* 目标文件版本 */                  4        20
;     Elf32_Addr    e_entry;                /* 程序进入点 */                    4        24
;     Elf32_Off     e_phoff;                /* 程序头部偏移量 */                4         28  
;     Elf32_Off     e_shoff;                /* 节头部偏移量 */                  4         32
;     Elf32_Word    e_flags;                /* 处理器特定标志 */                4         36
;     Elf32_Half    e_ehsize;               /* ELF头部长度 */                   2        40
;     Elf32_Half    e_phentsize;            /* 程序头部中一个条目的长度 */       2         42
;     Elf32_Half    e_phnum;                /* 程序头部条目个数  */             2         44
;     Elf32_Half    e_shentsize;            /* 节头部中一个条目的长度 */         2         46
;     Elf32_Half    e_shnum;                /* 节头部条目个数 */                2         48
;     Elf32_Half    e_shstrndx;             /* 节头部字符表索引 */              2         50
; } Elf32_Ehdr;

; typedef struct elf32_phdr{                                                        size     offset
;   Elf32_Word  p_type;                     /* 段类型 */                               4        0
;   Elf32_Off   p_offset;                   /* 段位置相对于文件开始处的偏移量 */         4        4     
;   Elf32_Addr  p_vaddr;                    /* 段在内存中的地址 */                      4        8
;   Elf32_Addr  p_paddr;                    /* 段的物理地址 */                          4       12 
;   Elf32_Word  p_filesz;                   /* 段在文件中的长度 */                      4        16
;   Elf32_Word  p_memsz;                    /* 段在内存中的长度 */                      4        20
;   Elf32_Word  p_flags;                    /* 段的标记 */
;   Elf32_Word  p_align;                    /* 段在内存中对齐标记 */
; } Elf32_Phdr;