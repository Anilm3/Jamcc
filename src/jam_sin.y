/********************************************************************************
* JAM v1.0 - jam_sin.y                                                          *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com)              *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/

%{

#include "util.h"
#include "hashtbl.h"
#include "ast.h"
#include "stack.h"
#define YYERROR_VERBOSE

/* Hashing information for symbols */
enum boolean { NO, YES };
enum type {T_VOID = -1, T_BOOL = 0, T_CHAR = 1, T_INT = 2, T_FLOAT = 3, T_STRING = 4};
enum class {FUNCTION, VARIABLE};

struct symbol_info_{
	enum class clase;
	enum type tipo;
	enum boolean vector;
	int tam;
	enum boolean constant;
	enum boolean init;
	struct symbol_info_ *parametros;
};

typedef struct symbol_info_ symbol_info;

/* Global Variables */
extern FILE *yyin;
extern int numline;

int numerrors = 0;
int level = 0;
int iteration = 0;
HASHTBL *symbol_table[3];
stack *ast_stack;
ast_node *tree = NULL;

/* Symbol struct creation */
symbol_info *
create_symbol(	enum class clase,
								enum type tipo,
								enum boolean vector,
								int tam,
								enum boolean constant,
								enum boolean init,
								symbol_info *parametros)
{
	symbol_info *retorno = (symbol_info *)malloc(sizeof(symbol_info));
	retorno->clase = clase;
	retorno->tipo = tipo;
	retorno->vector = vector;
	retorno->tam = tam;
	retorno->constant = constant;
	retorno->init = init;
	retorno->parametros = parametros;
	return retorno;
}
/* DEBUGGING FUNCTION: prints the symbols contained in the hash table*/
void hashtbl_read(HASHTBL *hashtbl){
	int i;
	for(i = 0; i < hashtbl->size; i++){
		struct hashnode_s *node=hashtbl->nodes[i];
		while(node) {
		
			symbol_info *datos = node->data;
			printf("\nNombre       : %s\n", node->key);
			printf("Clase        : %s\n",	(datos->clase? "Variable":"Funcion"));
			printf("Tipo         : %d\n",	datos->tipo);
			printf("Vector       : %s\n",	(datos->vector? "Yes":"No"));
			printf("Tamano       : %d\n",	datos->tam);
			printf("Constant     : %s\n",	(datos->constant? "Yes":"No"));
			printf("Inicializado : %s\n",	(datos->init? "Yes":"No"));
			printf("Parametros   : %s\n",	(datos->parametros? "Yes": "No"));
			
			if(datos->parametros){
				symbol_info *node2 = datos->parametros;
				while(node2) {
					printf("\tTipo         : %d\n",	node2->tipo);
					printf("\tVector       : %s\n\n",	(node2->vector? "Yes":"No"));
					node2=node2->parametros;
				}
			}
			node=node->next;
		}
	}
}

/* Determines when the parser has entered a function */
/* And creates a new local symbol table for the current */
/* function */	
void in_function(){
	level = 1;
	if(!(symbol_table[2] = hashtbl_create(256, NULL))) {
		fprintf(stderr, "Error   : Parser failed\n");
		exit(EXIT_FAILURE);
	}
}

/* Determines when the parser has come out of a function */
/* and destroys the content of the associated symbol table */
void out_function(){
	level = 0;
	int i;
	for(i = 0; i < symbol_table[2]->size; i++){
		struct hashnode_s *node=symbol_table[2]->nodes[i];
		while(node) {
			free(node->data);
			node=node->next;
		}
	}
	hashtbl_destroy(symbol_table[2]);
}

/* This function destroys the global symbol tables */
void st_destroy(){
	int i;
	/* First destroys the global symbol table */
	for(i = 0; i < symbol_table[0]->size; i++){
		struct hashnode_s *node=symbol_table[0]->nodes[i];
		while(node) {
			symbol_info *datos = node->data;
			symbol_info *aux, *node2 = datos->parametros;
			/* Destroys de function parameters */
			while(node2) {
				aux = node2;
				node2=node2->parametros;
				free(aux);
			}
			free(datos);
			node=node->next;
		}
	}
	hashtbl_destroy(symbol_table[0]);
	/* Then destroys the global local symbol table */
	for(i = 0; i < symbol_table[1]->size; i++){
		struct hashnode_s *node=symbol_table[1]->nodes[i];
		while(node) {
			free(node->data);
			node=node->next;
		}
	}
	hashtbl_destroy(symbol_table[1]);
}

/* Creates a new symbol on the corresponding table */
void st_new(char *name, symbol_info *info){
	/* Checks wether the symbol exists on global symbol table */
	symbol_info *prior = hashtbl_get(symbol_table[0], name);
	if(prior == NULL){
		/* If we are defining a global symbol */
		if(level == 0){
			/* Checks if there exists a local symbol with the same name */
			prior = hashtbl_get(symbol_table[1], name);
			if(prior == NULL){
				hashtbl_insert(symbol_table[0], name, info);
			} else {
				printf("Line %d : symbol \"%s\" already declared once\n",numline,name);
				numerrors++;
			}
		} else {
			/* Checks if the symbol exists in the local symbol table */
			prior = hashtbl_get(symbol_table[2], name);
			if(prior == NULL){
				if(hashtbl_get(symbol_table[1], name) != NULL){
					hashtbl_insert(symbol_table[1], name, create_symbol(VARIABLE, 0, NO, 0, NO, NO, NULL));
				}
				hashtbl_insert(symbol_table[2], name, info);
			} else {
				printf("Line %d : symbol \"%s\" already declared once\n",numline,name);
				numerrors++;
			}
		}
	} else {
		printf("Line %d : symbol \"%s\" already declared once\n",numline,name);
		numerrors++;
	}
}

