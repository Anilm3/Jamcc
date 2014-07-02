#################################################################################
# JAM v1.0 - Makefile                                                           #
#                                                                               #
# Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       #
#                    Mikel Ganuza Estremera(migaes.mail@gmail.com               #
#                                                                               #
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> #
# This is free software: you are free to change and redistribute it.            #
# There is NO WARRANTY, to the extent permitted by law.                         #
#                                                                               #
#################################################################################
.SILENT:

CC = gcc
CFLAGS = -march=native -O3
LFLAGS = -lfl
FLEX = flex
BISON = bison

all: start jamcc clean

start:
	@echo JAM v1.0 Compiler Makefile
	
jamcc: lex.yy.c jam_sin.tab.c stack.c jamcc.c util.c
	$(CC) -o ../jamcc stack.c ast.c hashtbl.c lex.yy.c jam_sin.tab.c jamcc.c util.c
	@echo "[GCC]\tCompiler Compiled Succesfuly"
	
jam_sin.tab.c:
	$(BISON) -d jam_sin.y
	@echo "[Bison]\tGenerating LALR Parser"
	
lex.yy.c: jam_lex.l
	$(FLEX) jam_lex.l
	@echo "[Flex]\tGenerating Lexical Scanner"

clean:
	rm lex.yy.c jam_sin.tab.c jam_sin.tab.h
	@echo "[RM]\tCleaning Generated Source Files"
