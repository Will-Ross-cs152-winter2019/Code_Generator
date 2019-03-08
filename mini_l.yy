%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
    /* you may need these deader files 
     * add more header file if you need more
     */
#include <list>
#include <string>
#include <functional>
    /* define the sturctures using as types for non-terminals */

    /* end the structures for non-terminal types */
}


%code
{
#include "parser.tab.hh"

    /* you may need these deader files 
     * add more header file if you need more
     */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();

    /* define your symbol table, global variables,
     * list of keywords or any function you may need here */
    
    /* end of your code */
}

%token END 0 "end of file";

%start program

    /* specify tokens, type of non-terminals and terminals here */
%token	FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token	INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token	READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA
%token <int> NUMBER
%token <char*> IDENT
%left	MULT DIV MOD ADD SUB 
%left	EQ NEQ LT GT LTE GTE
%left	L_SQUARE_BRACKET R_SQUARE_BRACKET L_PAREN R_PAREN
%left	AND OR
%right	NOT ASSIGN
    /* end of token specifications */

%%


    /* define your grammars here use the same grammars 
     * you used Phase 2 and modify their actions to generate codes
     * assume that your grammars start with prog_start
     */

program:        /* empty */  {printf("program -> epsilon\n");}
                | function {printf("program -> function\n");}
                ;
function:       FUNCTION id SEMICOLON BEGIN_PARAMS param_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement_loop END_BODY program
		{printf("function -> FUNCTION id SEMICOLON BEGIN_PARAMS dec_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement_loop END_BODY program\n");}
                ;
param_loop:     /* empty */ {printf("param_loop -> epsilon\n");}
                | declaration SEMICOLON param_loop {printf("param_loop -> declaration SEMICOLON param_loop\n");}
                | error;
dec_loop:       /* empty */  				{printf("dec_loop -> epsilon\n");}
                | declaration SEMICOLON dec_loop	{printf("dec_loop -> declaration SEMICOLON dec_loop\n");}
		| error;	
declaration:    ident_loop COLON INTEGER 							{printf("declaration -> ident_loop COLON INTEGER\n");}
                | ident_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER	{printf("declaration -> ident_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
		;
ident_loop:     id 				{printf("ident_loop -> id\n");}
		| id COMMA ident_loop	{printf("ident_loop -> id COMMA ident_loop\n");}
		; 
statement:      var ASSIGN expression	{printf("statement -> var ASSIGN expression\n");}
                | if_state		{printf("statement -> if_state\n");}
                | while_state		{printf("statement -> while_state\n");}
                | dowhile_state		{printf("statement -> dowhile_state\n");}
                | read_state		{printf("statement -> read_state\n");}
                | write_state		{printf("statement -> write_state\n");}
                | CONTINUE 		{printf("statement -> CONTINUE\n");}
		| RETURN expression	{printf("statement -> RETURN expression\n");}
		;
if_state:       IF bool_expr THEN statement_loop else_loop ENDIF		{printf("if_state -> IF bool_expr THEN statement SEMICOLON statement_loop else_loop ENDIF\n");}
		; 
while_state:    WHILE bool_expr BEGINLOOP statement_loop ENDLOOP		{printf("while_state -> WHILE bool_expr BEGINLOOP statement SEMICOLON statement_loop ENDLOOP\n");}
		;
dowhile_state:	DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr 		{printf("dowhile_state -> DO BEGINLOOP statement SEMICOLON statement_loop ENDLOOP WHILE bool_expr\n");}
		;
read_state:     READ var_loop		{printf("read_state -> READ var_loop\n");}
		;
write_state:    WRITE var_loop		{printf("write_state -> WRITE var_loop\n");}
		;
var_loop:       var 			{printf("var_loop -> var\n");}
		| var COMMA var_loop	{printf("var_loop -> var COMMA var_loop\n");}
		| error;
else_loop:      /* empty */					{printf("else_loop -> epsilon\n");}  
                | ELSE statement_loop				{printf("else_loop -> ELSE statement SEMICOLON statement_loop\n");}
		;
statement_loop: /*empty */ {printf("statement_loop -> epsilon\n");}		 
                | statement SEMICOLON statement_loop	{printf("statement_loop -> statement SEMICOLON statement_loop\n");}
		; 
bool_expr:      relation_and_expr 		{printf("bool_expr -> relation_and_expr\n");}
		| OR relation_and_expr		{printf("bool_expr -> OR relation_and_expr\n");}
		;
relation_and_expr:	relation_expr 		{printf("relation_and_expr -> relation_expr\n");}
			| AND relation_expr	{printf("relation_and_expr -> AND relatio_expr\n");}
			;
relation_expr:  NOT relation_expr		{printf("relation_expr -> NOT relation_expr\n");}
                | expression comp expression	{printf("relation_expr -> expression comp expression\n");}
                | TRUE				{printf("relation_expr -> TRUE\n");}
                | FALSE				{printf("relation_expr -> FALSE\n");}
                | L_PAREN bool_expr R_PAREN	{printf("relation_expr -> L_PAREN bool_expr R_PAREN\n");}
		;
comp:	        EQ 		{printf("comp -> EQ\n");}
		| NEQ 		{printf("comp -> NEQ\n");}
		| LT 		{printf("comp -> LT\n");}
		| GT 		{printf("comp -> GT\n");}
		| LTE 		{printf("comp -> LTE\n");}
		| GTE 		{printf("comp -> GTE\n");}
		| error;	
para:        	expression		        {printf("para -> expression");}
                | expression COMMA para         {printf("para -expression COMMA para");};
		
ident_term:     id L_PAREN para R_PAREN 	{printf("ident_term -> id L_PAREN para R_PAREN\n");}
		;  
ident_var:      var 				{printf("ident_var -> var\n");}
		| NUMBER 			{printf("ident_var -> NUMBER%d\n", $1);}
		| L_PAREN expression R_PAREN	{printf("ident_var -> R_PAREN expression L_PAREN\n");}
		;
term:           ident_var 			{printf("term -> ident_var\n");}
                | SUB ident_var			{printf("term -> SUB ident_var\n");}
		| ident_term			{printf("term -> ident_term\n");}
		;		
multi_express:  term 						{printf("multi_express -> term\n");}
		| multi_express MULT term			{printf("multi_express -> multi_express MULT term\n");}
		| multi_express DIV term 			{printf("multi_express -> multi_express DIV term\n");}
		| multi_express MOD term			{printf("multi_express -> multi_express MOD term\n");}
		;
expression:     multi_express 				{printf("expression -> multi_express\n");}
		| expression ADD multi_express		{printf("expression -> expression ADD multi_express\n");}
		| expression SUB multi_express		{printf("expression -> expression SUB multi_express\n");}
		;
var:            id 	    							{printf("var -> id\n");}
		| id L_SQUARE_BRACKET expression R_SQUARE_BRACKET		{printf("id L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
		;
id:             IDENT 					{printf("IDENT -> %s\n", $1);};


%%

int main(int argc, char *argv[])
{
    yy::parser p;
    return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
    std::cerr << l << ": " << m << std::endl;
}
