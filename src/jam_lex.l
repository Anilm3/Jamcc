/********************************************************************************
* JAM v1.0 - jam_lex.l                                                          *
*                                                                               *
* Copyright (C) 2010 Anil Motilal Mahtani Mirchandani(anil.mmm@gmail.com)       *
*                    Mikel Ganuza Estremera(migaes.mail@gmail.com               *
* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html> *
* This is free software: you are free to change and redistribute it.            *
* There is NO WARRANTY, to the extent permitted by law.                         *
*                                                                               *
*********************************************************************************/
 
%{

#include "jam_sin.tab.h"
#include "util.h"

int numline = 1;


%}

%option noyywrap

NUM    [0-9]
ALPHA	[a-zA-Z]
ALPHNUM {ALPHA}|{NUM}
HEXCH [a-fA-F]|{NUM}

%%

	/* Multicharacter operators */
"&&"																{return AND;}
"||"																{return OR;}
"=="																{return EQ;}
"!="																{return NEQ;}
"<="																{return SEQ;}
">="																{return GEQ;}
"<<"																{return SLFT;}
">>"																{return SRGT;}
"++"																{return CON;}
"<++"																{return OUT;}
">++"																{return IN;}

	/* Keywords */
if																	{return IF;}
else																{return ELSE;}
elsif																{return ELSIF;}
for																	{return FOR;}
while																{return WHILE;}
continue														{return CONTINUE;}
break																{return BREAK;}
switch															{return SWITCH;}
case																{return CASE;}
end																	{return END;}
return 															{return RETURN;}
void 																{return VOID;}
float																{return FLOAT;}
char																{return CHAR;}
int																	{return INT;}
const																{return CONST;}
bool																{return BOOL;}
default															{return DEFAULT;}


	/* Boolean constants: 1 or 0 */
true																{yylval.caracter = 1; return C_BOOL;}
false																{yylval.caracter = 0; return C_BOOL;}

	/* Integer constants */
	/* scanf is used for conversion from octal, hex and decimal ASCII strings to integers */
	/* strtobin converts a binary ASCII string to integers */
0[bB](0|1)+													{yylval.entero = strtobin(&yytext[2]); return C_INT;}
0x{HEXCH}+													{sscanf(yytext, "%x", &yylval.entero); return C_INT;}
0([0-7])+														{sscanf(yytext, "%o", &yylval.entero); return C_INT;}
{NUM}+															{sscanf(yytext, "%d", &yylval.entero); return C_INT;}

	/* Identifiers */
{ALPHA}({ALPHNUM}|[_])* 						{yylval.string = strdup(yytext); return IDENTIFIER;}

	/* Float constants */
	/* scanf is used for conversion from floating point ASCII strings to floats */
{NUM}*"."{NUM}+											{sscanf(yytext, "%f", &yylval.real); return C_FLT;}
{NUM}*"."{NUM}+[eE]("+"|-)?{NUM}+		{sscanf(yytext, "%f", &yylval.real); return C_FLT;}
{NUM}+[eE]("+"|-)?{NUM}+						{sscanf(yytext, "%f", &yylval.real); return C_FLT;}

	/* String constants */
"\""[^"]*"\""												{yylval.string = strdup(yytext); return C_STRING;}

	/* Character constants */
"'\\"[abfnrtv\\\'\"]"'"							{yylval.caracter = get_scape(yytext[2]); return C_CHAR;}
"'"."'"															{yylval.caracter = yytext[1]; return C_CHAR;}

	/* Ignoring comments, spaces, tabs and blank lines */
^[ \t]*#.*\n												{numline++;}
^[ \t]*\n														{numline++;}
[ \t]+						 									

	/* Single character operators */
.																		{return yytext[0];}

	/* New Line */
\n		 															{numline++; return yytext[0];}


%%

