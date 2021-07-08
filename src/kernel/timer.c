#include "./kernel/timer.h"
#include "./kernel/io.h"
#include "./lib/print.h"

//         --------------控制字格式---------------
//         7    6    5    4    3    2    1    0
//         SC1  SC0  RW1  RW0  M2   M1   M0   BCD       
//         --------------控制字格式---------------


static void frequency_set(uint8_t counter_port, uint8_t counter_no, uint8_t rw1, 
                            uint8_t counter_mode, uint16_t counter_value) {
    // 写入控制字
    outb(PIT_CONTROL_PORT, (uint8_t)(counter_no << 6 | rw1 << 4 | counter_mode << 1));
    // 写入counter_value的低8位
    outb(counter_port, (uint8_t)counter_value);
    // 写入counter_value的高8位
    outb(counter_port, (uint8_t)counter_value >> 8);
}

void timer_init() {
    put_string("timer_init starting...\n");
    frequency_set(COUNTER0_PORT, COUNTER0_NO, COUNTER0_RW, COUNTER0_MODE, COUNTER0_VALUE);
    put_string("timer_init done.\n");
}