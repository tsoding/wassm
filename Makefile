# TODO(#25): Generate header dependencies for Makefile
#
# See `nasm -M` for more info on that
CC=gcc
cc=nasm
OS := $(shell uname)

ASM_FILES=$(wildcard src/*.asm)
OBJ_FILES=$(ASM_FILES:.asm=.o)

TEST_ASM_FILES=$(wildcard test/*.asm)
TEST_OBJ_FILES=$(TEST_ASM_FILES:.asm=.o)



src/webapp: $(OBJ_FILES)
	$(CC) -no-pie $(OBJ_FILES) -o src/webapp

test/test: $(TEST_OBJ_FILES)
	$(CC) $(TEST_OBJ_FILES) -o test/test

%.o: %.asm
	$(cc) -Isrc/ -f elf64 -g -F dwarf $<

test: test/test
	./test/test

.PHONY: clean

clean:
	rm -rf $(OBJ_FILES) $(TEST_OBJ_FILES) src/webapp test/test
