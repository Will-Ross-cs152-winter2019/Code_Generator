%{
#include <iostream>
#define YY_DECL yy::parser::symbol_type yylex()
#include "parser.tab.hh"

static yy::location loc;
%}

%option noyywrap 

%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

    /* your definitions here */

/*
* Numbers, letters, identifiers
*/
DIGIT 	0|1|2|3|4|5|6|7|8|9
LOWER 	[a-z]
UPPER 	[A-Z]
LETTER 	({LOWER}|{UPPER})
NUMBER 	{DIGIT}+
FLOAT 	{DIGIT}*\.{DIGIT}+
IDENT 	({LETTER}({LETTER}|{DIGIT}|_)*({LETTER}|{DIGIT}))|{LETTER}
/*
* Arithmetic Symbols
*/

ADD 	\+
SUB 	-
MULT 	\*
DIV 	\/
MOD 	%

/*
* Comparison Operators
*/

EQ 	==
NEQ 	<>
LT 	<
GT 	>
LTE 	<=
GTE 	>=

/*
* Other Special Symbols
*/

SEMICOLON		;
COLON 			:
COMMA 			,
L_PAREN 		\(
R_PAREN 		\)
L_SQUARE_BRACKET	\[
R_SQUARE_BRACKET 	\]
ASSIGN :=
WH			" "
TAB			\t
/*
* Reserved Words
*/

function        "function"
BEGIN_PARAMS	"beginparams"
END_PARAMS	"endparams"
BEGIN_LOCALS	"beginlocals"
END_LOCALS	"endlocals"
BEGIN_BODY	"beginbody"
END_BODY	"endbody"
INTEGER		"integer"
ARRAY		"array"
OF		"of"
IF		"if"
THEN		"then"
ENDIF		"endif"
ELSE		"else"
WHILE		"while"
DO		"do"
BEGINLOOP	"beginloop"
ENDLOOP		"endloop"
CONTINUE	"continue"
READ		"read"
WRITE		"write"
AND		"and"
OR		"or"
NOT		"not"
TRUE		"true"
FALSE		"false"
RETURN		"return"

    /* your definitions end */

%%

%{
loc.step(); 
%}

    /* your rules here */

{ADD} 			{numChar+= yyleng; return ADD;}
{SUB} 			{numChar+= yyleng; return SUB;}
{MULT} 			{numChar+= yyleng; return MULT;}
{MOD} 			{numChar+= yyleng; return MOD;}
{DIV} 			{numChar+= yyleng; return DIV;}

{EQ} 			{numChar+= yyleng; return EQ;}
{NEQ} 			{numChar+= yyleng; return NEQ;}
{LT} 			{numChar+= yyleng; return LT;}
{GT} 			{numChar+= yyleng; return GT;}
{LTE} 			{numChar+= yyleng; return LTE;}
{GTE} 			{numChar+= yyleng; return GTE;}

{SEMICOLON} 		{numChar+= yyleng; return SEMICOLON;}
{COLON} 		{numChar+= yyleng; return COLON;}
{COMMA} 		{numChar+= yyleng; return COMMA;}
{L_PAREN} 		{numChar+= yyleng; return L_PAREN;}
{R_PAREN} 		{numChar+= yyleng; return R_PAREN;}
{L_SQUARE_BRACKET} 	{numChar+= yyleng; return L_SQUARE_BRACKET;}
{R_SQUARE_BRACKET} 	{numChar+= yyleng; return R_SQUARE_BRACKET;}
{ASSIGN} 		{numChar+= yyleng; return ASSIGN;}

{function} 		{numChar+= yyleng; return FUNCTION;}
{BEGIN_PARAMS}		{numChar+= yyleng; return BEGIN_PARAMS;}
{END_PARAMS}		{numChar+= yyleng; return END_PARAMS;}
{BEGIN_LOCALS}		{numChar+= yyleng; return BEGIN_LOCALS;}
{END_LOCALS}		{numChar+= yyleng; return END_LOCALS;}
{BEGIN_BODY}		{numChar+= yyleng; return BEGIN_BODY;}
{END_BODY}		{numChar+= yyleng; return END_BODY;}
{INTEGER}		{numChar+= yyleng; return INTEGER;}
{ARRAY}			{numChar+= yyleng; return ARRAY;}
{OF}			{numChar+= yyleng; return OF;}
{IF}			{numChar+= yyleng; return IF;}
{THEN}			{numChar+= yyleng; return THEN;}
{ENDIF}			{numChar+= yyleng; return ENDIF;}
{ELSE}			{numChar+= yyleng; return ELSE;}
{WHILE}			{numChar+= yyleng; return WHILE;}
{DO}			{numChar+= yyleng; return DO;}
{BEGINLOOP}		{numChar+= yyleng; return BEGINLOOP;}
{ENDLOOP}		{numChar+= yyleng; return ENDLOOP;}
{CONTINUE}		{numChar+= yyleng; return CONTINUE;}
{READ}			{numChar+= yyleng; return READ;}
{WRITE}			{numChar+= yyleng; return WRITE;}
{AND}			{numChar+= yyleng; return AND;}
{OR}			{numChar+= yyleng; return OR;}
{NOT}			{numChar+= yyleng; return NOT;}
{TRUE}			{numChar+= yyleng; return TRUE; }
{FALSE}			{numChar+= yyleng; return FALSE;}
{RETURN}		{numChar+= yyleng; return RETURN;}

{IDENT} 		{numChar += yyleng; yylval.op = yytext; return IDENT;}
{NUMBER} 		{numChar += yyleng; yylval.val = atoi(yytext); return NUMBER;}
{WH}+			{numChar += yyleng;}
\n			{++numLines; numChar = 1;}
{TAB}			{numChar += 3;}
"##".*
{IDENT}_+ 			{printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", numLines, numChar, yytext);}
(_|{NUMBER})+({IDENT})		{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", numLines, numChar, yytext);}
.				{printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", numLines, numChar, yytext);}

    /* use this structure to pass the Token :
     * return yy::parser::make_TokenName(loc)
     * if the token has a type you can pass the
     * as the first argument. as an example we put
     * the rule to return token function.
     */

function       {return yy::parser::make_FUNCTION(loc);}

 <<EOF>>    {return yy::parser::make_END(loc);}
    /* your rules end */

%%
