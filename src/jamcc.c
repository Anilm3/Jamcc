/********************************************************************************
* JAM v1.0 - jamcc.c                                                            *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/
#include <getopt.h>
#include <unistd.h>
#include "util.h"
#include "jam_sin.tab.h"
#include "hashtbl.h"
#include "stack.h"
#include "ast.h"


FILE *fd;

/* Global and local symbols */
HASHTBL *symbols[2];

int var_id = 0;
int str_id = 0;
int fun_id = 0;
int loop_id = 0;
int loop_level = -1;
int swtch_id = 0;
int if_id = 0;
int brk_id = 0;
int esp, ebp;

/* Type for symbol information */
enum local_type_ { VARIABLE, PARAMETER, FUNCTION };
typedef enum local_type_ local_type;

/* Boolean type for symbol information */
enum boolean_ { NO, YES };
typedef enum boolean_ boolean;

/* Hash symbol structure */
struct var_info_ {
	char *name;
	local_type type;
	boolean vector;
	int offset;
	enum ast_subtype size;
};
typedef struct var_info_ var_info;

/* Register macros */
enum reg_name_ {NAR=-1, EAX=0, EBX=1, ECX=2, EDX=3};
typedef enum reg_name_ reg_name;

/* Register buffer */
int reg_buffer[4] = {0, 0, 0, 0};

/* Return string for given register number */
char* reg_string(reg_name reg) {
	switch(reg){
	case EAX:
		return "eax";
	case EBX:
		return "ebx";
	case ECX:
		return "ecx";
	case EDX:
		return "edx";
	default:
		return NULL;
	}
}

/* Allocate a given register */
reg_name reg_alloc(reg_name reg){
	reg_buffer[reg] = 1;
	return reg;
}

/* Obtain pseudorandom register */
/* In reality it's the next free */
/* register from the start */
reg_name reg_ralloc(){
	int i;
	for(i = 0; i < 4; i++)
		if(!reg_buffer[i]) {
			reg_buffer[i]++;
			return i;
		}
	return NAR;
}

/* Return next register */
reg_name reg_next(reg_name reg){
	return (++reg)%4;
}

/* Free register */
reg_name reg_free(reg_name reg){
	reg_buffer[reg] = 0;
}

/* State of the register */
int reg_state(reg_name reg){
	return reg_buffer[reg];
}

/* Returns register number for given string */
reg_name reg_number(char *reg){
	if(strcmp("eax", reg) == 0){
		return EAX;
	} else if(strcmp("ebx", reg) == 0){
		return EBX;
	} else if(strcmp("ecx", reg) == 0){
		return ECX;
	} else if(strcmp("edx", reg) == 0){
		return EDX;
	} else if(strcmp("al", reg) == 0){
		return EAX;
	} else if(strcmp("bl", reg) == 0){
		return EBX;
	} else if(strcmp("cl", reg) == 0){
		return ECX;
	} else if(strcmp("dl", reg) == 0){
		return EDX;
	} else {
		return -1;
	}
}
/* Returns lower order register */
char *reg_lower(reg_name reg){
	switch(reg){
	case EAX:
		return "al";
		break;
	case EBX:
		return "bl";
		break;
	case ECX:
		return "cl";
		break;
	case EDX:
		return "dl";
		break;
	default:
		return NULL;
	}
}

/* Count the number of characters of an integer*/

/* Create a new global symbol */
var_info *new_global_ident(char *name, 
											 char *prefix, 
											 int count,
											 local_type type,
											 boolean vector,
											 enum ast_subtype vsize){
	var_info *data = malloc(sizeof(var_info));
	if( prefix != NULL ){
		int size = char_count(count) + strlen(prefix) + 1;
		data->name = malloc(sizeof(char)*size);
		sprintf(data->name, "%s%d", prefix, count);
	} else {
		data->name = strdup(name);
	}
	
	data->type = type;
	data->vector = vector;
	data->size = vsize;
	
	if(name != NULL){
		hashtbl_insert(symbols[0], name, data);
	} else {
		hashtbl_insert(symbols[0], data->name, data);
	}
	
	return data;
}

var_info *get_global_ident(char *name){
	var_info *ident = hashtbl_get(symbols[0], name);
	return ident;
}
/* Destroy hash table contents and hash table */
symbols_destroy(HASHTBL *table){
	int i;
	for(i = 0; i < table->size; i++){
		struct hashnode_s *node=table->nodes[i];
		while(node) {
			var_info *data = node->data;
			if(data->name) free(data->name);
			free(data);
			node=node->next;
		}
	}
	hashtbl_destroy(table);
}

/* Generates BSS section of zero initialized variables */
void generate_bss(ast_node *tree){
	if(tree->type == AST_PROG){
		ast_node *node = tree->type_info[1];
		fprintf(fd, "section .bss\n");
		while(node){
			if(node->type_info == NULL){

				var_info *ident = new_global_ident(node->string, "var", var_id++, VARIABLE,
																					(node->integer>0?YES:NO), node->subtype);
				int size = (node->integer > 0 ? node->integer : 1);

				if(node->subtype == AST_INT || node->subtype == AST_FLOAT){
					fprintf(fd,"\t%s\tresd %d\n",ident->name, size);
				} else {
					fprintf(fd,"\t%s\tresb %d\n", ident->name, size);
				}
			}
			node = node->sibling;
		}
		fprintf(fd,"\n");
	}
}


