#ifndef _LIB_BITMAP_H_
#define _LIB_BITMAP_H_

#include "./kernel/global.h"
#define BITMAP_MASK 1
struct bitmap
{
    uint32_t btmp_byte_len;
    uint8_t *bits;
};

void bitmap_init(struct bitmap *btmpPtr_);

// 判断第bit_idx是否为1
bool bitmap_scan_test(struct bitmap *btmpPtr_, uint32_t bit_idx_);

// 找到连续cnt_个空闲位置，并返回第一个下标
int bitmap_scan(struct bitmap *btmpPtr_, uint32_t cnt_);

void bitmap_set(struct bitmap *btmpPtr_, uint32_t bit_idx, int8_t value);

#endif