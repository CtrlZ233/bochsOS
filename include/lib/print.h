#ifndef _KERNEL_PRINT_H_
#define _KERNEL_PRINT_H_

#include "./kernel/stdint.h"

void put_char(uint8_t char_ascii);
void put_string(char* str);
void put_int(uint32_t num);
#endif