# TODO(#25): Generate header dependencies for Makefile
#
# See `nasm -M` for more info on that
ASM_FILES=$(wildcard src/*.asm)
OBJ_FILES=$(ASM_FILES:.asm=.o)

TEST_ASM_FILES=$(wildcard test/*.asm)
TEST_OBJ_FILES=$(TEST_ASM_FILES:.asm=.o)
TESTED_OBJ_FILES=src/http.o

CC = gcc

# $(call check_cc_option,<option>)
define check_cc_option
$(shell printf "int main(void){ return 0; }\n" \
        | $(CC) -Wall -Werror -x c $(1) -c - -o /dev/null 2> /dev/null \
        && printf -- "%s" $(1))
endef

LDFLAGS += $(call check_cc_option,-no-pie)

src/webapp: $(OBJ_FILES)
	gcc $(LDFLAGS) $(OBJ_FILES) -o src/webapp

test/test: $(TEST_OBJ_FILES) $(TESTED_OBJ_FILES)
	gcc $(TEST_OBJ_FILES) $(TESTED_OBJ_FILES) -o test/test

%.o: %.asm
	nasm -Isrc/ -Itest/ -f elf64 -g -F dwarf $<

test: test/test
	./test/test

.PHONY: clean

clean:
	rm -rf $(OBJ_FILES) $(TEST_OBJ_FILES) src/webapp test/test