/* Creating global symbols for strings and compressing constant operations */
void tree_data_compress(ast_node *tree){

		switch(tree->type){
		case AST_FUN:
			{
				ast_node *aux, *aux2, *node;
				if(tree->type_info){
					aux = node = tree->type_info[1];
					while(node){
						/* Creating global symbols for string variables */
						if(node->subtype == AST_STRING){
							if(node == tree->type_info[1]){
								tree->type_info[1] = node->sibling;
							} else {
								aux->sibling = node->sibling;
							}
							var_info *ident = new_global_ident(node->string, "var", var_id++,
																								 VARIABLE, YES, AST_STRING);
							fprintf(fd,"\t%s\tdb", ident->name);
							print_string(node->type_info[0]->string, fd);
							aux2 = node->sibling;
							/* Deleting useless node */
							free(node->string);
							free(node->type_info[0]->string);
							free(node->type_info[0]);
							free(node->type_info);
							free(node);
							node = aux2;
						} else {
							aux = node;
							node = node->sibling;
						}
						
					}
				}
				
				node = tree->content;
				while(node){
					/* Compressing content */
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_FOR:
			{
				/* Passing through, no significant operation */
				if(tree->type_info){
					tree_data_compress(tree->type_info[0]);
					tree_data_compress(tree->type_info[1]);
					tree_data_compress(tree->type_info[2]);
				}
			
				ast_node *node = tree->content;
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_WHILE:
			{
				/* Passing through, no significant operation */
				if(tree->type_info){
					tree_data_compress(tree->type_info[0]);
				}
			
				ast_node *node = tree->content;
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_IF:
			{
				/* Passing through, no significant operation */
				ast_node *node = tree->content;
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
				
				if(tree->type_info){
					tree_data_compress(tree->type_info[0]);
					node = tree->type_info[1];
					while(node){
						tree_data_compress(node);
						node = node->sibling;
					}
				}
			}
			break;
		case AST_ELSIF:
			{
				/* Passing through, no significant operation */
				ast_node *node = tree->content;
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
				if(tree->type_info){
					tree_data_compress(tree->type_info[0]);
				}
			}
			break;
		case AST_SWITCH:
			/* Passing through, no significant operation */
			if(tree->type_info){
				tree_data_compress(tree->type_info[0]);
				ast_node *node = tree->type_info[1];
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_OUT:
			if(tree->type_info){
				/* Creating printf string */
				int size = 0;
				ast_node *node = tree->type_info[0];
				char *fmt = malloc(sizeof(char)*67);
				fmt[0] = '\"';
				fmt[1] = '\0';
				while(node){
					size++;
					tree_data_compress(node);
					switch(node->subtype){
					case AST_STRING:
						if(node->type_info)
							strcat(fmt, "%c");
						else
							strcat(fmt, "%s");
						break;
					case AST_FLOAT:
						size++;
						strcat(fmt, "%f");
						break;
					case AST_BOOL:
					case AST_INT:
						strcat(fmt, "%d");
						break;
					case AST_CHAR:
						if(node->type == AST_CONST){
							strcat(fmt, "%c");
						} else {
							if(node->integer > 0){
								if(node->type_info)
									strcat(fmt, "%c");
								else
									strcat(fmt, "%s");
							} else strcat(fmt, "%c");
						}
						break;
					}
					node = node->sibling;
				}
				strcat(fmt,"\"");
				/* Adding new symbol for printf string */
				var_info *ident = new_global_ident(NULL, "str", str_id++,
																				VARIABLE, YES, AST_STRING);
				fprintf(fd,"\t%s\tdb %s,0\n", ident->name, fmt);
				/* Adding node to operator content */
				tree->content = ast_node_create(AST_IDENT, AST_STRING, 
									strdup(ident->name), size, 0, NULL, NULL, NULL);
				free(fmt);
			}
			break;
		case AST_RET:
		case AST_PROG:
		case AST_FUNCALL:
		case AST_B_ASIG:
				/* Passing through, no significant operation */
			if(tree->type_info){
				ast_node *node = tree->type_info[0];
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_ELSE:
		case AST_CASE:
		case AST_DEFAULT:
		case AST_EXPR:
			{
				/* Passing through, no significant operation */
				ast_node *node = tree->content;
				while(node){
					tree_data_compress(node);
					node = node->sibling;
				}
			}
			break;
		case AST_B_MUL:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real * node->sibling->real;
						} else {
							tree->integer = node->integer * node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					} 
				}
			}
			break;
		case AST_B_DIV:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real / node->sibling->real;
						} else {
							tree->integer = node->integer / node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_MOD:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer % node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_SUM:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real + node->sibling->real;
						} else {
							tree->integer = node->integer + node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_MIN:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real - node->sibling->real;
						} else {
							tree->integer = node->integer - node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_SRGT:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer >> node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_SLFT:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer << node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_GEQ:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real >= node->sibling->real;
						} else {
							tree->integer = node->integer >= node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_SEQ:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real <= node->sibling->real;
						} else {
							tree->integer = node->integer <= node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_GT:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real > node->sibling->real;
						} else {
							tree->integer = node->integer > node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_ST:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real < node->sibling->real;
						} else {
							tree->integer = node->integer < node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_NEQ:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real != node->sibling->real;
						} else {
							tree->integer = node->integer != node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_EQ:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real == node->sibling->real;
						} else {
							tree->integer = node->integer == node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_ORB:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer | node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_ANDB:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer & node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_XOR:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						tree->integer = node->integer ^ node->sibling->integer;
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_OR:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real || node->sibling->real;
						} else {
							tree->integer = node->integer || node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;
		case AST_B_AND:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				tree_data_compress(node->sibling);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->sibling->type == AST_CONST){
						if(node->subtype == AST_FLOAT){
							tree->real = node->real && node->sibling->real;
						} else {
							tree->integer = node->integer && node->sibling->integer;
						}
						tree->type = AST_CONST;
						tree->subtype = node->subtype;
						free(node->sibling);
						free(node);
						free(tree->type_info);
					}
				}
			}
			break;

		case AST_IN:
			/* Compressing operand */
			tree_data_compress(tree->type_info[0]);
			break;
		case AST_U_POS:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);

				/* Compressing null operation */
				tree->type = node->type;
				tree->subtype = node->subtype;
				tree->string = node->string;
				tree->integer = node->integer;
				tree->real = node->real;
				free(tree->type_info);
				tree->type_info = node->type_info;
				tree->content = node->content;
				tree->sibling = node->sibling;
				free(node);
			}
			break;
		case AST_U_MIN:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);

				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->subtype == AST_FLOAT){
						tree->real = -node->real;
					} else {
						tree->integer = -node->integer;
					}
					tree->type = AST_CONST;
					tree->subtype = node->subtype;
					free(node);
					free(tree->type_info);
				}
			}
			break;
		case AST_U_NEG:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				/* Compressing constant operation */
				if(node->type == AST_CONST){
					if(node->subtype == AST_FLOAT){
						tree->real = !node->real;
					} else {
						tree->integer = !node->integer;
					}
					tree->type = AST_CONST;
					tree->subtype = node->subtype;
					free(node);
					free(tree->type_info);
				}
			}
			break;
		case AST_U_NEGB:
			{
				/* Compressing operands */
				ast_node *node = tree->type_info[0];
				tree_data_compress(node);
				/* Compressing constant operation */
				if(node->type == AST_CONST){
					tree->integer = ~node->integer;
					tree->type = AST_CONST;
					tree->subtype = node->subtype;
					free(node);
					free(tree->type_info);
				}
			}
			break;
		case AST_CONST:
			if(tree->subtype == AST_STRING){
				/* Creating a new global symbol for string constant */
				var_info *ident = new_global_ident(NULL, "str", str_id++,
																					VARIABLE, YES, AST_STRING);
				fprintf(fd,"\t%s\tdb ", ident->name);
				print_string(tree->string,fd);
				/* Creating identifier for new symbol */
				tree->type = AST_IDENT;
				free(tree->string);
				tree->string = strdup(ident->name);
			}
			break;
		}
}


/* Generates DATA section of user initialized variables */
void generate_data(ast_node *tree){
	if(tree->type == AST_PROG){
		int i, j;
		ast_node *node = tree->type_info[1];
		/* Data section header */
		fprintf(fd, "section .data\n");
		while(node){
			if(node->type_info != NULL){
				/* Creating new symbol */
				var_info *ident = new_global_ident(node->string, "var", var_id++, VARIABLE,
																					(node->integer>0?YES:NO), node->subtype);
				/* Printing size and name */
				if(node->subtype == AST_INT || node->subtype == AST_FLOAT){
					fprintf(fd,"\t%s\tdd ",ident->name);
				} else {
					fprintf(fd,"\t%s\tdb ", ident->name);
				}
				
				/* Printing initializators */
				ast_node *info = node->type_info[0];
				int n = ( node->integer == 0 ? 1 : node->integer); 
				for(i = 0; i < n ; i++){
					switch(info->subtype){
					case AST_INT:
						if(i == (node->integer -1) || node->integer == 0)
							fprintf(fd,"%d\n", info->integer);
						else
							fprintf(fd,"%d, ", info->integer);
						break;
					case AST_CHAR:
						if(i == (node->integer -1) || node->integer == 0)
							fprintf(fd,"%d\n", (char)info->integer);
						else
							fprintf(fd,"%d, ", (char)info->integer);
						break;
					case AST_BOOL:
						if(i == (node->integer -1) || node->integer == 0)
							fprintf(fd,"%d\n", (info->integer > 0 ? 1 : 0));
						else
							fprintf(fd,"%d, ", (info->integer > 0 ? 1 : 0));
						break;
					case AST_FLOAT:
						if(i == (node->integer -1) || node->integer == 0)
							fprintf(fd,"%f\n", info->real);
						else
							fprintf(fd,"%f, ", info->real);
						break;
					case AST_STRING:
						print_string(info->string, fd);
						break;
					}
					info = info->sibling;
				}
			}
			node = node->sibling;
		}
		/* Ready for tree compression */
		tree_data_compress(tree);
	}
}

