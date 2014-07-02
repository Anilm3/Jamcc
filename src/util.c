/********************************************************************************
* JAM v1.0 - util.c                                                             *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

#include "util.h"

/* Returns the corresponding scape character */
char get_scape(char c){
	switch(c){
		case 'a':
			return '\a';
			break;
		case 'b':
			return '\b';
			break;
		case 'f':
			return '\f';
			break;
		case 'n':
			return '\n';
			break;
		case 'r':
			return '\r';
			break;
		case 't':
			return '\t';
			break;
		case 'v':
			return '\v';
			break;
		case '\\':
			return '\\';
			break;
		case '\'':
			return '\'';
			break;
		case '\"':
			return '\"';
			break;
	}
}

/* Converts from binary string to integer */
int strtobin(char *num){
	int i = 0;
	int var = 0;
	while(num[i] != '\0'){
		var = var << 1;
		if(num[i++] == '1') var += 1;
	}
	return var;
}

/*Copies a literal string to real string representation */
char *copy_string(char *str){
	int i, j = 0;
	int n = strlen(str);
	char *ret_str, *aux_str = (char*)malloc(sizeof(char)*(n-1));
	for(i = 1; i < n-1; i++){
		switch(str[i]){
		case '\\':
			aux_str[j++] = get_scape(str[++i]);
			break;
		default:
			aux_str[j++] = str[i];
			break;
		}
	} 
	aux_str[j] = '\0';
	ret_str = strdup(aux_str);
	free(aux_str);
	return ret_str;
}

/* Counts the number of characters of an integer */
int char_count(int n){
	int i = 0;
	if(n > 0){
		while((n /= 10) > 0) i++;
	} else {
		while((n /= 10) < 0) i++;
	}
	return i + 1 ;
}

/* Counts the number of characters of a float */
int fchar_count(float n){
	int i = 0;
	while((n /= 10) > 0) i++;
	return i + 1 ;
}

/* Prints a literal string substituting scape sequences */
void print_string(char *str, FILE* fd){
	while(*str != '\0'){
		if(*str =='\\'){
			fprintf(fd, "\",%d,\"",get_scape(*(++str)));
		} else {
			fprintf(fd, "%c",*str);
		}
		str++;
	}
	fprintf(fd, ",0\n");
}

/* Returns the size of a literal string */
int string_size(char *str){
	int i, j = 0;
	int n = strlen(str);
	for(i = 1; i < n-1; i++){
		switch(str[i]){
		case '\\':
			i++;
			j++;
			break;
		default:
			j++;
			break;
		}
	} 
	return j;
}