/* Returns the content of the symbol if exists */
symbol_info *st_find(char *name){
	/* Checking global */
	symbol_info *prior = hashtbl_get(symbol_table[0], name);
	if(prior == NULL){
		if(level > 0){
			/* Checking local */
			prior = hashtbl_get(symbol_table[2], name);
			if(prior == NULL){
				printf("Line %d : symbol \"%s\" undeclared\n",numline,name);
				numerrors++;
			}
		} else {
				printf("Line %d : symbol \"%s\" undeclared\n",numline,name);
				numerrors++;
		}
	}
	return prior;
}



%}
%union { float real; int entero; char *string; char caracter; struct symbol_info_ *info; }

%token OUT IN '='
%left OR
%left AND
%left '|'
%left '^'
%left '&'
%left EQ NEQ
%left '<' '>' SEQ GEQ
%left SLFT SRGT
%left '-' '+'
%left '%' '/' '*'
%right '~' '!'
%token '(' ')' '[' ']'
%token CON


%token IF
%token ELSE
%token ELSIF
%token FOR
%token WHILE
%token CONTINUE
%token BREAK
%token SWITCH
%token CASE
%token END
%token RETURN 
%token VOID 
%token FLOAT
%token CHAR
%token INT
%token SIZEOF
%token CONST
%token BOOL
%token DEFAULT

%token IDENTIFIER 

%token ','
%token ';'
%token ':'
%token '\n'

%token <entero> C_INT
%token <entero> C_FLT
%token <entero> C_STRING
%token <entero> C_BOOL
%token <entero> C_CHAR

%type <entero> type constant funcall expr_sec integer_const
%type <entero> expr_asig expression init_const atom
%type <string> ident_new
%type <info> ident decl_var_sim decl_funct_par_list 
%type <info> decl_funct_par funcall_pars decl_coma_list variable
%%
source								:	content_list 
												{
													/* Creating node for the entire program */
													if(numerrors == 0){
														ast_node *node = stk_pop(ast_stack);
														ast_node *fun, *afun, *var, *avar, *aux;
														ast_node **pars = malloc(sizeof(ast_node*)*2);
													
														fun = afun = var = avar = NULL;
													
														/* Separating functions and variables */
														while(node){
															if(node->type == AST_FUN){
																if(fun == NULL){
																	fun = afun = node;
																} else {
																	afun->sibling = node;
																	afun = afun->sibling;
																}
															} else {
																if(var == NULL){
																	var = avar = node;
																} else {
																	avar->sibling = node;
																	avar = avar->sibling;
																}
															}
															node = node->sibling; 
														}
													
														/* Saving functions and variables */
														if(afun != NULL) afun->sibling = NULL;
														if(avar != NULL) avar->sibling = NULL;
													
														pars[0] = fun;
														pars[1] = var;
														/* Creating tree */
														tree = ast_node_create(AST_PROG, AST_VOID, NULL, 0, 0, pars, NULL, NULL);
													}
												}
											;
	
content_list					:	decl_variable content_list
												{
													if(numerrors == 0){
														/* Inserting variables in the list */
														ast_node *content = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = content;
													
														stk_push(ast_stack, node);
													}
												}
											| decl_function content_list
												{
													if(numerrors == 0){
														/* Inserting functions in the list */
														ast_node *content = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = content;
													
														stk_push(ast_stack, node);
													}
												}
											|	{
													if(numerrors == 0){
														/* Avoiding future errors */
														stk_push(ast_stack, NULL);
													}
												}
											;
											
