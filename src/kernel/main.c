#include "print.h"
void main(void) {
	put_char('b');
	put_char('o');
	put_char('c');
	put_char('h');
	put_char('s');
	put_char('O');
	put_char('S');
	put_char(':');
	put_char('\n');
	put_string("This project is dedicated to learning the basic framework of the operating system,"
				"involving the startup process, memory management, etc.\n");
	put_string("Welecome to the kernel's world!\n");
	while(1);
}