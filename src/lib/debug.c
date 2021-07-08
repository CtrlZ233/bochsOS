#include "./lib/debug.h"
#include "./lib/print.h"
#include "./kernel/interrupt.h"

void panic_handler(char *filename, int line, const char *func, const char *condition) {
    disable_intr();
    put_string("\n\n\n!!!! error!!!! \n");
    put_string("filename: ");
    put_string(filename);
    put_string("\n");

    put_string("line: 0x");
    put_int(line);
    put_string("\n");

    put_string("function: ");
    put_string((char *)func);
    put_string("\n");

    put_string("condition: ");
    put_string((char *)condition);
    put_string("\n");
    while(1);
}