decl_variable					:	type ident_new 
												{
													/* Checking if variable declared void */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Inserting symbol in table */
														st_new($2, create_symbol(VARIABLE, $1, NO, 0, NO, NO, NULL));
														if(numerrors == 0){
															/* Generating AST node */
															ast_node *name = stk_pop(ast_stack);

															stk_push(ast_stack, ast_node_create(AST_VAR, $1, name->string, 0, 0,
																																	NULL, NULL, NULL));
															free(name);
														}
													}
												} '\n' 
												
											|	type ident_new '=' init_const 
												{
													/* Checking if variable declared void */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														if($4 == T_FLOAT && $1 < $4){
															printf("Line %d : type error in initialization\n",numline);
															numerrors++;
														} else {
															/* Inserting symbol in table */
															st_new($2, create_symbol(VARIABLE, $1, NO, 0, NO, YES, NULL));
															if(numerrors == 0){
																/* Generating AST node */
																ast_node **pars = malloc(sizeof(ast_node*));
																pars[0] = stk_pop(ast_stack);
																ast_node *name = stk_pop(ast_stack);

																stk_push(ast_stack, ast_node_create(AST_VAR, $1, name->string, 0, 0,
																																		pars, NULL, NULL));
																free(name);
															}
														}
													}
												} '\n' 
												
											|	type ident_new '[' C_INT ']' 
												{
													/* Checking if variable declared void */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Inserting symbol in table */
														st_new($2, create_symbol(VARIABLE, $1, YES, $4, NO, NO, NULL));
														if(numerrors == 0){
															/* Generating AST node */
															ast_node *name = stk_pop(ast_stack);

															stk_push(ast_stack, ast_node_create(AST_VAR, $1, name->string, $4, 0,
																																	NULL, NULL, NULL));
															free(name);
														}
													}
												} '\n' 
												
											|	type ident_new '[' C_INT ']' '=' '[' decl_coma_list ']' 
												{
													/* Checking if variable declared void */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Checking vector initializator size */
														if($8 == NULL){
															printf("Line %d : vector initialization size error\n",numline);
															numerrors++;
														} else {
															/* Checking positive size*/
															if($4 <= 0){
																printf("Line %d : vector size error\n",numline);
																numerrors++;
															}
															/* Checking initializator and constant size */
															if($4 != $8->tam){
																printf("Line %d : vector initialization size error\n",numline);
																numerrors++;
															}
															/* Checking type compatibility */
															if($8->tipo == T_FLOAT && $1 < $8->tipo){
																printf("Line %d : type error in initialization\n",numline);
																numerrors++;
															} else {
																/* Inserting symbol in table */
																st_new($2, create_symbol(VARIABLE, $1, YES, $4, NO, YES, NULL));
																if(numerrors == 0){
																	/* Generating AST node */
																	ast_node **pars = malloc(sizeof(ast_node*));
																	pars[0] = stk_pop(ast_stack);
																	ast_node *name = stk_pop(ast_stack);

																	stk_push(ast_stack, ast_node_create(AST_VAR, $1, name->string,  
																																			$4, 0, pars, NULL, NULL));
																	free(name);
																}
															}
															free($8);
														}
													}
												} '\n' 
												
											|	type ident_new '[' C_INT ']' '=' C_STRING  
												{
													/* Checking if variable declared other than char */												
													if($1 != T_CHAR){
														printf("Line %d : strings have to be declared char\n",numline);
														numerrors++;
													} else {
														/* Checking correct initialization size*/
														if($4 != string_size(yylval.string)){
															printf("Line %d : string initialization size error\n",numline);
															numerrors++;
														} else {
															/* Inserting symbol in table */
															st_new($2, create_symbol(VARIABLE, T_STRING, YES, $4, NO, YES, NULL));
															if(numerrors == 0){
																/* Generating AST node */
																ast_node **pars = malloc(sizeof(ast_node*));
																ast_node *name = stk_pop(ast_stack);
																pars[0] = ast_node_create(AST_CONST, AST_STRING, yylval.string, $4, 0, 
																													NULL, NULL, NULL);
																stk_push(ast_stack, ast_node_create(AST_VAR, AST_STRING, name->string,
																																		1, 0, pars, NULL, NULL));
																free(name);
															}
														}
													}
												} '\n' 
												
											|	CONST type ident_new '=' init_const 
												{
													/* Checking if variable declared void */
													if($2 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Checking type compatibility */
														if($5 == T_FLOAT && $2 < $5){
															printf("Line %d : type error in initialization\n",numline);
															numerrors++;
														} else {
															/* Inserting symbol in table */
															st_new($3, create_symbol(VARIABLE, $2, NO, 0, YES, YES, NULL));
															if(numerrors == 0){
																/* Generating AST node */
																ast_node **pars = malloc(sizeof(ast_node*));
																pars[0] = stk_pop(ast_stack);
																ast_node *name = stk_pop(ast_stack);

																stk_push(ast_stack, ast_node_create(AST_VAR, $2, name->string,
																																		 0, 0, pars, NULL, NULL));
																free(name);
															}
														}
													}
												} '\n' 
 
											|	CONST type ident_new '[' C_INT ']' '=' '[' decl_coma_list ']'
												{
													/* Checking if variable declared void */
													if($2 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Checking vector initializator size */
														if($9 == NULL){
															printf("Line %d : vector initialization size error\n",numline);
															numerrors++;
														} else {
															/* Checking positive size*/
															if($5 <= 0){
																printf("Line %d : vector size error\n",numline);
																numerrors++;
															}
															/* Checking initializator and constant size */
															if($5 != $9->tam){
																printf("Line %d : vector initialization size error\n",numline);
																numerrors++;
															}
															/* Checking type compatibility */
															if($9->tipo == T_FLOAT && $2 < $9->tipo){
																printf("Line %d : type error in initialization\n",numline);
																numerrors++;
															} else {
															/* Inserting symbol in table */
																st_new($3, create_symbol(VARIABLE, $2, YES, $5, YES, YES, NULL));
																if(numerrors == 0){
																/* Generating AST node */
																	ast_node **pars = malloc(sizeof(ast_node*));
																	pars[0] = stk_pop(ast_stack);
																	ast_node *name = stk_pop(ast_stack);

																	stk_push(ast_stack, ast_node_create(AST_VAR, $2, name->string,
																																			 $5, 0, pars, NULL, NULL));
																	free(name);
																}
															}
															free($9);
														}
													}
												} '\n' 

											|	CONST type ident_new '[' C_INT ']' '=' C_STRING  
												{
													/* Checking if variable declared other than char */
													if($2 != T_CHAR){
														printf("Line %d : strings have to be declared char\n",numline);
														numerrors++;
													} else {
														/* Checking correct initialization size*/
														if($5 != string_size(yylval.string)){
															printf("Line %d : string initialization size error\n",numline);
															numerrors++;
														} else {
															/* Inserting symbol in table */
															st_new($3, create_symbol(VARIABLE, T_STRING, YES, $5, YES, YES, NULL));
															if(numerrors == 0){
																/* Generating AST node */
																ast_node **pars = malloc(sizeof(ast_node*));
																ast_node *name = stk_pop(ast_stack);
															
																pars[0] = ast_node_create(AST_CONST, AST_STRING, yylval.string, $5, 0, 
																													NULL, NULL, NULL);
																stk_push(ast_stack, ast_node_create(AST_VAR, AST_STRING, name->string, 
																																		1, 0, pars, NULL, NULL));
																free(name);
															}
														}
													}
												} '\n' 
											
											/* Error handling code */
											|	type ident_new '=' error '\n' 
											|	type ident_new '[' C_INT ']' '=' error  '\n' 
											|	error ident_new '\n'
											|	error ident_new '=' init_const '\n' 
											|	error ident_new '[' C_INT ']' '\n' 
											|	error ident_new '[' C_INT ']' '=' '[' decl_coma_list ']' 
												{
													free($8);
												} '\n' 
											|	error ident_new '[' C_INT ']' '=' C_STRING 
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'

											|	type ident_new '[' C_INT error '\n' {free($2);}
											|	type ident_new '[' C_INT error '=' '[' decl_coma_list ']' 
												{
													free($8);
												}  '\n'
											|	type ident_new '[' C_INT error '=' C_STRING 
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'
											
											|	type ident_new '[' error ']' '\n' 
											|	type ident_new '[' error ']' '=' '[' decl_coma_list ']' 
												{
													free($8);
												}  '\n'
											|	type ident_new '[' error ']' '=' C_STRING 
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'

											|	type ident_new error C_INT ']' '\n'
											|	type ident_new error C_INT ']' '=' '[' decl_coma_list ']' 
												{
													free($8);
												}  '\n'
											|	type ident_new error C_INT ']' '=' C_STRING 
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'

											|	CONST type ident_new error C_INT ']' '=' '[' decl_coma_list ']' 
												{
													free($9);
												}  '\n'
											|	CONST type ident_new error C_INT ']' '=' C_STRING
												{
													if(yylval.string != NULL) free(yylval.string );
													free($3);
												} '\n'
											
											|	CONST type ident_new '[' C_INT ']' '=' error decl_coma_list ']' 
												{
													free($9);
												}  '\n'
										
											|	CONST type ident_new '=' error '\n'
											|	CONST type ident_new '[' C_INT ']' '=' error '\n' 											
											|	CONST type ident_new '[' C_INT error '=' '[' decl_coma_list ']' 
												{
													free($9);
												}  '\n'
											|	CONST type ident_new '[' C_INT error '=' C_STRING 
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'

											|	CONST type ident_new '[' error ']' '=' '[' decl_coma_list ']' 
												{
													free($3);
													free($9);
												}  '\n'
											|	CONST type ident_new '[' error ']' '=' C_STRING
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'
											
											|	CONST error ident_new '=' init_const '\n'
											|	CONST error ident_new '[' C_INT ']' '=' '[' decl_coma_list ']' 
												{
													free($9);
												}  '\n'
											|	CONST error ident_new '[' C_INT ']' '=' C_STRING
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'
											
											|	error type ident_new '=' init_const '\n'
											|	error type ident_new '[' C_INT ']' '=' '[' decl_coma_list ']' 
												{
													free($9);
												}  '\n'
											|	error type ident_new '[' C_INT ']' '=' C_STRING
												{
													if(yylval.string != NULL) free(yylval.string );
												} '\n'
											;
											
