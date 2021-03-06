#include "./kernel/memory.h"
#include "./lib/print.h"
#include "./kernel/stdint.h"
#include "./lib/string.h"


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

// 申请pg_cnt个虚拟页，返回虚拟页的起始地址
static void * vaddr_get(enum pool_flags pf, uint32_t pg_cnt) {
    int vaddr_start = 0;
    int bit_idx_start = -1;
    uint32_t cnt = 0;
    if (PF_KERNEL == pf) {
        bit_idx_start = bitmap_scan(&kernel_vaddr_.vaddr_bitmap_, pg_cnt);
        if (-1 == bit_idx_start) {
            return NULL;
        }
        while (cnt < pg_cnt) {
            bitmap_set(&kernel_vaddr_.vaddr_bitmap_, bit_idx_start + cnt++, 1);
        }
        vaddr_start = kernel_vaddr_.vaddr_start_ + bit_idx_start * PG_SIZE;
    } else {
        // 用户内存池
    }
    return (void *)vaddr_start;
}

// 得到虚拟地址vaddr对应的pte指针
uint32_t* get_pte_ptr(uint32_t vaddr) {
    // 0xFFC00000是第一个页表的虚拟地址，对应的物理地址为0x101000
    uint32_t* pte = (uint32_t *)(0xFFC00000 + ((vaddr & 0xFFC00000) >> 10) + PTE_IDX(vaddr) * 4);
    
    return pte;
}

// 得到虚拟地址vaddr对应的pde指针 
uint32_t* get_pde_ptr(uint32_t vaddr) {
    // 0xFFFFF000是页目录表的起始虚拟地址，对应的物理地址为0x100000
    uint32_t* pde_ptr = (uint32_t*) ((0xFFFFF000) + PDE_IDX(vaddr) * 4);
    return pde_ptr;
}

// 分配一个物理页，返回页框的物理地址
static void* palloc(struct pool *m_pool) {
    int bit_idx = bitmap_scan(&m_pool->pool_bitmap_, 1);
    if (-1 == bit_idx) {
        return NULL;
    }
    bitmap_set(&m_pool->pool_bitmap_, bit_idx, 1);
    uint32_t page_phyaddr = bit_idx * PG_SIZE + m_pool->pddr_start_;
    return (void *)page_phyaddr;
} 

// 在页表中添加虚拟地址 vaddr与物理地址page_phyaddr的映射
static void page_table_add(void* vaddr, void* page_phyaddr) {
    // todo:
}

// 分配pg_cnt个页空间
void* malloc_page(enum pool_flags pf, uint32_t pg_cnt) {
    // todo:
    return NULL;
}

// 从内核物理内存池中申请1页内存，返回虚拟地址
void* get_kernel_pages(uint32_t pg_cnt) {
    // todo:
    return NULL;
}

void mem_init () {
    put_string("mem_init start...\n");
    uint32_t mem_bytes_total = (*((uint32_t *)(0xa00))); // 在bootloader的数据区存放了总内存大小
    put_string("totoal mem bytes: ");
    put_int(mem_bytes_total / 1024 / 1024);
    put_string(" MB.\n");
    mem_pool_init(mem_bytes_total);
    put_string("mem_init done!\n");
}