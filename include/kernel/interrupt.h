#ifndef _KERNEL_INTERRUPT_H_
#define _KERNEL_INTERRUPT_H_

#define IDT_DESC_CNT    0x21

#define PIC_M_CTRL  0x20
#define PIC_M_DATA  0x21
#define PIC_S_CTRL  0xA0
#define PIC_S_DATA  0xA1

#define EFLAGS_IF    0x00000200
#define GET_EFLAGS(EFLAG_VAR) asm volatile("pushfl; popl %0" : "=g" (EFLAG_VAR))


#include "stdint.h"
//  31-------------------16-------------------------0
//  |   程序偏移高16位      |       其他属性          |
//  |   程序段选择子        |      程序偏移的低16位    |
//  -------------------------------------------------
struct GateDesc {   
    uint16_t offset_low_16;
    uint16_t selector;
    uint16_t attribute;
    uint16_t offset_high_16;
};

void idt_init();        // 初始化IDT

enum intr_status {
    INTR_OFF,
    INTR_ON
};

enum intr_status get_intr_status();
enum intr_status set_intr_status(enum intr_status);
enum intr_status enable_intr();
enum intr_status disable_intr();

#endif