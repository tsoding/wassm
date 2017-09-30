# TODO(#25): Generate header dependencies for Makefile
#
# See `nasm -M` for more info on that
ASM_FILES=$(wildcard src/*.asm)
OBJ_FILES=$(ASM_FILES:.asm=.o)

src/webapp: $(OBJ_FILES)
	gcc $(OBJ_FILES) -o src/webapp

%.o: %.asm
	nasm -Isrc/ -f elf64 -g -F dwarf $<

.PHONY: clean

clean:
	rm -rf $(OBJ_FILES) src/webapp
