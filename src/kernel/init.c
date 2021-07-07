#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
void init_all() {
    put_string("init all\n");
    idt_init();
    timer_init();
}