void gen_text_expr(ast_node *tree, reg_name reg, int offset);

void gen_text_var_read(ast_node *ident, reg_name reg, int offset){
	var_info *info = get_global_ident(ident->string);
	/* If global variable */
	if(info != NULL){
		/* If vector*/
		if(info->vector == YES){
			/* If indexed */
			if(ident->type_info != NULL){
				/* Indexed, loading vector position */
				ast_node *index = ident->type_info[0];
				gen_text_expr(index, reg, offset);
				switch(ident->subtype){
				case AST_FLOAT:
				case AST_INT:
					fprintf(fd, "\tsal %s, 2\n", reg_string(reg));
					fprintf(fd, "\tmov %s, dword [%s + %s]\n", reg_string(reg), info->name, reg_string(reg));
					break;
				case AST_BOOL:
				case AST_CHAR:
				case AST_STRING:
					fprintf(fd, "\tmovsx %s, byte [%s + %s]\n", reg_string(reg), info->name, reg_string(reg));
					break;
				}
			} else { 
				/* Not indexed, loading vector pointer */
				fprintf(fd, "\tmov %s, dword %s\n", reg_string(reg), info->name);
			}
		} else {
			switch(ident->subtype){
			case AST_FLOAT:
			case AST_INT:
				fprintf(fd, "\tmov %s, dword [%s]\n", reg_string(reg), info->name);
				break;
			case AST_BOOL:
			case AST_CHAR:
			case AST_STRING:
				fprintf(fd, "\tmovsx %s, byte [%s]\n", reg_string(reg), info->name);
				break;
			}
		}
	} else {
		info = hashtbl_get(symbols[1], ident->string);
		/* If vector*/
		if(info->vector == YES){
			/* If indexed */
			if(ident->type_info != NULL){
				/* Indexed, loading vector position */
				ast_node *index = ident->type_info[0];
				gen_text_expr(index, reg, offset);

				switch(ident->subtype){
				case AST_FLOAT:
				case AST_INT:
					if(info->type == VARIABLE){
						fprintf(fd, "\tsal %s, 2\n", reg_string(reg));
						fprintf(fd, "\tmov %s, dword [esp + %d + %s]\n",reg_string(reg), info->offset + offset, reg_string(reg));
					} else {
						fprintf(fd, "\tsal %s, 2\n", reg_string(reg));
						fprintf(fd, "\tadd %s, dword [ebp + %d]\n",reg_string(reg), info->offset);
						fprintf(fd, "\tmov %s, dword [%s]\n", reg_string(reg), reg_string(reg));
					}
					break;
				case AST_BOOL:
				case AST_CHAR:
				case AST_STRING:
					if(info->type == VARIABLE){
						fprintf(fd, "\tmovsx %s, byte [esp + %d + %s]\n",reg_string(reg), info->offset + offset, reg_string(reg));
					} else {
						fprintf(fd, "\tadd %s, dword [ebp + %d]\n",reg_string(reg), info->offset);
						fprintf(fd, "\tmovsx %s, byte [%s]\n", reg_string(reg), reg_string(reg));
					}
					break;
				}
			} else { 
				/* Not indexed, loading vector pointer */
				if(info->type == VARIABLE){
					fprintf(fd, "\tlea %s, [esp + %d]\n", reg_string(reg), info->offset + offset);
				} else {
					fprintf(fd, "\tmov %s, dword [ebp + %d]\n", reg_string(reg), info->offset);
				}
			}
		} else {
			switch(ident->subtype){
			case AST_FLOAT:
			case AST_INT:
				if(info->type == VARIABLE){
					fprintf(fd, "\tmov %s, dword [esp + %d]\n",reg_string(reg), info->offset + offset);
				} else {
					fprintf(fd, "\tmov %s, dword [ebp + %d]\n",reg_string(reg), info->offset);
				}
				break;
			case AST_BOOL:
			case AST_CHAR:
			case AST_STRING:
				if(info->type == VARIABLE){
					fprintf(fd, "\tmovsx %s, byte [esp + %d]\n",reg_string(reg), info->offset + offset);
				} else {
					fprintf(fd, "\tmovsx %s, byte [ebp + %d]\n",reg_string(reg), info->offset);
				}
				break;
			}
		}
	}
}

void gen_text_var_write(ast_node *ident, reg_name reg, int offset){
	int pushed = 0;
	reg_name reg2;
	var_info *info = get_global_ident(ident->string);
	/* If global variable */
	if(info != NULL){
		/* If vector*/
		if(info->vector == YES){
			/* If indexed */
			if(ident->type_info != NULL){
				/* Indexed, loading vector position */
				ast_node *index = ident->type_info[0];
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				gen_text_expr(index, reg2, offset);
				switch(ident->subtype){
				case AST_FLOAT:
				case AST_INT:
					fprintf(fd, "\tsal %s, 2\n", reg_string(reg2));
					fprintf(fd, "\tmov dword [%s + %s], %s\n", info->name, reg_string(reg2), reg_string(reg));
					break;
				case AST_BOOL:
				case AST_CHAR:
				case AST_STRING:
					fprintf(fd, "\tmov byte [%s + %s], %s\n", info->name, reg_string(reg2), reg_lower(reg));
					break;
				}
			
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
			} else { 
				/* Not indexed, loading vector pointer */
				fprintf(fd, "\tmov dword %s, %s\n", info->name, reg_string(reg));
			}
		} else {
			switch(ident->subtype){
			case AST_FLOAT:
			case AST_INT:
				fprintf(fd, "\tmov dword [%s], %s\n", info->name, reg_string(reg));
				break;
			case AST_BOOL:
			case AST_CHAR:
			case AST_STRING:
				fprintf(fd, "\tmov byte [%s], %s\n", info->name, reg_lower(reg));
				break;
			}
		}
	} else {
		info = hashtbl_get(symbols[1], ident->string);
		/* If vector*/
		if(info->vector == YES){
			/* If indexed */
			if(ident->type_info != NULL){
				/* Indexed, loading vector position */
				ast_node *index = ident->type_info[0];
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				gen_text_expr(index, reg2, offset);

				switch(ident->subtype){
				case AST_FLOAT:
				case AST_INT:
					if(info->type == VARIABLE){
						fprintf(fd, "\tsal %s, 2\n", reg_string(reg2));
						fprintf(fd, "\tmov dword [esp + %d + %s], %s\n", info->offset + offset, reg_string(reg2), reg_string(reg));
					} else {
						fprintf(fd, "\tsal %s, 2\n", reg_string(reg2));
						fprintf(fd, "\tadd %s, dword [ebp + %d]\n",reg_string(reg2), info->offset);
						fprintf(fd, "\tmov dword [%s], %s\n", reg_string(reg2), reg_string(reg));
					}
					break;
				case AST_BOOL:
				case AST_CHAR:
				case AST_STRING:
					if(info->type == VARIABLE){
						fprintf(fd, "\tmov byte [esp + %d + %s], %s\n", info->offset + offset, reg_string(reg2),reg_lower(reg));
					} else {
						fprintf(fd, "\tadd %s, dword [ebp + %d]\n",reg_string(reg2), info->offset);
						fprintf(fd, "\tmov byte [%s], %s\n", reg_string(reg2), reg_lower(reg));
					}
					break;
				}
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
			} else { 
				/* Not indexed, loading vector pointer */
				if(info->type == VARIABLE){
					fprintf(fd, "\tlea [esp + %d], %s\n", info->offset + offset, reg_string(reg));
				} else {
					fprintf(fd, "\tmov dword [ebp + %d], %s\n", info->offset, reg_string(reg));
				}
			}
		} else {
			switch(ident->subtype){
			case AST_FLOAT:
			case AST_INT:
				if(info->type == VARIABLE){
					fprintf(fd, "\tmov dword [esp + %d], %s\n", info->offset + offset, reg_string(reg));
				} else {
					fprintf(fd, "\tmov dword [ebp + %d], %s\n", info->offset, reg_string(reg));
				}
				break;
			case AST_BOOL:
			case AST_CHAR:
			case AST_STRING:
				if(info->type == VARIABLE){
					fprintf(fd, "\tmov byte [esp + %d], %s\n", info->offset + offset, reg_lower(reg));
				} else {
					fprintf(fd, "\tmov byte [ebp + %d], %s \n", info->offset, reg_lower(reg));
				}
				break;
			}
		}
	}
}

