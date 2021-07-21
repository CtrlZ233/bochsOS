#!/bin/bash

MYDIR=$(dirname "$0")
DIRPRE=$MYDIR'/'

cd $DIRPRE'build' && cmake .. && make
#如果文件夹不存在，创建文件夹
if [ ! -d "obj" ]; then
  mkdir obj
fi
OBJDIR=$DIRPRE'build/obj'
cd .. 

nasm -f elf32 -o ./build/obj/print.o ./src/lib/print.asm
nasm -f elf32 -o ./build/obj/kernel.o ./src/kernel/kernel.asm

gcc -g -O0 -m32 -D NDEBUG -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/main.o ./src/kernel/main.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/init.o ./src/kernel/init.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/interrupt.o ./src/kernel/interrupt.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/timer.o ./src/kernel/timer.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/debug.o ./src/lib/debug.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/string.o ./src/lib/string.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/bitmap.o ./src/lib/bitmap.c
gcc -g -O0 -m32 -I ./include/ -c -fno-stack-protector -fno-builtin -o ./build/obj/memory.o ./src/kernel/memory.c
ld -m elf_i386 -Ttext 0x00001500 -e main -o ./build/bin/kernel.bin  ${OBJDIR}/main.o  ${OBJDIR}/init.o\
 ${OBJDIR}/interrupt.o ${OBJDIR}/timer.o ${OBJDIR}/print.o ${OBJDIR}/kernel.o  ${OBJDIR}/debug.o ${OBJDIR}/string.o \
 ${OBJDIR}/bitmap.o ${OBJDIR}/memory.o

mbr_path=$DIRPRE'build/bin/mbr.bin'
img_path=$DIRPRE"img/start.img"
wc -c ${mbr_path}
# dd if=/dev/zero of=${img_path} bs=512 count=256 seek=0 conv=notrunc
dd if=${mbr_path} of=${img_path} count=1 seek=0 conv=notrunc
dd if=./build/bin/bootLoader.bin of=./img/start.img count=10 seek=16 conv=notrunc
dd if=./build/bin/kernel.bin of=./img/start.img count=200 seek=32 conv=notrunc