#include "print.h"
#include "init.h"
void main(void) {
	put_string("\n\n");
	put_string("I'm kernel\n");
	init_all();
	asm volatile ("sti");
	while(1);
}