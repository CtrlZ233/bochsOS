#ifndef _KERNEL_INTERRUPT_H_
#define _KERNEL_INTERRUPT_H_

#include "stdint.h"
//  31-------------------16-------------------------0
//  |   程序偏移高16位      |       其他属性          |
//  |   程序段选择子        |      程序偏移的低16位    |
//  -------------------------------------------------
struct GateDesc
{   
    uint16_t offset_low_16;
    uint16_t selector;
    uint16_t attribute;
    uint16_t offset_high_16;
};

void idt_init();        // 初始化IDT

#endif