decl_function					:	type ident_new '(' decl_funct_par ')' 
												{
													/* Temporary level adjust for symbol creation */
													int val = 0;
													level = 0; 
													symbol_info *info = $4;
													/* Inserting parameters on symbol info */
													while(info){
														info = info->parametros;
														val++;
													}
													/* Inserting symbol in table */
													st_new($2, create_symbol(FUNCTION, $1, NO, val, NO, NO, $4)); 
													level = 1;
												} '\n' 
													decl_funct_block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *fblock = stk_pop(ast_stack);
														ast_node **pars = malloc(sizeof(ast_node*)*2);
														ast_node *block, *ablock, *vars, *avars, *aux;
													
														block = ablock = vars = avars = NULL;
														/* Inserting parameters */
														pars[0] = stk_pop(ast_stack);
														ast_node *ident = stk_pop(ast_stack);
														aux = fblock;
														/* Extracting variables from the rest of the code */
														while(aux) {
															if(aux->type == AST_VAR){
																if(vars == NULL){
																	vars = avars = aux;
																} else {
																	avars->sibling = aux;
																	avars = avars->sibling;
																}
															} else {
																if(block == NULL){
																	block = ablock = aux;
																} else {
																	ablock->sibling = aux;
																	ablock = ablock->sibling;
																}
															}
														
															aux = aux->sibling;
														}
														if(ablock != NULL) 
															ablock->sibling = NULL;
														if(avars != NULL) 
															avars->sibling = NULL;
													
														pars[1] = vars;
													
														stk_push(ast_stack, ast_node_create(AST_FUN, $1, ident->string, 
																								 0, 0, pars, block, NULL));
														free(ident);
													}
												}
												END '\n' 
												{
													out_function();
												}
												
											/* Error handling code */
											|	error ident_new '(' decl_funct_par ')' '\n' decl_funct_block END 
												{
													symbol_info *info = $4;
													symbol_info *aux;
													
													while(info != NULL){
														aux = info;
														info = info->parametros;
														free(aux);
													}
												}'\n'
											|	type ident_new error decl_funct_par ')' '\n' decl_funct_block END 
												{
													symbol_info *info = $4;
													symbol_info *aux;
													
													while(info != NULL){
														aux = info;
														info = info->parametros;
														free(aux);
													}
												} '\n'
											;
											
decl_funct_par				:	{in_function();} 
												decl_funct_par_list
												{$$ = $2;}
												
											| {
													if(numerrors == 0)
														stk_push(ast_stack, NULL);
													in_function();
													$$ = NULL;
												}
											;
										
decl_funct_par_list		:	decl_var_sim ',' decl_funct_par_list
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *list = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
														node->sibling = list;
													
														stk_push(ast_stack, node);
													}
													$1->parametros = $3;
													$$ = $1;
												}
												
											|	decl_var_sim
												{$$ = $1;}
											
											/* Error handling code */
											|	decl_var_sim error decl_funct_par_list
											;
											
decl_var_sim					:	type ident_new 
												{
													/* Checking posible void declaration */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Inserting symbol in table */
														st_new($2, create_symbol(VARIABLE, $1, NO, 0, NO, NO, NULL));
														/* Returning duplicated symbol info*/
														$$ = create_symbol(VARIABLE, $1, NO, 0, NO, NO, NULL);
														if(numerrors == 0){
															/* Generating AST node */
															ast_node *node = stk_pop(ast_stack);
															node->type = AST_VAR;
														
															stk_push(ast_stack, node);
														} else free($2);
													}
												}
												
											|	type ident_new '[' ']' 
												{
													/* Checking posible void declaration */
													if($1 < 0){
														printf("Line %d : variables can't be declared void\n",numline);
														numerrors++;
													} else {
														/* Inserting symbol in table */
														st_new($2, create_symbol(VARIABLE, $1, YES, 0, NO, NO, NULL));
														/* Returning duplicated symbol info*/
														$$ = create_symbol(VARIABLE, $1, YES, 0, NO, NO, NULL);

														if(numerrors == 0){
															/* Generating AST node */
															ast_node *node = stk_pop(ast_stack);
															node->type = AST_VAR;
															node->integer = 1;
														
															stk_push(ast_stack, node);
														}
													}
												}
											
											/* Error handling code */
											| error ident_new 
												{
													$$ = NULL;
												}
												
											| error ident_new '[' ']'
												{
													$$ = NULL;
												}
												
											| type ident_new '[' error
												{
													$$ = NULL;
												}
											;
											