void gen_text_io(ast_node *tree){
	if(tree->type == AST_OUT){
		ast_node *node = tree->content;
		int i = 0, p_offset = node->integer*4+4;
		fprintf(fd, "\n\t;Print routine\n");
		fprintf(fd, "\tsub esp, %d\n", p_offset);
		node = tree->type_info[0];
		while(node){
			i+=4;
			/* Printing variable */
			if(node->type == AST_IDENT){
				switch(node->subtype){
				case AST_INT:
					reg_alloc(EAX);
					gen_text_var_read(node, EAX, p_offset);
					reg_free(EAX);
					fprintf(fd, "\tmov dword [esp + %d], eax\n", i);
					break;
				case AST_FLOAT:
					reg_alloc(EAX);
					gen_text_var_read(node, EAX,p_offset);
					reg_free(EAX);
					fprintf(fd, "\tmov dword [esp + %d], eax\n", i);
					fprintf(fd, "\tfld dword [esp + %d]\n", i);
					fprintf(fd, "\tfstp qword [esp + %d]\n", i);
					i+=4;
					break;
				case AST_BOOL:
				case AST_CHAR:
				case AST_STRING:
					reg_alloc(EAX);
					gen_text_var_read(node, EAX, p_offset);
					reg_free(EAX);
					fprintf(fd, "\tmov dword [esp + %d], eax\n", i);
					break;
				}
			} else {
				/* Printing constant */
				switch(node->subtype){
				case AST_BOOL:
				case AST_CHAR:
				case AST_INT:
					fprintf(fd, "\tmov eax, dword %d\n",node->integer);
					fprintf(fd, "\tmov dword [esp + %d], eax\n", i);
					break;
				case AST_FLOAT:
					{
						int *number = (int*)&node->real;
						fprintf(fd, "\tmov eax, dword %d\n", *number);
						fprintf(fd, "\tmov dword [esp + %d], eax\n", i);
						fprintf(fd, "\tfld dword [esp + %d]\n", i);
						fprintf(fd, "\tfstp qword [esp + %d]\n", i);
						i+=4;
					}
					break;
				}
			}
			node = node->sibling;
		}
		node = tree->content;
		fprintf(fd, "\tmov eax, dword %s\n",node->string);
		fprintf(fd, "\tmov dword [esp], eax\n");
		fprintf(fd, "\tcall printf\n");
		fprintf(fd, "\tadd esp, %d\n", p_offset);
		fprintf(fd, "\t;End Print routine\n");
	} else {
		/* Getchar routine is very simple */
		fprintf(fd, "\n\t;Scan char routine\n");
		ast_node *node = tree->type_info[0];
		/* Input variable */
		var_info *info = get_global_ident(node->string);
		/* Function call */
		fprintf(fd, "\tcall getchar\n");
		/* Writing to register */
		gen_text_var_write(tree->type_info[0], EAX,0);
	}
}

