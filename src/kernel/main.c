#include "./lib/print.h"
#include "./kernel/init.h"
#include "./lib/debug.h"
void main(void) {
	put_string("\n\n");
	put_string("I'm kernel\n");
	init_all();
	ASSERT(1 == 2);
	// asm volatile ("sti");
	while(1);
}