decl_coma_list				:	init_const ',' decl_coma_list 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *list = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
														node->sibling = list;
													
														stk_push(ast_stack, node);
													}
													/* Inserting in list */
													$3->tipo = ($1 > $3->tipo ? $1 : $3->tipo);
													$3->tam += 1;
													$$ = $3;
												}
											|	init_const 
												{
													/* Creating symbol list */
													$$ = create_symbol(VARIABLE, $1, NO, 1, NO, NO, NULL);
												}
											
											/* Error handling code */
											|	init_const error decl_coma_list 
												{
													$3->tipo = ($1 > $3->tipo ? $1 : $3->tipo);
													$3->tam += 1;
													$$ = $3;
												}
											;
											
decl_funct_block			:	statement decl_funct_block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
														elm->sibling = block;
													
														stk_push(ast_stack, elm);
													}
												}
											|	decl_variable decl_funct_block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
													
														elm->sibling = block;
													
														stk_push(ast_stack, elm);
													}
												}
											|	expression '\n' decl_funct_block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
													
														elm->sibling = block;
													
														stk_push(ast_stack, elm);
													}
												}
											|	expr_io '\n' decl_funct_block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
													
														elm->sibling = block;
													
														stk_push(ast_stack, elm);
													}
												}
											|	{
													if(numerrors == 0)
														stk_push(ast_stack, NULL);
												}
											;
											
block									:	 statement block
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
														
														elm->sibling = block;
														
														stk_push(ast_stack, elm);
													}
												}
											|	 expression '\n' block
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
														
														elm->sibling = block;
														
														stk_push(ast_stack, elm);
													}
												}
											|	 expr_io '\n'block
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *elm = stk_pop(ast_stack);
														/* Adding node to top of list */
													
														elm->sibling = block;
													
														stk_push(ast_stack, elm);
													}
												}
											| {
													if(numerrors == 0)
														stk_push(ast_stack, NULL);
												}
											
											/* Error handling code */
											|	 expression error block
											|	 expr_io error block
											;
									
statement							:	stmnt_iteration
											|	stmnt_selection
											|	stmnt_jump
											;
										
stmnt_iteration				:	stmnt_iteration_head '\n' 
													block 
												END 
												{
													/* Out from loop */
													iteration--;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *iteration = stk_pop(ast_stack);
														iteration->content = block;
													
														stk_push(ast_stack, iteration);
													}
												}'\n'

											/* Error handling code */
											|	stmnt_iteration_head error block END '\n'
											|	stmnt_iteration_head '\n' block error '\n'
											;
										
stmnt_iteration_head	:	WHILE '(' expression ')' 
												{
													/* In loop */
													iteration++;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **expr = malloc(sizeof(ast_node*));
													
														expr[0] = stk_pop(ast_stack);
													
														stk_push(ast_stack, ast_node_create(AST_WHILE, AST_VOID, NULL, 
																																0, 0, expr, NULL, NULL));
													}
												}
											|	FOR '(' expression ';' expression ';' expression ')'  
												{
													/* Out loop */
													iteration++;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **expr = malloc(sizeof(ast_node*)*3);
													
														expr[2] = stk_pop(ast_stack);
														expr[1] = stk_pop(ast_stack);
														expr[0] = stk_pop(ast_stack);
													
														stk_push(ast_stack, ast_node_create(AST_FOR, AST_VOID, NULL, 
																																0, 0, expr, NULL, NULL));
													}
												}
											
											/* Error handling code */
											|	WHILE '(' expression error 
											|	FOR '(' expression ';' expression ';' expression error
											|	WHILE error expression error 
											|	FOR error expression ';' expression ';' expression ')'
											|	FOR '(' expression error expression ';' expression ')'
											|	FOR '(' expression ';' expression error expression ')'
											;
									
stmnt_selection				:	stmnt_selection_if
											|	stmnt_selection_switch
											;
									
stmnt_selection_if		:	IF '(' expression ')' '\n' 
													block 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node **expr = malloc(sizeof(ast_node*)*2);
													
														expr[0] = stk_pop(ast_stack);
														expr[1] = NULL;
														stk_push(ast_stack, ast_node_create(AST_IF, AST_VOID, NULL, 
																															 0, 0, expr, block, NULL));
													}
												}
												END '\n'
											|	IF '(' expression ')' '\n' 
													block 
												stmnt_selection_elsif 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **expr = malloc(sizeof(ast_node*)*2);
														expr[1] = stk_pop(ast_stack);
													
														ast_node *block = stk_pop(ast_stack);
													
														expr[0] = stk_pop(ast_stack);
													
														stk_push(ast_stack, ast_node_create(AST_IF, AST_VOID, NULL, 
																															0, 0, expr, block, NULL));
													}
												}
												END '\n'
											
											/* Error handling code */
											|	IF '(' expression error '\n' block END '\n'
											|	IF '(' expression error '\n' block stmnt_selection_elsif END '\n'
											|	IF '(' expression ')' error block END '\n'
											|	IF '(' expression ')' error block stmnt_selection_elsif END '\n'
											|	IF '(' expression ')' '\n' block error '\n'
											|	IF '(' expression ')' '\n' block stmnt_selection_elsif error '\n'
											|	IF error expression ')' '\n' block END '\n'
											|	IF error expression ')' '\n' block stmnt_selection_elsif END '\n'
											;
									
