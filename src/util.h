/********************************************************************************
* JAM v1.0 - util.h                                                             *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef JAM_UTIL_H
#define JAM_UTIL_H

char get_scape(char c);
int strtobin(char *num);
char *copy_string(char *str);
int char_count(int n);
void print_string(char *str, FILE *fd);
int string_size(char *str);
#endif
