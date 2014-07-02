/********************************************************************************
* JAM v1.0 - stack.h                                                            *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

/* Stack structure */
struct stack_ {
	int size;
	int max_size;
	void **array;
};

typedef struct stack_ stack;

/* Stack functions */
stack* stk_new(int);
void stk_free(stack *);
int stk_size(stack *);
int stk_max_size(stack *);
int stk_push(stack *,void *);
void* stk_pop(stack *);