stmnt_selection_elsif	:	ELSIF '(' expression ')' '\n' 
													block
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node **expr = malloc(sizeof(ast_node*));
														expr[0] = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_ELSIF, AST_VOID, NULL, 
																																 0, 0, expr, block, NULL));
													}
												}
											|	ELSE '\n' 
													block
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_ELSE, AST_VOID, NULL, 
																																 0, 0, NULL, block, NULL));
													}
												}
											|	ELSIF '(' expression ')' '\n' 
													block 
												stmnt_selection_elsif
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *elsif = stk_pop(ast_stack);
														ast_node *block = stk_pop(ast_stack);
														ast_node **expr = malloc(sizeof(ast_node*));
														expr[0] = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_ELSIF, AST_VOID, NULL, 
																																 0, 0, expr, block, elsif));
													}
												}
											
											/* Error handling code */
											|	ELSIF error expression ')' '\n' block
											|	ELSIF error expression ')' '\n' block stmnt_selection_elsif
											|	ELSIF '(' expression error '\n' block
											|	ELSIF '(' expression error '\n' block stmnt_selection_elsif
											|	ELSIF '(' expression ')' error block
											|	ELSIF '(' expression ')' error block stmnt_selection_elsif
											;
									
stmnt_selection_switch:	SWITCH '(' expression ')' '\n' 
													stmnt_selection_case 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **expr = malloc(sizeof(ast_node*)*2);
														expr[1] = stk_pop(ast_stack);
														expr[0] = stk_pop(ast_stack);
														stk_push(ast_stack,  ast_node_create(AST_SWITCH, AST_VOID, NULL, 
																								 0, 0, expr, NULL, NULL));
													}
												}
												END '\n'
											
											/* Error handling code */
											|	SWITCH error expression ')' '\n' stmnt_selection_case END '\n'
											|	SWITCH '(' expression error '\n' stmnt_selection_case END '\n'
											|	SWITCH '(' expression ')' '\n' stmnt_selection_case error '\n'
											;
									
stmnt_selection_case	:	CASE integer_const ':' '\n' 
													block 
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
														ast_node *constant = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_CASE, constant->subtype, NULL, 
																								 constant->integer, 0, NULL, block, NULL));
														free(constant);
													}
												}
											|	CASE integer_const ':' '\n' 
													block 
												stmnt_selection_case
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *cases = stk_pop(ast_stack);
														ast_node *block = stk_pop(ast_stack);
														ast_node *constant = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_CASE, constant->subtype, NULL, 
																								 constant->integer, 0, NULL, block, cases));
														free(constant);
													}
												}
											| DEFAULT ':' '\n'
													block
												{ 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *block = stk_pop(ast_stack);
													
														stk_push(ast_stack,  ast_node_create(AST_DEFAULT, AST_VOID, NULL, 
																								 0, 0, NULL, block, NULL));
													}
												}
											;
									
												
stmnt_jump						:	CONTINUE 
												{
													/* Checking if inside loop */
													if(iteration == 0){
														printf("Line %d : continue statement shouldn't be here\n",numline);
														numerrors++;
													} else {
														if(numerrors == 0){
														/* Generating AST node */
															ast_node *node = ast_node_create(AST_CONT, AST_VOID, NULL, 0,
																															 0, NULL, NULL, NULL);
																										 
															stk_push(ast_stack, node);
														}
													}
												} '\n'
											|	BREAK 
												{
													/* Checking if inside loop */
													if(iteration == 0){
														printf("Line %d : break statement shouldn't be here\n",numline);
														numerrors++;
													} else {
														if(numerrors == 0){
														/* Generating AST node */
															ast_node *node = ast_node_create(AST_BREAK, AST_VOID, NULL, 0,
																															 0, NULL, NULL, NULL);
																										 
															stk_push(ast_stack, node);
														}
													}
												} '\n'
											| RETURN 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_RET, AST_VOID, NULL, 0,
																																		 0, NULL, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												} '\n'
											| RETURN expr_sec 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
												
														ast_node *node = ast_node_create(AST_RET, AST_VOID, NULL, 1,
																														 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												} '\n'
											;
expression						:	expr_asig 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack, ast_node_create(AST_EXPR, $1, NULL, 0,
																												0, NULL,  stk_pop(ast_stack), NULL));
													}
													$$ = $1;
												}
											|	expr_sec  
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack, ast_node_create(AST_EXPR, $1, NULL, 0,
																							0, NULL,  stk_pop(ast_stack), NULL));
													}
													$$ = $1;
												}
											;
											
expr_asig							:	variable '=' expr_sec 
												{
													if($1 != NULL){
														/* Checking if trying to modify constant variable */
														if($1->constant == YES){
															printf("Line %d : constant variable can't be modified\n",numline-1);
															numerrors++;
														}
														/*Checking type compatibility */
														if(($3 == T_FLOAT && $1->tipo < $3) || 
															 ($1->tipo == T_FLOAT && $1->tipo < $3) ||
															 ($1->tipo  <= T_INT   &&    T_INT < $3) ||  
															 ($3 < 0))
														{
															printf("Line %d : type error in assignment\n",numline-1);
															numerrors++;
														} 
														$$ = $1->tipo;
													}
													
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
												
														node = ast_node_create(AST_B_ASIG, $1->tipo, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}

												}
												
											/* Error handling code */
											|	variable '=' error 
												{
													if($1 != NULL){
														if($1->constant == YES){
															printf("Line %d : constant variable can't be modified\n",numline-1);
															numerrors++;
														}
														$$ = $1->tipo;
													}
												}
											;
											
