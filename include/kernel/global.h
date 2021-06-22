#ifndef _KERNEL_GLOBAL_H_
#define _KERNEL_GLOBAL_H_

#include "stdint.h"

#define RPL0 0
#define RPL1 1
#define RPL2 2
#define RPL3 3

#define TI_GDT 0
#define TI_LDT 1

#define SELECTOR_KERNEL_CODE ((1 << 3) + (TI_GDT << 2) + RPL0)
#define SELECTOR_KERNEL_DATA ((2 << 3) + (TI_GDT << 2) + RPL0)
#define SELECTOR_KERNEL_STACK SELECTOR_KERNEL_DATA
#define SELECTOR_KERNEL_GS ((3 << 3) + (TI_GDT << 2) + RPL0)


#define IDT_DESC_P      1
#define IDT_DESC_DPL0   0
#define IDT_DESC_DPL3   3
#define IDT_DESC_32_TYPE    0xE

#define IDT_DESC_ATTR_DPL0 \
    ((IDT_DESC_P << 15) + (IDT_DESC_DPL0 << 13) + (IDT_DESC_32_TYPE << 8))

#define IDT_DESC_ATTR_DPL3 \
    ((IDT_DESC_P << 15) + (IDT_DESC_DPL3 << 13) + (IDT_DESC_32_TYPE << 8))

#endif