#ifndef _KERNEL_MEMORY_H_
#define _KERNEL_MEMORY_H_

#include "./kernel/stdint.h"
#include "./lib/bitmap.h"

#define PG_SIZE                 4096
#define MEM_BITMAP_BASE         0xc009a000
#define KERNLE_HEAP_START       0xc0100000

#define PG_P_1                  1
#define PG_P_0                  0
#define PG_RW_R                 0
#define PG_RW_W                 2
#define PG_US_S                 0   // 系统级
#define PG_US_U                 4   // 用户级


#define PDE_IDX(addr)       ((addr & 0xFFC00000) >> 22)
#define PTE_IDX(addr)       ((addr & 0x003FF000) >> 12)

// ; ----------------------------------------------------------------------------------------------
// ; 页管理机制的相关数据结构，往上的内存区域作为可用内存交给内核统一管理
// ; ------------------------------------------0x100000-------------------------------------------
// ; ....
// ; -------------------------------------------0x9FC00-------------------------------------------
// ; 管理虚拟内存和物理内存的bitmap数据
// ; -------------------------------------------0x9A000-------------------------------------------
// ;
// ; 内核代码和数据区，此区域可以一直往上扩展
// ;
// ; --------------------------------------------0x1500-------------------------------------------
// ;
// ; bootloader代码区 (最多2560 B)
// ;
// ; ---------------------------------------------0xB00-------------------------------------------
// ; bootloader数据区，也是GDT、和内存布局等数据结构存放的地方
// ; ---------------------------------------------0x900-------------------------------------------
// ; 可用区域 (约 30 KB)
// ; ---------------------------------------------0x500-------------------------------------------
// ; BIOS数据区 (256 B)
// ; ---------------------------------------------0x400-------------------------------------------
// ; 中断向量表IVT (1 KB)
// ; ---------------------------------------------0x000-------------------------------------------

struct pool
{
    struct bitmap pool_bitmap_;
    uint32_t pddr_start_;       // 起始地址
    uint32_t pool_size_;        // 本内存池的容量
};

enum pool_flags {
    PF_KERNEL = 1,
    PF_USER = 2
};

struct virtual_addr
{
    struct bitmap vaddr_bitmap_;
    uint32_t vaddr_start_;
};

extern struct pool kernel_pool_, user_pool_;

void mem_init(void);


// 得到虚拟地址vaddr对应的pte指针
uint32_t* get_pte_ptr(uint32_t vaddr);

// 得到虚拟地址vaddr对应的pde指针 
uint32_t* get_pde_ptr(uint32_t vaddr);

// 分配pg_cnt个页空间
void* malloc_page(enum pool_flags pf, uint32_t pg_cnt);

// 从内核物理内存池中申请1页内存，返回虚拟地址
void* get_kernel_pages(uint32_t pg_cnt) ;

#endif