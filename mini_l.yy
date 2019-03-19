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

enum token_type{variable, array, function}; 
struct id_struct{
    std::string s = "";
    enum token_type t;
};
struct dec_struct{
    std::string s = "";

};

struct decLoop_struct{
    std::string s = "";
};

struct idLoop_struct{
    std::string s = "";
};

struct state_struct{
    std::string s = "";
    int val;
};

struct stateLoop_struct{
    std::string s = "";
    int val;
};

struct var_struct{
    std::string s = "";
    int val;
};

struct expr_struct{
    std::string s = "";
    int val;
};
struct multiExpr_struct{
    std::string s = "";
    int val;
};
struct term_struct{
    std::string s = "";
    int val;
};
struct identVar_struct{
    std::string s = "";
    int val;
};
 
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
void fillTable(std::set<std::string> &s);
int isValid(std::string id);
void addToUsed(std::string, enum token_type t);
    /* define your symbol table, global variables,
     * list of keywords or any function you may need here */
std::map<std::string, enum token_type> usedVars;
std::set<std::string> keywordTable; 
int labelCnt = 0;
int tempCnt = 0;  

std::string output = "";
/* STRUCTS GO HERE!!!!!!!!!!!!!!!! */

    /* end of your code */
}

%token END 0 "end of file";

%start program

    /* specify tokens, type of non-terminals and terminals here */
%token	FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token	INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE IDENT NUMBER
%token	READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA

/*types*/
%type <int> NUMBER
%type <std::string> IDENT
%type <id_struct> id
%type <idLoop_struct>
%type <dec_struct> declaration
%type <decLoop_struct> dec_loop
%type <expr_struct> expression
%type <state_struct> statement
%type <stateLoop_struct> statement_loop
%type <var_struct> var
%type <multiExpr_struct> var
%type <term_struct> var
%type <identVar_struct> var
/*END TYPES*/

%right  ASSIGN
%left   OR
%left	AND 
%right  NOT
%left	EQ NEQ LT GT LTE GTE
%left   ADD SUB 
%left	MULT DIV MOD
%left	L_SQUARE_BRACKET R_SQUARE_BRACKET
%left   L_PAREN R_PAREN
    /* end of token specifications */

%%


    /* define your grammars here use the same grammars 
     * you used Phase 2 and modify their actions to generate codes
     * assume that your grammars start with prog_start
     */

program:        /* empty */  {printf("program -> epsilon\n");}
                | funct {printf("program -> function\n");}
                ;
funct:       FUNCTION id SEMICOLON BEGIN_PARAMS param_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement_loop END_BODY program
		{cout << "funct " << $2.s << "\n" << $8.s << "end funct";}
                ;
param_loop:     /* empty */ {printf("param_loop -> epsilon\n");}
                | declaration SEMICOLON param_loop {printf("param_loop -> declaration SEMICOLON param_loop\n");}
                | error;
dec_loop:       /* empty */  				{$$.s = "";}
                | declaration SEMICOLON dec_loop	{$$.s += $1.s +"\n" + $3.s;}
		| error;	

declaration:    ident_loop COLON INTEGER	{$$.s += $1.s;}
                | ident_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER	{printf("declaration -> ident_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
		;
ident_loop:     id 				{$$.s += ("." + $1.s);}
		| id COMMA ident_loop	{$$.s += ("." + $1.s + "\n" + $3.s);}
		; 

statement:      var ASSIGN expression	{;}
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
                | statement SEMICOLON statement_loop	{$$.s +=  ($1.s + "\n" + $3.s);}
		; 
bool_expr:      relation_and_expr 		{printf("bool_expr -> relation_and_expr\n");}
		| bool_expr OR relation_and_expr    {printf("bool_expr -> OR relation_and_expr\n");}
		;
relation_and_expr:	relation_expr 		{printf("relation_and_expr -> relation_expr\n");}
			| relation_and_expr AND relation_expr	{printf("relation_and_expr -> AND relatio_expr\n");}
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
ident_var:      var 				{$$.s += $1.s;}
		| NUMBER 			{printf("ident_var -> NUMBER%d\n", $1);}
		| L_PAREN expression R_PAREN	{printf("ident_var -> R_PAREN expression L_PAREN\n");}
		;
term:           ident_var 			{$$.s += $1.s;}
                | SUB ident_var			{printf("term -> SUB ident_var\n");}
		| ident_term			{printf("term -> ident_term\n");}
		;		
multi_express:  term 						{$$.s += $1.s;}
		| multi_express MULT term			{printf("multi_express -> multi_express MULT term\n");}
		| multi_express DIV term 			{printf("multi_express -> multi_express DIV term\n");}
		| multi_express MOD term			{printf("multi_express -> multi_express MOD term\n");}
		;
expression:     multi_express 				{$$.s += $1.s;}
		| expression ADD multi_express		{printf("expression -> expression ADD multi_express\n");}
		| expression SUB multi_express		{printf("expression -> expression SUB multi_express\n");}
		;
var:            id 	    							{$$.s += $1.s;}
		| id L_SQUARE_BRACKET expression R_SQUARE_BRACKET		{$$.s += ($1.s +"[" + $3.s + "]");}
		;
id:             IDENT 					{$$.s = $1; std::cout << $$.s << std::endl;};


%%

int main(int argc, char *argv[])
{
    yy::parser p;
    fillTable(keywordTable);
    return p.parse();
}

//Takes in the set "keywords" and fills with all of the
// string values pertaining to the reserved words
void fillTable(std::set<std::string> &s){
    s.insert("function");
    s.insert("beginparams");
    s.insert("endparams");
    s.insert("beginlocals");
    s.insert("endlocals");
    s.insert("beginbody");
    s.insert("endbody");
    s.insert("integer");
    s.insert("array");
    s.insert("of");
    s.insert("if");
    s.insert("then");
    s.insert("endif");
    s.insert("else");
    s.insert("while");
    s.insert("do");
    s.insert("beginloop");
    s.insert("endloop");
    s.insert("continue");
    s.insert("read");
    s.insert("write");
    s.insert("and");
    s.insert("or");
    s.insert("not");
    s.insert("true");
    s.insert("false");
    s.insert("return");
}

//Takes in a string and compares it to see whether
// or not it is contained within the set of keywords
// or if it has been previously declared.
// IF either of the above conditions are met, return -1
// and goto semantic error.
int isValid(std::string id){
    int result = 0;
    std::map<std::string, enum token_type>::iterator itr1;
    std::set<std::string>::iterator itr2;
    itr1 = usedVars.find(id);
    itr2 = keywordTable.find(id);
        if(itr1 != usedVars.end() && itr2 != keywordTable.end()){
            result = 1;
        }
    
    return result;
}

//If an identifier is valid, add it to the map of
//used variable names. Include the type of variable
// i.e "varaiable" = 0, "array" = 1 and
// "function" == 2
void addToUsed(std::string id, enum token_type t){
    if(isValid(id)){
        usedVars.insert(std::pair<std::string, enum token_type>(id, t));
    }
}

 
void yy::parser::error(const yy::location& l, const std::string& m)
{
    std::cerr << l << ": " << m << std::endl;
}

std::string makeLabel(){
    std::string s = "__label__" + labelCnt;
    labelCnt++; 
    return s;
}

std::string makeTemp(){
    std::string s = "__temp__" + tempCnt;
    tempCnt++;
    return s;
}
