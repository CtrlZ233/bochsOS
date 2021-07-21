#ifndef _KERNEL_MEMORY_H_
#define _KERNEL_MEMORY_H_

#include "./kernel/stdint.h"
#include "./lib/bitmap.h"

#define PG_SIZE                 4096
#define MEM_BITMAP_BASE         0xc009a000
#define KERNLE_HEAP_START       0xc0100000

struct pool
{
    struct bitmap pool_bitmap_;
    uint32_t pddr_start_;       // 起始地址
    uint32_t pool_size_;        // 本内存池的容量
};

struct virtual_addr
{
    struct bitmap vaddr_bitmap_;
    uint32_t vaddr_start_;
};

extern struct pool kernel_pool_, user_pool_;

void mem_init(void);

#endif