#include "./lib/bitmap.h"
#include "./lib/string.h"
#include "./lib/debug.h"
void bitmap_init(struct bitmap *btmpPtr_) {
    memset(btmpPtr_->bits, 0, btmpPtr_->btmp_byte_len);
}

bool bitmap_scan_test(struct bitmap *btmpPtr_, uint32_t bit_idx_) {
    uint32_t byte_idx = bit_idx_ / 8;
    uint32_t bit_odd = bit_idx_ % 8;
    return  (btmpPtr_->bits[byte_idx] & (BITMAP_MASK << bit_odd));
}

int bitmap_scan(struct bitmap *btmpPtr_, uint32_t cnt_) {
    ASSERT (btmpPtr_ != NULL);
    uint32_t bit_start_idx = 0;
    uint32_t bit_len = btmpPtr_->btmp_byte_len * 8;
    uint32_t cntTmp = cnt_;
    for(uint32_t idx = 0; idx < bit_len; ++idx) {
        if(cntTmp == 0) return bit_start_idx;
        if (!bitmap_scan_test(btmpPtr_, idx)) {
            cntTmp--;
        } else {
            bit_start_idx = idx + 1;
            cntTmp = cnt_;
        }
    }
    if (!cntTmp) {
        return bit_start_idx;
    }
    return -1;
}

void bitmap_set(struct bitmap *btmpPtr_, uint32_t bit_idx_, int8_t value) {
    ASSERT (btmpPtr_ != NULL && (value == 0 || value == 1));
    uint32_t byte_idx = bit_idx_ / 8;
    uint32_t bit_odd = bit_idx_ % 8;

    if (value) {
        btmpPtr_->bits[byte_idx] |=(BITMAP_MASK << bit_odd);
    } else {
        btmpPtr_->bits[byte_idx] &= ~(BITMAP_MASK << bit_odd);
    }
}
