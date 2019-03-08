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

{function} 		{loc.lines(1); loc.step(); return yy::parser::make_FUNCTION(loc);}
{BEGIN_PARAMS}		{numChar+= yyleng; return yy::parser::make_BEGIN_PARAMS(loc);}
{END_PARAMS}		{numChar+= yyleng; return yy::parser::make_END_PARAMS(loc);}
{BEGIN_LOCALS}		{numChar+= yyleng; return yy::parser::make_BEGIN_LOCALS(loc);}
{END_LOCALS}		{numChar+= yyleng; return yy::parser::make_END_LOCALS(loc);}
{BEGIN_BODY}		{numChar+= yyleng; return yy::parser::make_BEGIN_BODY(loc);}
{END_BODY}		{numChar+= yyleng; return yy::parser::make_END_BODY(loc);}
{INTEGER}		{numChar+= yyleng; return yy::parser::make_INTEGER(loc);}
{ARRAY}			{numChar+= yyleng; return yy::parser::make_ARRAY(loc);}
{OF}			{numChar+= yyleng; return yy::parser::make_OF(loc);}
{IF}			{numChar+= yyleng; return yy::parser::make_IF(loc);}
{THEN}			{numChar+= yyleng; return yy::parser::make_THEN(loc);}
{ENDIF}			{numChar+= yyleng; return yy::parser::make_ENDIF(loc);}
{ELSE}			{numChar+= yyleng; return yy::parser::make_ELSE(loc);}
{WHILE}			{numChar+= yyleng; return yy::parser::make_WHILE(loc);}
{DO}			{numChar+= yyleng; return yy::parser::make_DO(loc);}
{BEGINLOOP}		{numChar+= yyleng; return yy::parser::make_BEGINLOOP(loc);}
{ENDLOOP}		{numChar+= yyleng; return yy::parser::make_ENDLOOP(loc);}
{CONTINUE}		{numChar+= yyleng; return yy::parser::make_CONTINUE(loc);}
{READ}			{numChar+= yyleng; return yy::parser::make_READ(loc);}
{WRITE}			{numChar+= yyleng; return yy::parser::make_WRITE(loc);}
{AND}			{numChar+= yyleng; return yy::parser::make_AND(loc);}
{OR}			{numChar+= yyleng; return yy::parser::make_OR(loc);}
{NOT}			{numChar+= yyleng; return yy::parser::make_NOT(loc);}
{TRUE}			{numChar+= yyleng; return yy::parser::make_TRUE(loc); }
{FALSE}			{numChar+= yyleng; return yy::parser::make_FALSE(loc);}
{RETURN}		{numChar+= yyleng; return yy::parser::make_RETURN(loc);}

{IDENT} 		{numChar += yyleng; yylval.op = yytext; return yy::parser::make_IDENT(loc);}
{NUMBER} 		{numChar += yyleng; yylval.val = atoi(yytext); return yy::parser::make_NUMBER(atoi(yytext), loc);}
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
