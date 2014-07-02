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

all:
	$(MAKE) -C src
	
clean:
	rm jamcc
	@echo "[RM]\tCleaning Executable File"
	
correct:
	rm src/lex.yy.c src/jam_sin.tab.c src/jam_sin.tab.h jamcc
	@echo "[RM]\tCleaning Everything"
