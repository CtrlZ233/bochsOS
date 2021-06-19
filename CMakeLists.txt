cmake_minimum_required(VERSION 3.5)
project(MyOS)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
# set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS nasm asm S)
set(CMAKE_ASM_NASM_OBJECT_FORMAT bin)

# set(CMAKE_C_FLAGS "-no-pie")
set(CMAKE_C_FLAGS "-m32 -no-pie")
# set(CMAKE_C_FLAGS "-Ttext 0xc0001500 -e main")
set(CMAKE_ASM_NASM_FLAGS "-e")
# set(CMAKE_ASM_NASM_FLAGS "-g")
set(CMAKE_C_LINK_FLAGS "-m elf_i386 -Ttext 0xc0001500 -e main")
SET(CMAKE_C_LINK_EXECUTABLE "/usr/bin/ld <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET>")
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "nasm <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
ENABLE_LANGUAGE(ASM_NASM)
include_directories(  ${PROJECT_SOURCE_DIR}/include)
add_compile_options(-I ${CMAKE_CURRENT_SOURCE_DIR}/include/ )
include_directories(  ${PROJECT_SOURCE_DIR}/include)
add_executable(mbr src/boot/mbr.asm)
add_executable(bootLoader src/boot/bootloader.asm)

set_target_properties(mbr bootLoader
        PROPERTIES
        SUFFIX .bin
        )
