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


extern void *handle_entry_table[IDT_DESC_CNT];           // 处理函数的入口表，声明定义在kernel.S中
void *handle_func_table[IDT_DESC_CNT];                   // 处理函数表
static struct GateDesc IDT[IDT_DESC_CNT]; 

char *intr_name[IDT_DESC_CNT];          // 存储中断的名字

static void general_intr_handle(uint8_t intr_vec) {
    if (intr_vec == 0x27 || intr_vec == 0x2f) {
        // 伪中断无需处理
        // 伪中断：一类不希望被产生的硬件中断。 发生的原因有很多种，如中断线路上电气信号异常，或是中断请求设备本身有问题
        return;
    }
    put_string("int vector:  0x");
    put_int(intr_vec);
    put_char('\n');
}

static void exception_init() {
    for (int i = 0; i < IDT_DESC_CNT; ++i) {
        handle_func_table[i] = general_intr_handle;
        intr_name[i] = "unknown";
    }

    intr_name[0] = "#DE Divide Error";                      // ÷0错误
    intr_name[1] = "#DB Debug Exception";                   // 对代码进行单步调试
    intr_name[2] = "#NMI Interrupt";                        // 不可屏蔽中断
    intr_name[3] = "#BP BreakPoint Exception";              // 断点调试
    intr_name[4] = "#OF Overflow Exception";                // 溢出
    intr_name[5] = "#BR BOUND Range Exceeded Exception";    // 边界检测
    intr_name[6] = "#UD Invalid Opcode Exception";          // 非法操作码
    intr_name[7] = "#NM Device Not Available Exception";    // 用于支持协处理器（设备不可用）
    intr_name[8] = "#DF Double Fault Exception";            // 双重故障
    intr_name[9] = "Coprocessor Segment Overrun";           // 协处理器段越界
    intr_name[10] = "#TS Invalid TSS Exception";            // 无效TSS
    intr_name[11] = "#NP Segment Not Present";              // 段不存在
    intr_name[12] = "#SS Stack Fault Exception";            // 堆栈段异常（越界）
    intr_name[13] = "#GP General Protection Exception";     // 通用保护异常（其他的段异常）
    intr_name[14] = "#PF Page-Fault Exception";             // 缺页
    // intr_name[15] = ""                                   // 保留
    intr_name[16] = "#MF x87 FPU Floating-Point Error";     // 协处理器出错
    intr_name[17] = "#AC Alignment Check Exception";        // 对齐检查（操作数的地址没有被正确地排列）
    intr_name[18] = "#MC Machine-Check Exception";          // 机器检查（检测到CPU或总线错误）
    intr_name[19] = "#XF SIMD Floating-Point Exception";    // SIMD协处理器异常
    // 20 ~ 31 保留
}

static void make_int_desc(struct GateDesc* p_gdesc, uint16_t attr, void * handle_func) {
    handle_func = handle_func; 
    // put_int((uint32_t)handle_func);
    // put_char('\n');
    p_gdesc->offset_low_16 = (uint32_t)handle_func & 0xFFFF;
    p_gdesc->selector = SELECTOR_KERNEL_CODE;
    p_gdesc->attribute = attr;
    p_gdesc->offset_high_16 = ((uint32_t)handle_func & 0xFFFF0000) >> 16;
}

// 

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
        make_int_desc(&IDT[i], IDT_DESC_ATTR_DPL0, handle_entry_table[i]);
    }
    exception_init();
    
    // 初始化8259A
    pic_init();

    // 加载IDT
    uint64_t idt_operand = ((sizeof(IDT) - 1) | ((uint64_t)(uint32_t)IDT << 16));
    asm volatile("lidt %0" : : "m" (idt_operand));
    put_string("idt_init done.\n");
}

