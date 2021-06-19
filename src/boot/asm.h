#ifndef __BOOT_ASM_H__
#define __BOOT_ASM_H__

//      base 32位, lim 20位
/*
        ------------------------段描述符格式------------------------
        |31--------------24-23--22--21-20--19---16--15-14--13-12-11----8-7------------0|
        |   Base 31:24    | G |D/B| L |AVL|seglimit| P | DPL | S | Type |  Base 23:16  | 高字节
        |               Base 15:0                |            seglimit 15:0            | 低字节
        |31------------------------------------16-15----------------------------------0|
*/
//      P = 1, DPL = 00, S = 1
//      G = 1, D/B = 1, L = 0, AVL = 0
#define SEG_ASM(type, base, lim)       \ 
    dw ((lim) & 0xffff), ((base) & 0xffff)  \
    db (((base) >> 16) & 0xff), (0x90 | (type)),  \
        (0xc0 | (((lim) >> 16) & 0xf)), (((base) >> 24) & 0xff)

//      type的种类
#define STA_X       0x8         //  可执行段
#define STA_E       0x4         // 非可执行段
#define STA_C       0x4         // 只能执行段
#define STA_W       0x2         // 可写但不能执行
#define STA_R       0x2         // 可读可执行
#define STA_A       0x1         // 被访问

#endif