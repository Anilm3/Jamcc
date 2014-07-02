/********************************************************************************
* JAM v1.0 - ast.c                                                              *
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
#include "ast.h"

/* Creates a new AST node */
ast_node* 
ast_node_create(enum ast_type type,
								enum ast_subtype subtype,
								char *string,
								int integer,
								float real,
								ast_node **type_info,
								ast_node *content,
								ast_node *sibling)
{
	ast_node *node = malloc(sizeof(ast_node));
	node->type = type;
	node->subtype = subtype;
	node->string = string;
	node->integer = integer;
	node->real = real;
	node->type_info = type_info;
	node->content = content;
	node->sibling = sibling;
	return node;
}
int i, nivel = 0;

/* Debugging function, prints the entire AST tree */
void ast_tree_print(ast_node *node){
	switch(node->type){
	case AST_PROG:
		{
			ast_node *nodo = node->type_info[1];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			printf("\n");
			nodo = node->type_info[0];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
		}
		break;
	case AST_FUN:
		{
			printf("FUN %s\n", node->string);
			nivel++;
			printf("\nParametros:\n");
			ast_node *nodo = node->type_info[0];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			
			printf("\nVariables:\n");
			
			nodo = node->type_info[1];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			printf("\nContenido:\n");
			nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
			printf("\n");
		}
		
		
		break;
	case AST_VAR:
		for(i = 0; i < nivel; i++) printf(" ");
		printf("VAR %s\n", node->string);
		break;
	case AST_FOR:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("FOR\n");
			nivel++;
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Inicialización:\n");
			ast_tree_print(node->type_info[0]);
			
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Condición: \n");
			ast_tree_print(node->type_info[1]);
			
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Paso: \n");
			ast_tree_print(node->type_info[2]);
			
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Contenido:\n");
			
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
			for(i = 0; i < nivel; i++) printf(" ");
			printf("END\n");
		}
		break;
	case AST_WHILE:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("WHILE\n");
			nivel++;
			
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Condición: \n");
			ast_tree_print(node->type_info[0]);
						
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Contenido:\n");
			
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
			for(i = 0; i < nivel; i++) printf(" ");
			printf("END\n");
		}
		break;
	case AST_IF:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("IF\n");
			nivel++;
		
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Condición: \n");
			ast_tree_print(node->type_info[0]);
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Contenido:\n");
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
			
			nodo = node->type_info[1];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			for(i = 0; i < nivel; i++) printf(" ");
			printf("END\n");
		}
		break;
	case AST_ELSIF:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("ELSE IF\n");
			nivel++;
		
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Condición: \n");
			ast_tree_print(node->type_info[0]);
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Contenido:\n");
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
/*			printf("\n");*/
		}
		break;
	case AST_ELSE:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("ELSE\n");
			nivel++;
		
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Contenido:\n");
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
/*			printf("\n");*/
		}
		break;
	case AST_SWITCH:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("SWITCH\n");
		
			for(i = 0; i < nivel; i++) printf(" ");
			printf("Condición: \n");
		printf("(");
			ast_tree_print(node->type_info[0]);
			
			ast_node *nodo = node->type_info[1];
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			for(i = 0; i < nivel; i++) printf(" ");
			printf("END\n");
		}
		break;
	case AST_CASE:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("CASE %d\n", node->integer);
			nivel++;
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
		}
		break;
	case AST_DEFAULT:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("DEFAULT\n");
			nivel++;
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			nivel--;
		}
		break;
	case AST_BREAK:
		for(i = 0; i < nivel; i++) printf(" ");
		printf("BREAK\n");
		break;
	case AST_CONT:
		for(i = 0; i < nivel; i++) printf(" ");
		printf("CONTINUE\n");
		break;
	case AST_RET:
		for(i = 0; i < nivel; i++) printf(" ");
		printf("RETURN");
		if(node->type_info)
			ast_tree_print(node->type_info[0]);
		printf("\n");
		break;
	case AST_FUNCALL:
		{
			printf("FUNCALL %s\n", node->string);
		}
		break;
	case AST_EXPR:
		{
			for(i = 0; i < nivel; i++) printf(" ");
	/*		printf("EXPRESSION\n");*/
			ast_node *nodo = node->content;
			while(nodo){
				ast_tree_print(nodo);
				nodo = nodo->sibling;
			}
			printf("\n");
		}
		break;
	case AST_IDENT:
		printf("%s", node->string);
		break;
	case AST_CONST:
		printf("CONST");
		break;
	case AST_OUT:
		{
			for(i = 0; i < nivel; i++) printf(" ");
			printf("<++\n");
			nivel++;
			ast_node *nodo = node->type_info[0];
			while(nodo){
				for(i = 0; i < nivel; i++) printf(" ");
				ast_tree_print(nodo);
				printf("\n");
				nodo = nodo->sibling;
			}
			nivel--;
		}
		break;
	case AST_IN:
		for(i = 0; i < nivel; i++) printf(" ");
		printf(">++\n");
		if(node->type_info){
			if(node->type_info[0]){
				for(i = 0; i < nivel; i++) printf(" ");
				ast_tree_print(node->type_info[0]);
				printf("\n");
			}
		}
		break;
	case AST_B_MUL:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("*");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_DIV:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("/");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_MOD:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("%%");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_SUM:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("+");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_MIN:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("-");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_SRGT:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf(">>");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_SLFT:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("<<");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_GEQ:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf(">=");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_SEQ:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("<=");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_GT:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf(">");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_ST:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("<");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_NEQ:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("!=");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_EQ:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("==");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_ORB:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("|");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_ANDB:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("&");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_XOR:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("^");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_OR:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("||");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_AND:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("&&");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_B_ASIG:
		printf("(");
		ast_tree_print(node->type_info[0]);
		printf("=");
		ast_tree_print(node->type_info[0]->sibling);
		printf(")");
		break;
	case AST_U_POS:
		printf("(");
		printf("+");
		ast_tree_print(node->type_info[0]);
		printf(")");
		break;
	case AST_U_MIN:
		printf("(");
		printf("-");
		ast_tree_print(node->type_info[0]);
		printf(")");
		break;
	case AST_U_NEG:
		printf("(");
		printf("!");
		ast_tree_print(node->type_info[0]);
		printf(")");
		break;
	case AST_U_NEGB:
		printf("(");
		printf("~");
		ast_tree_print(node->type_info[0]);
		printf(")");
		break;
	default:
		for(i = 0; i < nivel; i++) printf(" ");
		printf("DEFAULT\n");
	}
}