expr_sec							:	expr_sec '*' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3); 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_MUL, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '/' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3); 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_DIV, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '%' expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT){
														printf("Line %d : %% is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_MOD, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}

												}
												
											|	expr_sec '+' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3); 
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_SUM, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '-' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_MIN, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec SRGT expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT){
														printf("Line %d : >> is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_SRGT, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec SLFT expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT){
														printf("Line %d : << is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
														node = ast_node_create(AST_B_SLFT, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec GEQ expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_GEQ, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec SEQ expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_SEQ, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '>' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_GT, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '<' expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_ST, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec NEQ expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_NEQ, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec EQ expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_EQ, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '|' expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT){
														printf("Line %d :  | is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_ORB, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '&' expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT){
														printf("Line %d : & is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_ANDB, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec '^' expr_sec 
												{
													/* Not ment for floats nor strings */
													if($1 > T_INT || $3 > T_INT ){
														printf("Line %d : ^ is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_XOR, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec OR expr_sec  
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_OR, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	expr_sec AND expr_sec 
												{
													$$ = ($1 > $3 ? $1 : $3);
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
													
														node->sibling = pars[0];
														pars[0] = node;
													
														node = ast_node_create(AST_B_AND, $$, NULL, 0,
																									 0, pars, NULL, NULL);
																									 
														stk_push(ast_stack, node);
													}
												}
												
											|	'!' expr_sec 
												{
													$$ = $2;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = ast_node_create(AST_U_NEG, $$, NULL, 0,
																														 0, pars, NULL, NULL);
														stk_push(ast_stack, node);
													}
												}

											|	'+' expr_sec 
												{
													$$ = $2;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = ast_node_create(AST_U_POS, $$, NULL, 0,
																														 0, pars, NULL, NULL);
														stk_push(ast_stack, node);
													}
												}

											|	'~' expr_sec 
												{
													/* Not ment for floats nor strings */
													if($2 > T_INT){
														printf("Line %d : ~ is an integer operation\n",numline-1);
														numerrors++;
													} 
													$$ = $2;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = ast_node_create(AST_U_NEGB, $$, NULL, 0,
																														 0, pars, NULL, NULL);
														stk_push(ast_stack, node);
													}
												}

											|	'-' expr_sec 
												{
													$$ = $2;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);
														ast_node *node = ast_node_create(AST_U_MIN, $$, NULL, 0, 
																														 0, pars, NULL, NULL);
														stk_push(ast_stack, node);
													}
												}

											|	'(' expr_sec ')' 
												{
													$$ = $2;
												}

											|	constant 
												{
													$$ = $1;
												}

											|	variable 
												{
													if($1 != NULL) $$ = $1->tipo;
												}

											|	funcall 
												{
													$$ = $1;
												}

											
											/* Error handling code */
											|	'(' expr_sec error 
												{
													$$ = $2;
												}

											;
											
expr_io								:	OUT out_var_list
												{
													if(numerrors == 0){
														/* Generating AST node list */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);													
														stk_push(ast_stack, ast_node_create(AST_OUT, AST_VOID, NULL, 0, 0, pars, NULL, NULL));
													}
												}
											|	IN variable
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node **pars = malloc(sizeof(ast_node*));
														pars[0] = stk_pop(ast_stack);													
														stk_push(ast_stack, ast_node_create(AST_IN, AST_VOID, NULL, 0, 0, pars, NULL, NULL));
													}
												}
											;
											
out_var_list					:	atom CON out_var_list
												{
													if(numerrors == 0){
														/* Generating AST node list */
														ast_node *list = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
														node->sibling = list;
														stk_push(ast_stack, node);
													}
												}
											|	atom
											;
										
variable							:	ident 
												{
													if($1 != NULL){
														if($1->tipo == T_STRING)
															$1->tipo = T_CHAR;
														$$ = $1;
													}
												}
												
											|	ident '[' expr_sec ']'
												{
													if($1 != NULL){
														/* Checking if trying to address non array variable */
														if($1->vector == 0){
															printf("Line %d : vector usage error\n",numline  );
															numerrors++;
														}
														if(numerrors == 0){
															/* Generating AST node */
															ast_node **expr = malloc(sizeof(ast_node*));
															expr[0] = stk_pop(ast_stack);
															ast_node *node = stk_pop(ast_stack);
															
															node->type_info = expr;
															
															stk_push(ast_stack, node);
															if($1->tipo == T_STRING)
																$1->tipo = T_CHAR;
															$$ = $1;
														}
													}
												}
											;
											
funcall_pars					:	expr_sec ',' funcall_pars
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *list = stk_pop(ast_stack);
														ast_node *node = stk_pop(ast_stack);
														node->sibling = list;
														stk_push(ast_stack, node);
													}
													$$ = create_symbol(VARIABLE, $1, NO, 0, NO, NO, $3);
												}
												
											|	expr_sec  
												{
													$$ = create_symbol(VARIABLE, $1, NO, 0, NO, NO, NULL);
												}
											
											/* Error handling code */
											|	expr_sec error funcall_pars 
												{
													$$ = create_symbol(VARIABLE, $1, NO, 0, NO, NO, $3);
												}
											;
											
funcall								:	ident '(' funcall_pars ')'
												{
													if($1 != NULL){
														if($1->parametros != NULL){
															int i = 0;
															symbol_info *aux;
															symbol_info *param_chk = $3;
															symbol_info *param_real = $1->parametros;
															/* Checking if function parameters are of the correct type */
															while(param_chk != NULL && param_real != NULL){
																i++;
																if(param_chk->tipo > param_real->tipo){
																	
																	if(!(param_chk->tipo == T_STRING && 
																		 param_real->tipo == T_CHAR && 
																		 param_real->vector == YES
																		 )){
																		printf("Line %d : function parameter %d type is wrong\n", numline, i);
																		numerrors++;
																	}
																}
																param_chk = param_chk->parametros;
																param_real = param_real->parametros;
															}
															/* Checking if number of function parameters coincide */
															if(param_chk != NULL || param_real != NULL){
																printf("Line %d : wrong number of parameters\n", numline);
																numerrors++;
															}
															
															/* Deleting useless information*/
															param_chk = $3;
															while(param_chk != NULL){
																aux = param_chk;
																param_chk = param_chk->parametros;
																free(aux);
															}
															if(numerrors == 0){
																/* Generating AST node */
																ast_node **type_info = malloc(sizeof(ast_node*));
																type_info[0] = stk_pop(ast_stack);
																ast_node *ident = stk_pop(ast_stack);
															
																stk_push(ast_stack, ast_node_create(AST_FUNCALL, $1->tipo, ident->string, $1->tam, 
																																 0, type_info, NULL, NULL));
															
																free(ident);
															}
															$$ = $1->tipo;
														} else {
															printf("Line %d : function does not have parameters\n",numline  );
															numerrors++;
														}
													}
												}

											|	ident '(' ')' 
												{
													if($1 != NULL){
														if($1->parametros == NULL){
															$$ = $1->tipo;
															if(numerrors == 0){
																/* Generating AST node */
																ast_node *ident = stk_pop(ast_stack);
															
																stk_push(ast_stack, ast_node_create(AST_FUNCALL, $1->tipo, ident->string, 0, 
																																 0, NULL, NULL, NULL));
															
																free(ident);
															}
														} else {
															printf("Line %d : function needs parameters\n",numline  );
															numerrors++;
														}
													}
												}
											;
											
											
