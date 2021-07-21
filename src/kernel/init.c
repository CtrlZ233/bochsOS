#include "./kernel/init.h"
#include "./lib/print.h"
#include "./kernel/interrupt.h"
#include "./kernel/timer.h"
#include "./kernel/memory.h"
void init_all() {
    put_string("init all\n");
    idt_init();
    timer_init();
    mem_init();
}