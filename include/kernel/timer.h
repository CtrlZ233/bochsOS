#ifndef _KERNEL_TIMER_H_
#define _KERNEL_TIMER_H_

#define IRQ0_FREQUENCY      100
#define INPUT_FREQUENCY     1193180     // 8253的工作频率
#define COUNTER0_VALUE      INPUT_FREQUENCY / IRQ0_FREQUENCY
#define COUNTER0_PORT       0x40
#define COUNTER0_NO         0x0
#define COUNTER0_MODE       2           // 工作方式2：比率发生器
#define COUNTER0_RW         3           // 先读写低字节，后读写高字节

#define PIT_CONTROL_PORT    0x43        //　控制字寄存器的操作端口


void timer_init();
#endif