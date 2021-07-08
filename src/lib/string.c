#include "./lib/string.h"
#include "./kernel/stdint.h"
#include "./lib/debug.h"
#include "./kernel/global.h"

void memset(void *dst_, uint8_t value_, uint32_t size_) {
    ASSERT (dst_ != NULL);
    uint8_t *dst = (uint8_t *)dst_;
    while (size_--) {
        *dst++ = value_;
    }
}

void memcpy(void *dst_, const void *src_, uint32_t size_) {
    ASSERT (dst_ != NULL && src_ != NULL);
    uint8_t *dst = (uint8_t *)dst_;
    const uint8_t *src = (const uint8_t *)src_;
    while (size_--) {
        *dst++ = *src++;
    } 
}

int memcmp(const void *ptrA_, const void *ptrB_, uint32_t size_) {
    const char *a = ptrA_;
    const char *b = ptrB_;
    ASSERT (a != NULL && b != NULL);
    while (size_--) {
        if(*a != *b) {
            return *a > *b ? 1 : -1;
        }
        a++;
        b++;
    }
    return 0;
}

char* strcpy(char *dst_, const char *src_) {
    ASSERT (dst_ != NULL && src_ != NULL);
    char *r = dst_;
    while ((*dst_++ = *src_++));
    return r;
}

uint32_t strlen(const char *str_) {
    ASSERT (str != NULL);
    const char *p = str_;
    while (*p++);
    return (p - str_ - 1);
}

int8_t strcmp(const char *ptrA_, const char *ptrB_) {
    ASSERT (ptrA_ != NULL && ptrB_ != NULL);
    while (*ptrA_ != 0 && *ptrA_ == *ptrB_) {
        ptrA_++;
        ptrB_++;
    }
    return *ptrA_ < *ptrB_ ? -1 : (*ptrA_ > *ptrB_);
}

char* strchr(const char *str_, const uint8_t ch_) {
    ASSERT (str_ != NULL);
    while (*str_ != 0) {
        if (*str_ == ch_) {
            return (char *)str_;
        }
    }
    return NULL;
}

char* strrchr(const char *str_, const uint8_t ch_) {
    ASSERT (str_ != NULL);
    const char *last_char = NULL;
    while (*str_ != 0) {
        if (*str_ == ch_) {
            last_char = str_;
        }
        str_++;
    }
    return (char *)last_char;
}

char* strcat(char *dst_, const char *src_) {
    ASSERT (dst_ != NULL && src_ != NULL);
    char *str = dst_;
    while (*str++);
    --str;
    while ((*str++ = *src_++));
    return dst_;
}

uint32_t strchrs(const char *str_, uint8_t ch_) {
    ASSERT (str_ != NULL);
    uint32_t cnt = 0;
    while (*str_ != 0) {
        if (*str_ == ch_)
            cnt++;
        str_++;
    }
    return cnt;
}

