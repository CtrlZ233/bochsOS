#ifndef _KERNEL_IO_H
#define _KERNEL_IO_H
#include "stdint.h"

// 向端口写入一个字节
static inline void outb (uint16_t port, uint8_t data) {
    asm volatile ( "outb %b0, %w1" : : "a" (data), "Nd" (port)); 
}

// 将addr起始的words_count个字写入端口port
static inline void outsw (uint16_t port, const void * addr, uint32_t words_count) {
    asm volatile ("cld; rep outsw " : "+S"(addr), "+c"(words_count): "d" (port) );
}

// 从端口port读入一个字节并返回
static inline uint8_t inb (uint16_t port) {
    uint8_t data;
    asm volatile ("inb %w1, %b0" : "=a"(data) : "Nd"(port));
    return data;
}

// 从端口port 读入words_count个字并写入addr
static inline void insw (uint16_t port, void* addr, uint32_t words_count) {
    asm volatile ("cld; rep insw" : "+D" (addr), "+c" (words_count) : "d" (port) : "memory");
}

#endif