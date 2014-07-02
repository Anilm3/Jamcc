/********************************************************************************
* JAM v1.0 - stack.c                                                            *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include "stack.h"

/* Creation of new stack */
stack* stk_new(int size){
	stack *stk = malloc(sizeof(stack));
	stk->array = malloc(sizeof(void*)*size);
	stk->max_size = size;
	stk->size = 0;
	return stk;
}

/* Elimination of the stack */
void stk_free(stack *stk){
	free(stk->array);
	free(stk);
}

/* Size of the stack */
int stk_size(stack *stk){
	return stk->size;
}

/* Maximum size of the stack */
int stk_max_size(stack *stk){
	return stk->max_size;
}

/* Insert element on the top of the stack */
int stk_push(stack *stk ,void *data){
	if(stk->size < stk->max_size){
		stk->array[stk->size++] = data;
		return 0;
	}
	return -1;
}

/* Extract element from the top of the stack */
void* stk_pop(stack *stk){
	if(stk->size > 0){
		return stk->array[--stk->size];
	}
	return NULL;
}

