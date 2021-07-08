#ifndef _LIB_STRING_H_
#define _LIB_STRING_H_
#include "./kernel/stdint.h"
/*
 * 对字符串操作的封装
 * 以及内存批量操作的封装
 */

void memset(void *dst_, uint8_t value_, uint32_t size_);

void memcpy(void *dst_, const void *src_, uint32_t size_);

int memcmp(const void *ptrA_, const void *ptrB_, uint32_t size_);

char* strcpy(char *dst_, const char *src_);

uint32_t strlen(const char *str_);

int8_t strcmp(const char *ptrA_, const char *ptrB_);

char* strchr(const char *str_, const uint8_t ch_);

char* strrchr(const char *str_, const uint8_t ch_);

char* strcat(char *dst_, const char *src_);

uint32_t strchrs(const char *str_, uint8_t ch_);
#endif