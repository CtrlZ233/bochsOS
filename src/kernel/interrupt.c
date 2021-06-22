#include "interrupt.h"
#include "stdint.h"
#include "global.h"
#include "print.h"
#include "io.h"

#define IDT_DESC_CNT    0x21

#define PIC_M_CTRL  0x20
#define PIC_M_DATA  0x21
#define PIC_S_CTRL  0xA0
#define PIC_S_DATA  0xA1


extern void* handle_func_table[IDT_DESC_CNT];           // 处理函数表，声明定义在kernel.S中
static struct GateDesc IDT[IDT_DESC_CNT]; 

static void make_int_desc(struct GateDesc* p_gdesc, uint16_t attr, void * handle_func) {
    handle_func = handle_func - 0xc0000000;  // 减掉段基址，得到偏移
    // put_int((uint32_t)handle_func);
    // put_char('\n');
    p_gdesc->offset_low_16 = (uint32_t)handle_func & 0xFFFF;
    p_gdesc->selector = SELECTOR_KERNEL_CODE;
    p_gdesc->attribute = attr;
    p_gdesc->offset_high_16 = ((uint32_t)handle_func & 0xFFFF0000) >> 16;
}

static void pic_init() {
    // 初始化主片
    outb(PIC_M_CTRL, 0x11);         // ICW1, 边沿触发，级联8259，需要ICM4
    outb(PIC_M_DATA, 0x20);         // ICW2, 起始中断号为0x20
    outb(PIC_M_DATA, 0x04);         // ICW3, IR2接从片
    outb(PIC_M_DATA, 0x01);         // ICW4, 8086模式，正常EOI

    // 初始化从片
    outb(PIC_S_CTRL, 0x11);         // ICW1, 边沿触发，级联8259，需要ICM4
    outb(PIC_S_DATA, 0x28);         // ICW2, 起始中断号为0x28
    outb(PIC_S_DATA, 0x02);         // ICW3, 设置从片连接到主片的IR2引脚
    outb(PIC_S_DATA, 0x01);         // ICW4, 8086模式，正常EOI

    // 打开主片上的IR0, 也就是目前只接受时钟产生的中断
    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);

    put_string("pic init done.\n");
}

void idt_init() {
    put_string("idt init start...\n");

    // 填充中断描述符表
    for (int i = 0; i < IDT_DESC_CNT; ++i) {
        make_int_desc(&IDT[i], IDT_DESC_ATTR_DPL0, handle_func_table[i]);
    }

    // 初始化8259A
    pic_init();

    // 加载IDT
    uint64_t idt_operand = ((sizeof(IDT) - 1) | ((uint64_t)(uint32_t)IDT << 16));
    asm volatile("lidt %0" : : "m" (idt_operand));
    put_string("idt_init done.\n");

}

