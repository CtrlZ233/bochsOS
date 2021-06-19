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

nasm -f elf32 -o ./build/obj/print.o ./src/lib/kernel/print.asm
gcc -m32 -I ./include/kernel/ -c -o ./build/obj/main.o ./src/kernel/main.c
ld -m elf_i386 -Ttext 0xc0001500 -e main -o ./build/bin/kernel.bin  ${OBJDIR}/main.o ${OBJDIR}/print.o

mbr_path=$DIRPRE'build/bin/mbr.bin'
img_path=$DIRPRE"img/start.img"
wc -c ${mbr_path}
# dd if=/dev/zero of=${img_path} bs=512 count=256 seek=0 conv=notrunc
dd if=${mbr_path} of=${img_path} count=1 seek=0 conv=notrunc
dd if=./build/bin/bootLoader.bin of=./img/start.img count=10 seek=16 conv=notrunc
dd if=./build/bin/kernel.bin of=./img/start.img count=200 seek=32 conv=notrunc