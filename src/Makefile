webapp: main.o
	gcc main.o -o webapp

main.o: main.asm
	nasm -f elf64 -g -F dwarf main.asm
