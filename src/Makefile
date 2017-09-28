# TODO(#25): Generate header dependencies for Makefile
#
# See `nasm -M` for more info on that
ASMS=$(shell ls | grep .asm)
OBS=$(ASMS:.asm=.o)

webapp: $(OBS)
	gcc $(OBS) -o webapp

%.o: %.asm
	nasm -f elf64 -g -F dwarf $<

.PHONY: clean

clean:
	rm -rf $(OBS) webapp
