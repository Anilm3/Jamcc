/********************************************************************************
* JAM v1.0 - ast.h                                                              *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

/* AST node type */
enum ast_type {
	AST_PROG, AST_FUN, AST_VAR, 
	
	AST_FOR, AST_WHILE, 
	AST_IF, AST_ELSIF, AST_ELSE,
	AST_SWITCH, AST_CASE, AST_DEFAULT,
	
	AST_BREAK, AST_CONT, AST_RET,
	
	AST_FUNCALL, AST_IDENT, AST_CONST, AST_EXPR,
	
	AST_BOP, AST_UOP,
	
	AST_OUT, AST_IN, 
	
	AST_B_MUL, AST_B_DIV, AST_B_MOD, AST_B_SUM, 
	AST_B_MIN, AST_B_SRGT, AST_B_SLFT, AST_B_GEQ,
	AST_B_SEQ, AST_B_GT, AST_B_ST, AST_B_NEQ, AST_B_EQ,
	AST_B_ORB, AST_B_ANDB, AST_B_XOR, AST_B_OR,
	AST_B_AND, AST_B_ASIG,
	 
	AST_U_POS, AST_U_MIN, AST_U_NEG, AST_U_NEGB,
};

/* AST node subtype */
enum ast_subtype {AST_VOID = -1, AST_BOOL = 0, AST_CHAR = 1, AST_INT = 2, AST_FLOAT = 3, AST_STRING = 4};

/* AST node structure */
struct ast_node_ {
	enum ast_type type;
	enum ast_subtype subtype;
	char *string;
	int integer;
	float real;

	struct ast_node_ **type_info;
	struct ast_node_ *content;
	struct ast_node_ *sibling;
};

typedef struct ast_node_ ast_node;

/* Function for AST node creation */
ast_node* 
ast_node_create(enum ast_type,
								enum ast_subtype,
								char *,
								int,
								float,
								ast_node **,
								ast_node *,
								ast_node *);
								
/* Function for AST node (or tree) destruction */
void ast_node_destroy(ast_node *);

/* Debugging function, prints an AST tree */
void ast_tree_print(ast_node *);