/* Destroy an AST node, or the entire tree for that matter */
void ast_node_destroy(ast_node *node){
	if(node){
		switch(node->type){
		case AST_PROG:
			{
				if(node->type_info){
					ast_node *aux, *nodo = node->type_info[1];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
			
					nodo = node->type_info[0];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_FUN:
			{
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				if(node->string != NULL) free(node->string);
				if(node->type_info){
					nodo = node->type_info[0];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					nodo = node->type_info[1];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
			
				free(node);
			}
			break;
		case AST_FOR:
			{
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
					ast_node_destroy(node->type_info[1]);
					ast_node_destroy(node->type_info[2]);
					free(node->type_info);
				}
			
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				free(node);
			}
			break;
		case AST_WHILE:
			{
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
					free(node->type_info);
				}
			
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				free(node);
			}
			break;
		case AST_IF:
			{
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
					nodo = node->type_info[1];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_ELSIF:
			{
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
					free(node->type_info);
				}
			
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				free(node);
			}
			break;
		case AST_SWITCH:
			{
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
			
					ast_node *aux, *nodo = node->type_info[1];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_BREAK:
			free(node);
			break;
		case AST_CONT:
			free(node);
			break;
		case AST_RET:
			if(node->type_info){
				if(node->type_info[0])
					ast_node_destroy(node->type_info[0]);
				free(node->type_info);
			}
			free(node);
			break;
		case AST_FUNCALL:
			{
				if(node->string != NULL) free(node->string);
				if(node->type_info){
					ast_node *aux, *nodo = node->type_info[0];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_ELSE:
		case AST_CASE:
		case AST_DEFAULT:
		case AST_EXPR:
			{
				ast_node *aux, *nodo = node->content;
				while(nodo){
					aux = nodo;
					nodo = nodo->sibling;
					ast_node_destroy(aux);
				}
				free(node);
			}
			break;
		case AST_VAR:
			{
				if(node->string != NULL) free(node->string);
				if(node->type_info){
					ast_node *aux, *nodo = node->type_info[0];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_IDENT:
			{
				if(node->string != NULL) free(node->string);
				if(node->type_info){
					ast_node_destroy(node->type_info[0]);
					free(node->type_info);
				}
				free(node);
			}
			break;
		case AST_CONST:
			if(node->string != NULL) free(node->string);
			free(node);
			break;
		case AST_OUT:
			{
				if(node->type_info){
					ast_node *aux, *nodo = node->type_info[0];
					while(nodo){
						aux = nodo;
						nodo = nodo->sibling;
						ast_node_destroy(aux);
					}
					free(node->type_info);
				}
				if(node->content != NULL)
					ast_node_destroy(node->content);
				free(node);
			}
			break;
		case AST_B_MUL:
		case AST_B_DIV:
		case AST_B_MOD:
		case AST_B_SUM:
		case AST_B_MIN:
		case AST_B_SRGT:
		case AST_B_SLFT:
		case AST_B_GEQ:
		case AST_B_SEQ:
		case AST_B_GT:
		case AST_B_ST:
		case AST_B_NEQ:
		case AST_B_EQ:
		case AST_B_ORB:
		case AST_B_ANDB:
		case AST_B_XOR:
		case AST_B_OR:
		case AST_B_AND:
		case AST_B_ASIG:
			if(node->type_info){
				ast_node_destroy(node->type_info[0]->sibling);
				ast_node_destroy(node->type_info[0]);
				free(node->type_info);
			}
			free(node);
			break;
		case AST_IN:
		case AST_U_POS:
		case AST_U_MIN:
		case AST_U_NEG:
		case AST_U_NEGB:
			if(node->type_info){
				ast_node_destroy(node->type_info[0]);
				free(node->type_info);
			}
			free(node);
			break;
		}
	}
}
