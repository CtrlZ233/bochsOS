#include "./kernel/memory.h"
#include "./lib/print.h"
#include "./kernel/stdint.h"

struct pool kernel_pool_, user_pool_;
struct virtual_addr kernel_vaddr_;

static void mem_pool_init(uint32_t all_mem) {
    put_string("    mem_pool init start....\n");
    uint32_t page_table_size = PG_SIZE * 256;   // 已用的页表
    
    uint32_t used_mem = page_table_size + 0x100000;

    uint32_t free_mem = all_mem - used_mem;

    uint16_t all_free_pages = free_mem / PG_SIZE;

    uint16_t kernel_free_pages = all_free_pages / 2;
    uint16_t user_free_pages = all_free_pages - kernel_free_pages;

    uint32_t kernel_bitmap_length = kernel_free_pages / 8;
    uint32_t user_bitmap_length = user_free_pages / 8;

    uint32_t kernel_pool_start = used_mem;
    uint32_t user_pool_start = kernel_pool_start + kernel_free_pages * PG_SIZE;

    kernel_pool_.pool_size_ = kernel_free_pages * PG_SIZE;
    user_pool_.pool_size_ = user_free_pages * PG_SIZE;

    kernel_pool_.pddr_start_ = kernel_pool_start;
    user_pool_.pddr_start_ = user_pool_start;

    kernel_pool_.pool_bitmap_.bits = (void *) MEM_BITMAP_BASE;
    user_pool_.pool_bitmap_.bits = (void *) (MEM_BITMAP_BASE + kernel_bitmap_length);

    put_string("    kernel_pool_bitmap_start: ");
    put_int((int)kernel_pool_.pool_bitmap_.bits);
    put_string("\n");

    put_string("    user_pool_bitmap_start: ");
    put_int((int)user_pool_.pool_bitmap_.bits);
    put_string("\n");

    bitmap_init(&kernel_pool_.pool_bitmap_);
    bitmap_init(&user_pool_.pool_bitmap_);

    kernel_vaddr_.vaddr_bitmap_.btmp_byte_len = kernel_bitmap_length;
    kernel_vaddr_.vaddr_bitmap_.bits = (void *) (MEM_BITMAP_BASE + kernel_bitmap_length + user_bitmap_length);

    kernel_vaddr_.vaddr_start_ = KERNLE_HEAP_START;
    bitmap_init(&kernel_vaddr_.vaddr_bitmap_);
    put_string("    mem_pool_init down!\n");
}

void mem_init () {
    put_string("mem_init start...\n");
    uint32_t mem_bytes_total = (*((uint32_t *)(0xa00)));
    mem_pool_init(mem_bytes_total);
    put_string("mem_init done!\n");
}