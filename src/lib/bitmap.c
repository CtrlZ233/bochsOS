#include "./lib/bitmap.h"
#include "./lib/string.h"
void bitmap_init(struct bitmap *btmpPtr_) {
    memset(btmpPtr_->bits, 0, btmpPtr_->btmp_byte_len);
}

bool bitmap_scan_test(struct bitmap *btmpPtr_, uint32_t bit_idx_) {
    uint32_t byte_idx = bit_idx_ / 8;
    uint32_t bit_odd = bit_idx_ % 8;
    return  (btmpPtr_->bits[byte_idx] & (BITMAP_MASK << bit_odd));
}
