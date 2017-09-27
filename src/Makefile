OBS=$(shell ls | grep asm | xargs -Ixx basename xx .asm | xargs -Ixx echo xx)

webapp: $(OBS)
	gcc $(OBS) -o webapp

%.o: %.asm
	nasm -f elf64 -g -F dwarf $<

.PHONY: clean

clean:
	rm -rf $(OBS) webapp