void gen_text_expr(ast_node *tree, reg_name reg, int offset){

	switch(tree->type){
	case AST_EXPR:
		gen_text_expr(tree->content, reg, offset);
		break;
	case AST_B_ASIG:
		{	/* Generating asign expression */
			gen_text_expr(tree->type_info[0]->sibling, reg, offset);
			if(tree->subtype == AST_BOOL){
				/* Bool expression 0 or 1 */
				fprintf(fd, "\tcmp %s, 0\n", reg_string(reg));
				fprintf(fd, "\tsetg %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
			}
			/* Writing result to variable */
			gen_text_var_write(tree->type_info[0], reg, offset);
			/* Returning result */
			gen_text_var_read(tree->type_info[0], reg, offset);
		}
		break;
	case AST_IDENT:
		/* Reading variable */
		gen_text_var_read(tree, reg, offset);
		break;
	case AST_FUNCALL:
		{	
			int pushed = 0;
			if(reg_state(EAX) != 0 && reg != EAX) {
				/* Inserting register in memory temporarily */
				fprintf(fd, "\tpush eax\n");
				pushed++;
				offset+=4;
			}
			var_info *info = get_global_ident(tree->string);
			if(tree->type_info){
				/* Inverting parameters print order using stack */
				ast_node *node = tree->type_info[0];
				stack *stk_info = stk_new(256);
				while(node){
					stk_push(stk_info, node);
					node = node->sibling;
				}
				while(node = stk_pop(stk_info)){
					gen_text_expr(node, reg, offset);
					fprintf(fd, "\tpush %s\n", reg_string(reg));
					offset += 4;
				}
				stk_free(stk_info);
			}
			/* Function call */
			fprintf(fd, "\tcall %s\n", info->name);
			fprintf(fd, "\tmov %s, eax\n", reg_string(reg));
			if(pushed > 0){
				/* Recovering register from memory */
				fprintf(fd, "\tpop eax\n");
				offset-=4;
				pushed--;
			}
		}
		break;
	case AST_CONST:
		switch(tree->subtype){
		case AST_BOOL:
			fprintf(fd, "\tmov %s, %d\n", reg_string(reg), tree->integer);
			break;
		case AST_CHAR:
			fprintf(fd, "\tmov %s, %d\n", reg_string(reg), tree->integer);
			break;
		case AST_INT:
			fprintf(fd, "\tmov %s, %d\n", reg_string(reg), tree->integer);
			break;
		case AST_FLOAT:
			{
				int *number = (int*)&tree->real;
				fprintf(fd, "\tmov %s, %d\n", reg_string(reg), *number);
			}
			break;
		}
		break;
	case AST_B_SUM:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Standard add */
				fprintf(fd, "\tadd %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_MIN:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Standard sub */
				fprintf(fd, "\tsub %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_MUL:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Signed multiplication */
				fprintf(fd, "\timul %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_DIV:
		{
			reg_name reg2;
			int eax_push = 0;
			int edx_push = 0;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* We need eax and edx registers because idiv operation
				  expects it that way */
				if(reg == EAX){ /* If result expected in eax */
					if(reg_state(EDX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush edx\n");
						edx_push++;
						offset+=4;
					}
					reg_alloc(EDX);
					/* Generating first operand */
					gen_text_expr(par1, reg, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					reg2 = reg_ralloc();
					if(reg2 == NAR){
						/* Inserting register in memory temporarily */
						reg2 = reg_next(reg);
						fprintf(fd, "\tpush %s\n", reg_string(reg2));
						pushed++;
						offset+=4;
					}
					
					/* Generating second  operand */
					gen_text_expr(par2, reg2, offset);
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg2));
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(pushed > 0){
						fprintf(fd, "\tpop %s\n", reg_string(reg2));
						pushed--;
						offset-=4;
					} else reg_free(reg2);
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(edx_push > 0){
						offset-=4;
						edx_push = 0;
						fprintf(fd, "\tpop edx\n");
					} else reg_free(EDX);
				} else if(reg == EDX){ /* If result expected in edx */
					if(reg_state(EAX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush eax\n");
						eax_push++;
						offset+=4;
					}
					reg_alloc(EAX);
					/* Generating first operand */
					gen_text_expr(par1, EAX, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					reg2 = reg_ralloc();
					if(reg2 == NAR){
						/* Inserting register in memory temporarily */
						reg2 = EBX;
						fprintf(fd, "\tpush %s\n", reg_string(reg2));
						pushed++;
						offset+=4;
					}
					
					/* Generating second  operand */
					gen_text_expr(par2, reg2, offset);
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg2));
					fprintf(fd, "\tmov edx, eax\n");
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(pushed > 0){
						fprintf(fd, "\tpop %s\n", reg_string(reg2));
						pushed--;
						offset-=4;
					} else reg_free(reg2);
					/* Restoring memory register or freeing the one alloc'ed */
					if(eax_push > 0){
						fprintf(fd, "\tpop eax\n");
						eax_push = 0;
						offset-=4;
					} else reg_free(EAX);
				} else { /* If result expected in another register */
					if(reg_state(EDX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush edx\n");
						edx_push++;
						offset+=4;
					}
					if(reg_state(EAX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush eax\n");
						eax_push++;
						offset+=4;
					}
					reg_alloc(EAX);
					reg_alloc(EDX);
					
					/* Generating first operand */
					gen_text_expr(par1, EAX, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					
					/* Generating second  operand */
					gen_text_expr(par2, reg, offset);
					
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg));
					fprintf(fd, "\tmov %s, eax\n",reg_string(reg));
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(eax_push > 0){
						fprintf(fd, "\tpop eax\n");
						eax_push = 0;
						offset-=4;
					} else reg_free(EAX);
					/* Restoring memory register or freeing the one alloc'ed */
					if(edx_push > 0){
						offset-=4;
						edx_push = 0;
						fprintf(fd, "\tpop edx\n");
					} else reg_free(EDX);
				}
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_MOD:
		{
			reg_name reg2;
			int eax_push = 0;
			int edx_push = 0;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* We need eax and edx registers because idiv operation
				  expects it that way */
				if(reg == EAX){ /* If result expected in eax */
					if(reg_state(EDX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush edx\n");
						edx_push++;
						offset+=4;
					}
					reg_alloc(EDX);
					/* Generating first operand */
					gen_text_expr(par1, reg, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					reg2 = reg_ralloc();
					if(reg2 == NAR){
						/* Inserting register in memory temporarily */
						reg2 = reg_next(reg);
						fprintf(fd, "\tpush %s\n", reg_string(reg2));
						pushed++;
						offset+=4;
					}
					
					/* Generating second  operand */
					gen_text_expr(par2, reg2, offset);
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg2));
					fprintf(fd, "\tmov eax, edx\n");
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(pushed > 0){
						fprintf(fd, "\tpop %s\n", reg_string(reg2));
						pushed--;
						offset-=4;
					} else reg_free(reg2);
					/* Restoring memory register or freeing the one alloc'ed */
					if(edx_push > 0){
						offset-=4;
						edx_push = 0;
						fprintf(fd, "\tpop edx\n");
					} else reg_free(EDX);
				} else if(reg == EDX){/* If result expected in edx */
					if(reg_state(EAX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush eax\n");
						eax_push++;
						offset+=4;
					}
					reg_alloc(EAX);
					/* Generating first operand */
					gen_text_expr(par1, EAX, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					reg2 = reg_ralloc();
					if(reg2 == NAR){
						/* Inserting register in memory temporarily */
						reg2 = EBX;
						fprintf(fd, "\tpush %s\n", reg_string(reg2));
						pushed++;
						offset+=4;
					}
					
					/* Generating second  operand */
					gen_text_expr(par2, reg2, offset);
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg2));
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(pushed > 0){
						fprintf(fd, "\tpop %s\n", reg_string(reg2));
						pushed--;
						offset-=4;
					} else reg_free(reg2);
					/* Restoring memory register or freeing the one alloc'ed */
					if(eax_push > 0){
						fprintf(fd, "\tpop eax\n");
						eax_push = 0;
						offset-=4;
					} else reg_free(EAX);
				} else {/* If result expected in another register */
					if(reg_state(EDX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush edx\n");
						edx_push++;
						offset+=4;
					}
					if(reg_state(EAX) != 0){
						/* Inserting register in memory temporarily */
						fprintf(fd, "\tpush eax\n");
						eax_push++;
						offset+=4;
					}
					reg_alloc(EAX);
					reg_alloc(EDX);
					
					/* Generating first operand */
					gen_text_expr(par1, EAX, offset);
					fprintf(fd, "\tmov edx, eax\n");
					fprintf(fd, "\tsar edx, 31\n");
					
					/* Generating second  operand */
					gen_text_expr(par2, reg, offset);
					/* Signed division operation */
					fprintf(fd, "\tidiv %s\n", reg_string(reg));
					fprintf(fd, "\tmov %s, edx\n",reg_string(reg));
					
					
					/* Restoring memory register or freeing the one alloc'ed */
					if(eax_push > 0){
						fprintf(fd, "\tpop eax\n");
						eax_push = 0;
						offset-=4;
					} else reg_free(EAX);
					/* Restoring memory register or freeing the one alloc'ed */
					if(edx_push > 0){
						offset-=4;
						edx_push = 0;
						fprintf(fd, "\tpop edx\n");
					} else reg_free(EDX);
				}
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_SRGT:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			/* Shift operation requires the use of the ecx register */
			if(reg != ECX){
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				if(reg_state(ECX) != 0){
					/* Inserting register in memory temporarily */
					fprintf(fd, "\tpush ecx\n");
					offset+=4;
					pushed++;
				}
				reg2 = reg_alloc(ECX);
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Right shift operation */
				fprintf(fd, "\tsar %s, cl\n", reg_string(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop ecx\n");
					offset-=4;
					pushed--;
				} else reg_free(reg2);
			} else {
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating first operand */
				gen_text_expr(par1, reg2, offset);
				/* Generating second  operand */
				gen_text_expr(par2, reg, offset);
				fprintf(fd, "\tsar %s, cl\n", reg_string(reg2));
				fprintf(fd, "\tmov ecx, %s\n",reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
			}
		}
		break;
	case AST_B_SLFT:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			/* Shift operation requires the use of the ecx register */
			if(reg != ECX){
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				if(reg_state(ECX) != 0){
					/* Inserting register in memory temporarily */
					fprintf(fd, "\tpush ecx\n");
					offset+=4;
					pushed++;
				}
				reg2 = reg_alloc(ECX);
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Left shift operation */
				fprintf(fd, "\tsal %s, cl\n", reg_string(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop ecx\n");
					offset-=4;
					pushed--;
				} else reg_free(reg2);
			} else {
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				gen_text_expr(par1, reg2, offset);
				/* Generating second  operand */
				gen_text_expr(par2, reg, offset);
				/* Left left operation */
				fprintf(fd, "\tsal %s, cl\n", reg_string(reg2));
				fprintf(fd, "\tmov ecx, %s\n",reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
			}
		}
		break;
	case AST_B_GEQ:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}

				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsetge %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_SEQ:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}

				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsetle %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_GT:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsetg %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_ST:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsetl %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_NEQ:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsetne %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_EQ:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Comparison */
				fprintf(fd, "\tcmp %s, %s\n", reg_string(reg), reg_string(reg2));
				fprintf(fd, "\tsete %s\n",reg_lower(reg));
				fprintf(fd, "\tmovzx %s, %s\n", reg_string(reg), reg_lower(reg));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_ORB:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				/* Obtaining another register */
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Bitwise or operation */
				fprintf(fd, "\tor %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_ANDB:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				/* Obtaining another register */
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Bitwise and operation */
				fprintf(fd, "\tand %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_XOR:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				/* Obtaining another register */
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				/* Bitwise xorg operation */
				fprintf(fd, "\txor %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_OR:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				/* Obtaining another register */
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Can only be 0 or 1 so standard logical or operation */
				fprintf(fd, "\tcmp %s, %d\n", reg_string(reg), 0);
				fprintf(fd, "\tsetne %s\n",reg_lower(reg));
				fprintf(fd, "\tmovsx %s, %s\n", reg_string(reg), reg_lower(reg));
				fprintf(fd, "\tcmp %s, %d\n", reg_string(reg2), 0);
				fprintf(fd, "\tsetne %s\n",reg_lower(reg2));
				fprintf(fd, "\tmovsx %s, %s\n", reg_string(reg2), reg_lower(reg2));
				fprintf(fd, "\tor %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_B_AND:
		{
			reg_name reg2;
			int pushed = 0;
			ast_node *par1 = tree->type_info[0];
			ast_node *par2 = tree->type_info[0]->sibling;
			switch(tree->subtype){
			case AST_BOOL:
			case AST_CHAR:
			case AST_INT:
				/* Generating first operand */
				gen_text_expr(par1, reg, offset);
				/* Obtaining another register */
				reg2 = reg_ralloc();
				if(reg2 == NAR){
					/* Inserting register in memory temporarily */
					reg2 = reg_next(reg);
					fprintf(fd, "\tpush %s\n", reg_string(reg2));
					pushed++;
					offset+=4;
				}
				
				/* Generating second  operand */
				gen_text_expr(par2, reg2, offset);
				
				/* Can only be 0 or 1 so standard logical and operation */
				fprintf(fd, "\tcmp %s, %d\n", reg_string(reg), 0);
				fprintf(fd, "\tsetne %s\n",reg_lower(reg));
				fprintf(fd, "\tmovsx %s, %s\n", reg_string(reg), reg_lower(reg));
				fprintf(fd, "\tcmp %s, %d\n", reg_string(reg2), 0);
				fprintf(fd, "\tsetne %s\n",reg_lower(reg2));
				fprintf(fd, "\tmovsx %s, %s\n", reg_string(reg2), reg_lower(reg2));
				fprintf(fd, "\tand %s, %s\n", reg_string(reg), reg_string(reg2));
				
				/* Restoring memory register or freeing the one alloc'ed */
				if(pushed > 0){
					fprintf(fd, "\tpop %s\n", reg_string(reg2));
					pushed--;
					offset-=4;
				} else reg_free(reg2);
				break;
			case AST_FLOAT:
				break;
			}
		}
		break;
	case AST_U_MIN:
		{
		
			/* Standard negation function */
			gen_text_expr( tree->type_info[0], reg, offset);
			
			fprintf(fd, "\tneg %s\n", reg_string(reg));
		}
		break;
	case AST_U_NEG:
		{
			/* Standard logical not function */
			gen_text_expr( tree->type_info[0], reg, offset);
			/* Can only be 0 or 1 */
			fprintf(fd, "\tcmp %s, 0\n",  reg_string(reg));
			fprintf(fd, "\tsete %s\n", reg_lower(reg));
			fprintf(fd, "\tmovsx %s, %s\n",  reg_string(reg), reg_lower(reg));
		}
		break;
	case AST_U_NEGB:
		{
			/* Standard not function */
			gen_text_expr( tree->type_info[0], reg, offset);
			
			fprintf(fd, "\tnot %s\n",  reg_string(reg));
		}
		break;
	}
}

void gen_text_content(ast_node *tree, int offset);

/* switch  generating function */
void gen_text_switch(ast_node *tree, int offset){
	int id = swtch_id++;
	int case_id = 0;
	/* Printing switch expression */
	reg_alloc(EAX);
	gen_text_expr(tree->type_info[0], EAX, 0);
	reg_free(EAX);
	/* for each case */
	ast_node *node = tree->type_info[1];
	while(node){
		fprintf(fd, "case%d%d:\n",id, case_id++);
		if(node->type == AST_CASE){
			/* Checking constant */
			switch(node->subtype){
			case AST_BOOL:
				fprintf(fd, "\tcmp eax, %d\n", (node->integer > 0 ? 1 : 0));
				break;
			case AST_CHAR:
				fprintf(fd, "\tcmp eax, %d\n", (char)node->integer);
				break;
			case AST_INT:
				fprintf(fd, "\tcmp eax, %d\n", node->integer);
				break;
			}
			/* Checking if there is more work to do */
			if(node->sibling)
				fprintf(fd, "\tjne case%d%d\n", id, case_id);
			else
				fprintf(fd, "\tjne endswtch%d\n", id);
		}
		/* Calling magic function */
		gen_text_content(node, offset);
		if(node->type == AST_CASE){
			fprintf(fd, "\tjmp endswtch%d\n", id);
		}
		node = node->sibling;
	}
	fprintf(fd, "endswtch%d:\n", id);
}
/* If-elsif-else  generating function */
void gen_text_if(ast_node *tree, int offset){
	/* Acquiring if id */
	int id = if_id++;
	int eif = 0;
	/* Printing if condition */
	fprintf(fd, "\n\t;IF : condition\n");
	reg_alloc(EAX);
	gen_text_expr(tree->type_info[0], EAX, 0);
	reg_free(EAX);
	fprintf(fd, "\tcmp eax, 0\n");
	/* Checking for elsif-else */
	if(tree->type_info[1]){
		/* We do have elsif */
		fprintf(fd, "\tjz if%d%d\n", id, eif);
		fprintf(fd, "\t;End IF : codition\n");
	
		fprintf(fd, "\n\t;IF : content\n");
		gen_text_content(tree, offset);
		fprintf(fd, "\t;End IF : content\n");
		fprintf(fd, "\tjmp endif%d\n", id);
	} else {
		/* No more work to do before this */
		fprintf(fd, "\tjz endif%d\n", id);
		fprintf(fd, "\t;End IF : codition\n");
	
		fprintf(fd, "\n\t;IF : content\n");
		gen_text_content(tree, offset);
		fprintf(fd, "\t;End IF : content\n");
	}

	ast_node *node = tree->type_info[1];
	/* For each elsif-else doing exactly the same */
	while(node){
		fprintf(fd, "if%d%d:\n", id, eif++);
		if(node->type_info){
			/* Printing condition */
			fprintf(fd, "\n\t;ELSIF : condition\n");
			reg_alloc(EAX);
			gen_text_expr(node->type_info[0], EAX, 0);
			reg_free(EAX);
			fprintf(fd, "\tcmp eax, 0\n");
			/* Checking for elsif-else */
			if(node->sibling){
				/* We do have elsif */
				fprintf(fd, "\tjz if%d%d\n", id, eif);
				fprintf(fd, "\t;End ELSIF : codition\n");
				fprintf(fd, "\n\t;ELSIF : content\n");
				gen_text_content(node, offset);
				fprintf(fd, "\t;End ELSIF : content\n");
				fprintf(fd, "\tjmp endif%d\n", id);
			} else {
				/* No more work to do before this */
				fprintf(fd, "\tjz endif%d\n", id);
				fprintf(fd, "\t;End ELSIF : codition\n");
				fprintf(fd, "\n\t;ELSIF : content\n");
				gen_text_content(node, offset);
				fprintf(fd, "\t;End ELSIF : content\n");
			}
		} else {
			/* Else, finishing */
			fprintf(fd, "\n\t;ELSE : content\n");
			gen_text_content(node, offset);
			fprintf(fd, "\t;End ELSE : content\n");
		}
		node = node->sibling;
	} 
	fprintf(fd, "endif%d:\n", id);
}

/* For generating function */
void gen_text_for(ast_node *node, int offset){
	/* Acquiring loop id */
	int id = loop_id++;
	/*Saving previous loop level */
	int rid = loop_level;
	loop_level = id;
	/* Printing initialization */
	fprintf(fd, "\n\t;For : initialization\n");
	reg_alloc(EAX);
	gen_text_expr(node->type_info[0], EAX, offset);
	reg_free(EAX);
	fprintf(fd, "\t;End For : initialization\n");
	
	fprintf(fd, "l%d:\n", id);
	
	/* Printing condition */
	fprintf(fd, "\n\t;For : condition\n");
	reg_alloc(EAX);
	gen_text_expr(node->type_info[1], EAX, offset);
	reg_free(EAX);
	fprintf(fd, "\tcmp eax, 0\n");
	fprintf(fd, "\tjz lr%d\n", id);
	fprintf(fd, "\t;End For : codition\n");
	/* Printing content using magic function */
	fprintf(fd, "\n\t;For : content\n");
	gen_text_content(node, offset);
	fprintf(fd, "\t;End For : content\n");
	/* Printing step */
	fprintf(fd, "\n\t;For : step\nls%d:\n",id);
	reg_alloc(EAX);
	gen_text_expr(node->type_info[2], EAX, offset);
	reg_free(EAX);
	fprintf(fd, "\t;End For : step\n");
	/* Finishing */	
	fprintf(fd, "\tjmp l%d\n",id);
	fprintf(fd, "lr%d:\n",id);
	/* Returning previous loop level */
	loop_level = rid;
}

/* While generating function */
void gen_text_while(ast_node *node, int offset){
	/* Acquiring loop id */
	int id = loop_id++;
	/*Saving previous loop level */
	int rid = loop_level;
	loop_level = id;
	fprintf(fd, "ls%d:\n", id);
	/* Printing condition */
	fprintf(fd, "\n\t;While : condition\n");
	reg_alloc(EAX);
	gen_text_expr(node->type_info[0], EAX, 0);
	reg_free(EAX);
	fprintf(fd, "\tcmp eax, 0\n");
	fprintf(fd, "\tjz lr%d\n", id);
	fprintf(fd, "\t;End while : codition\n");
	/* Printing content using magic function */
	fprintf(fd, "\n\t;While : content\n");
	gen_text_content(node, offset);
	fprintf(fd, "\t;End While : content\n");
	/* Finishing */
	fprintf(fd, "\tjmp ls%d\n",id);
	fprintf(fd, "lr%d:\n",id);
	/* Returning previous loop level */
	loop_level = rid;
}

/* This function generates the content of an entire block 
   it's used in every structure and function, */
void gen_text_content(ast_node *tree,int  offset){
	ast_node *node = tree->content;
	while(node){/* Node type discrimination */
		switch(node->type){
		case AST_OUT:
		case AST_IN:
			gen_text_io(node);
			break;
		case AST_EXPR:
			{
				/* Multiple registers can be used for expressions */
				reg_name reg = reg_ralloc();
				fprintf(fd, "\n\t;Expression\n");
				gen_text_expr(node, reg, offset);
				reg_free(reg);
				fprintf(fd, "\t;End Expression\n");
			}
			break;
		case AST_FOR:
			fprintf(fd, "\n\t;For loop\n");
			gen_text_for(node, offset);
			fprintf(fd, "\t;End For loop\n");
			break;
		case AST_WHILE:
			fprintf(fd, "\n\t;While loop\n");
			gen_text_while(node, offset);
			fprintf(fd, "\t;End While loop\n");
			break;
		case AST_BREAK:
			fprintf(fd, "\tjmp lr%d\n", loop_level);
			break;
		case AST_CONT:
			fprintf(fd, "\tjmp ls%d\n", loop_level);
			break;
		case AST_RET:
			/* Printing returning expression code */
			if(node->type_info != NULL){
				reg_alloc(EAX);
				gen_text_expr(node->type_info[0], EAX, offset);
				reg_free(EAX);
			}
			/* Printing return with false ebp */
			fprintf(fd, "\tleave\n");
			fprintf(fd, "\tret %d\n", ebp-8);
			break;
		case AST_IF:
			fprintf(fd, "\n\t;IF\n");
			gen_text_if(node, offset);
			fprintf(fd, "\t;End IF\n");
			break;
		case AST_SWITCH:
			fprintf(fd, "\n\t;SWITCH\n");
			gen_text_switch(node, offset);
			fprintf(fd, "\t;End SWITCH\n");
			break;
		}
		node = node->sibling;
	}
}
/* Real code generating area, this is the code generation
   function. Most of the job is delegated */
void generate_text(ast_node *tree){
	/* T.ext area initialization */
	fprintf(fd, "\nsection .text\n\n\tglobal main\n\n");
	if(tree->type_info){
		stack *init_vars = stk_new(256);
		ast_node *node = tree->type_info[0];
		while(node){
			/* False esp, ebp initializing */
			esp = 0; ebp = 8;
			var_info *ident;
			/* Checking if main symbol */
			/* The main symbol is needed in order for the 
			   assembler to find the entry point */
			if(strcmp(node->string,"main") == 0){
				ident = new_global_ident(node->string, NULL , 0,
																FUNCTION, NO, 0);
			} else {
				ident = new_global_ident(node->string, "fun", fun_id++,
																FUNCTION, NO, 0);
			}
			
			fprintf(fd,"%s:\n", ident->name);
			
			/* Variable Allocation */
			
			/* Generates local identifier translation table */
			if(!(symbols[1] = hashtbl_create(256, NULL))) {
				fprintf(stderr, "Error   : Compiler initialization failed\n");
				exit(EXIT_FAILURE);
			}
			
			/* Adding variables to hash */
			ast_node *pars = node->type_info[1];
			while(pars){
				var_info *data = malloc(sizeof(var_info));
				int size = esp;
				data->name = NULL;
				data->type = VARIABLE;
				data->vector = (pars->integer > 0 ? YES : NO);
				data->offset = esp;
				
				if(pars->integer == 0) {
					esp += 4; 
				} else {
					
					if(pars->subtype == AST_FLOAT || pars->subtype == AST_INT){
						esp += pars->integer*4;
					} else {
						esp += pars->integer + (4-pars->integer%4);
					}
				}
				
				if(pars->subtype == AST_FLOAT || pars->subtype == AST_INT){
					data->size = 4;
				} else {
					data->size = 1;
				}
				/* Adding initializations to stack */
				hashtbl_insert(symbols[1], pars->string, data);
				if(pars->type_info != NULL){
					char string[256];
					ast_node *initc = pars->type_info[0];
					while(initc){
						switch(pars->subtype){
						case AST_FLOAT:
							{
								int *var = (int*)&(initc->real);
								sprintf(string, "\tmov dword [esp + %d], %d\n", size ,*var);
								stk_push(init_vars, strdup(string));
							}
							break;
						case AST_INT:
							{
								sprintf(string, "\tmov dword [esp + %d], %d\n", size ,initc->integer);
								stk_push(init_vars, strdup(string));
							}
							break;
						case AST_BOOL:
							{
								sprintf(string, "\tmov byte [esp + %d], %d\n", size ,(initc->integer > 0 ? 1 : 0));
								stk_push(init_vars, strdup(string));
							}
							break;
						case AST_CHAR:
							{
								sprintf(string, "\tmov byte [esp + %d], %d\n", size ,(char)initc->integer);
								stk_push(init_vars, strdup(string));
							}
							break;
						}
						size +=data->size;
						initc = initc->sibling;
					}
				}
				pars = pars->sibling;
			}
			
			/* Adding parameters to hash */
			pars = node->type_info[0];
			while(pars){
				var_info *data = malloc(sizeof(var_info));

				data->name = NULL;
				data->type = PARAMETER;
				data->vector = (pars->integer > 0 ? YES : NO);
				data->offset = ebp;
				ebp += 4; 
				
				if(pars->subtype == AST_FLOAT || pars->subtype == AST_INT){
					data->size = 4;
				} else {
					data->size = 1;
				}
				hashtbl_insert(symbols[1], pars->string, data);
				pars = pars->sibling;
			}
			/* Function initializing */
			fprintf(fd, "\tenter %d,0\n", esp);
			char *str;
			
			/* Printing variables initialization */
			while(str = stk_pop(init_vars)){
				fprintf(fd, "%s",str);
				free(str);
			}
			/*Content generation engaged */
			gen_text_content(node, 0);
			/* End of function */
			fprintf(fd,"\n\tleave\n");
			fprintf(fd,"\tret %d\n\n",ebp - 8);
			
			/* Local symbol table destruction */
			symbols_destroy(symbols[1]);
			node = node->sibling;
		}
		stk_free(init_vars);
	}
}

int main(int argc, char** argv) {
	ast_node *tree;
	printf("JAM Compiler v1.0\n\n");
	int i, j;
	char c;
	int numerrors = 0;
	/* Options */
	int assemble = 0;
	char *input = NULL;
	char *output = NULL;
	char str_out1[256], str_out2[256];
	
	/* Initial parameter checking */
	while (1)
	{
		static struct option long_options[] =
		{
			{"assemble",     no_argument,  0, 'a'},
			{"help",         no_argument,  0, 'h'},
			{"version",      no_argument,  0, 'v'},
			{"input",   required_argument, 0, 'i'},
			{"output",  required_argument, 0, 'o'},
			{0, 0, 0, 0}
		};
	
		/* getopt_long stores the option index here. */
		int option_index = 0;

		c = getopt_long (argc, argv, "ahvi:o:",
							long_options, &option_index);

		/* Detect the end of the options. */
		if (c == -1) break;

		switch (c) {
		case 'a':/* Create executable option */
			assemble = 1;
			break;
		case 'i':/* Input file */
			input = strdup(optarg);
			break;
		case 'o':/* Output file */
			output = strdup(optarg);
			break;
		case 'v': /* Version view */
				printf("Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)\n");
				printf("                   Mikel Ganuza Estremera(migaes.mail@gmail.com)\n");
				printf("License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\n");
				printf("This is free software: you are free to change and redistribute it.\n");
				printf("There is NO WARRANTY, to the extent permitted by law.\n\n");
				exit(0);
				break;
			case '?':
			case 'h': /* Help view*/
				printf("\nUsage: jamcc [-vhioa]\n\n");
				printf("\t-v, --version\t\tPrints version information\n");
				printf("\t-h, --help\t\tPrints this help\n");
				printf("\t-i, --input FILE\tInput file name\n");
				printf("\t-o, --output FILE\tOutput file name\n");
				printf("\t-a, --assemble\t\tCreates linux executable file\n");
				printf("\nReport bugs to anil.mmm@gmail.com.\n\n");
				exit(0);
				break;
		default:
			exit(0);
		}
	}
	/* No input file */
	if(input == NULL){
		printf("\nUsage: jamcc [-vhioa]\n\n");
		printf("\t-v, --version\t\tPrints version information\n");
		printf("\t-h, --help\t\tPrints this help\n");
		printf("\t-i, --input FILE\tInput file name\n");
		printf("\t-o, --output FILE\tOutput file name\n");
		printf("\t-a, --assemble\t\tCreates linux executable file\n");
		printf("\nReport bugs to anil.mmm@gmail.com.\n\n");
		exit(0);
	}
	/* Using input file for parsing */
	tree = (ast_node *)parse(input);
	free(input);
	/* If no parsing errors */
	if(tree){

		/* Opening file for compilation result */
		if(output == NULL)
			output = strdup("a.out");

		sprintf(str_out1,"%s.s",output);
		fd = fopen(str_out1, "w");
		
		if(fd == NULL){
			fprintf(stderr, "Error   : Compiler initialization failed\n");
			exit(EXIT_FAILURE);
		}
		
		/* Generates global identifier translation table */
		if(!(symbols[0] = hashtbl_create(256, NULL))) {
			fprintf(stderr, "Error   : Compiler initialization failed\n");
			exit(EXIT_FAILURE);
		}
		fprintf(fd, "extern printf\n");
		fprintf(fd, "extern getchar\n\n");
		/* Generating zero initialized section */
		generate_bss(tree);
		/* Generating user initialized section */
		generate_data(tree);
		/* Generating code section */
		generate_text(tree);

		/* Destroy hash, AST tree and closing file */
		symbols_destroy(symbols[0]);
		ast_node_destroy(tree);
		fclose(fd);
		
		if(assemble == 1){
			int pid;
			
			switch(pid = fork()){
			case -1:
				break;
			case 0:
				/* Generating output files */
				sprintf(str_out1,"%s.lst",output);
				sprintf(str_out2,"%s.s",output);
				/* Assembling */
				execlp("nasm","nasm","-f", "elf", "-l",str_out1, str_out2, NULL);
				/* Exec failed */
				fprintf(stderr, "Error   : NASM not found\n");
				exit(0);
				break;
			default:
				/* Waiting for beloved child */
				wait(pid);
				switch(pid = fork()){
				case -1:
					break;
				case 0:
					sprintf(str_out1,"%s.o",output);
					execlp("gcc","gcc","-m32", "-o", output, str_out1, NULL);
					/* Exec failed */
					fprintf(stderr, "Error   : GCC not found\n");
					exit(0);
					break;
				default:
					/* Waiting for beloved child */
					wait(pid);
				}
			}
		}
		
		free(output);
		
		/* Victory */
		printf("Compilation completed successfully\n");
	}
	return 0;
}
