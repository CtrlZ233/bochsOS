#ifndef _LIB_DEBUG_H_
#define _LIB_DEBUG_H_
void panic_handler(char *filename, int line, const char *func, const char *condition);

#define PANIC(...) panic_handler(__FILE__, __LINE__, __func__, __VA_ARGS__)

#ifndef NDEBUG
    #define ASSERT(CONDITION) ((void)0)
#else
    #define ASSERT(CONDITION)               \
        if ((CONDITION)) {} else {          \
            PANIC(#CONDITION);              \
        }                                   
#endif
#endif