atom 									:	 init_const
												{
													$$ = $1;
												}
											| C_STRING 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_STRING,yylval.string,0,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_STRING;
												}
											|	variable {$$ = $1->tipo;}
											;
											
init_const						: '+' C_FLT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_FLOAT, NULL, 
																											 0, yylval.real, NULL, NULL, NULL));
													}
													$$ = T_FLOAT;
												}
											|	'-' C_FLT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_FLOAT, NULL, 
																											 0, yylval.real*(-1), NULL, NULL, NULL));
													}
													$$ = T_FLOAT;
												}
											|	C_FLT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_FLOAT, NULL, 
																											 0, yylval.real, NULL, NULL, NULL));
													}
													$$ = T_FLOAT;
												}
											| integer_const
												{
													$$ = $1;
												}
											;
											
integer_const					: '+' C_INT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_INT, NULL, 
																									 yylval.entero, 0, NULL, NULL, NULL));
													}
												}
											|	'-' C_INT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_INT, NULL, 
																									 yylval.entero*(-1), 0, NULL, NULL, NULL));
													}
												}
											|	C_INT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_INT, NULL, 
																									 yylval.entero, 0, NULL, NULL, NULL));
													}
												}
											| C_CHAR 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_CHAR, NULL, 
																								 yylval.caracter, 0, NULL, NULL, NULL));
													}
												}
											| C_BOOL 
												{
													if(numerrors == 0){
														/* Generating AST node */
														stk_push(ast_stack,  ast_node_create(AST_CONST, AST_BOOL, NULL, 
																											 yylval.caracter, 0, NULL, NULL, NULL));
													}
												}
											;
											
constant							:	C_FLT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_FLOAT,NULL,0,yylval.real,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_FLOAT;
												}
											|	C_CHAR 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_CHAR,NULL,yylval.caracter,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_CHAR;
												}
											|	C_BOOL 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_BOOL,NULL,yylval.caracter,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_BOOL;
												}
											| C_STRING 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_STRING,yylval.string,0,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_STRING;
												}
											| C_INT 
												{
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_CONST, AST_INT,NULL,yylval.entero,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
													$$ = T_INT;
												}
											;

											;
											
type									:	FLOAT  
												{
													$$ = T_FLOAT;
												}
												
											|	INT  
												{
													$$ = T_INT;
												}
												
											|	CHAR  
												{
													$$ = T_CHAR;
												}
												
												
											|	BOOL  
												{
													$$ = T_BOOL;
												}
												
											|	VOID  
												{
													$$ = T_VOID;
												}
											;
											
ident									: IDENTIFIER 
												{
													/* Reading identifier from hash */
													$$ = st_find(yylval.string);
													if(numerrors == 0){
														/* Generating AST node */
														
														ast_node *node = ast_node_create(AST_IDENT, $$->tipo,yylval.string,($$->vector == YES? 1 : 0),0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
												}
											;
											
ident_new							: IDENTIFIER 
												{
													$$ = yylval.string;
													if(numerrors == 0){
														/* Generating AST node */
														ast_node *node = ast_node_create(AST_IDENT, AST_VOID,yylval.string,0,0,NULL,NULL,NULL);
														stk_push(ast_stack, node);
													}
												}
											;

%%			

ast_node *parse(char* file) {
	char c;
	symbol_info *main;
	
	/* Using input file for parsing */
	yyin=fopen(file,"r");
	
	if(yyin == NULL){
		fprintf(stderr, "Error   : Compiler initialization failed\n");
		exit(EXIT_FAILURE);
	}
	
	/* Creating global symbol table */
	if(!(symbol_table[0] = hashtbl_create(256, NULL))) {
		fprintf(stderr, "Error   : Compiler initialization failed\n");
		exit(EXIT_FAILURE);
	}

	/* Creating local symbol table */
	if(!(symbol_table[1] = hashtbl_create(256, NULL))) {
		fprintf(stderr, "Error   : Compiler initialization failed\n");
		exit(EXIT_FAILURE);
	}
	
	if(!(ast_stack = stk_new(256))){
		fprintf(stderr, "Error   : Compiler initialization failed\n");
		exit(EXIT_FAILURE);
	}
	
	/* Running phase one: syntactic and semantic analysis */
	yyparse();

	/* Searching for main function */
	main = st_find("main");

	if(main != NULL){
		if (main->clase != FUNCTION){
			printf("Line %d : function 'main' undeclared\n", numline);
			numerrors++;
		}
		
		if(main->parametros != NULL){
			printf("Line %d : function 'main' can't have parameters\n", numline);
			numerrors++;
		}
		
		if (main->tipo != T_INT) {
			printf("Line %d : function 'main' has to be declared 'int'\n", numline);
			numerrors++;
		}
	}
	
	/* Destroying symbol tables */
	st_destroy();
	fclose(yyin);
	
	ast_node *node;
	while(node = stk_pop(ast_stack)){
		ast_node_destroy(node);
	}
	
	stk_free(ast_stack);
	
	if(numerrors > 0){
		printf("\nParsing completed with %d errors\n",numerrors);
	} 
	
	return tree;
}

/* Standard bison error function */
int yyerror(char* mens) {
	printf("Line %d : %s\n",numline, mens);
	numerrors++;
}
