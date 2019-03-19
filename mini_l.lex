%{
#include <iostream>
#define YY_DECL yy::parser::symbol_type yylex()
#include "parser.tab.hh"
#include <string>
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

{ADD} 			{return yy::parser::make_ADD(loc);}
{SUB} 			{return  yy::parser::make_SUB(loc);}
{MULT} 			{return yy::parser::make_MULT(loc);}
{MOD} 			{return yy::parser::make_MOD(loc);}
{DIV} 			{return yy::parser::make_DIV(loc);}

{EQ} 			{return yy::parser::make_EQ(loc);}
{NEQ} 			{return yy::parser::make_NEQ(loc);}
{LT} 			{return yy::parser::make_LT(loc);}
{GT} 			{return yy::parser::make_GT(loc);}
{LTE} 			{return yy::parser::make_LTE(loc);}
{GTE} 			{return yy::parser::make_GTE(loc);}

{SEMICOLON} 		{return yy::parser::make_SEMICOLON(loc);}
{COLON} 		{return yy::parser::make_COLON(loc);}
{COMMA} 		{return yy::parser::make_COMMA(loc);}
{L_PAREN} 		{return yy::parser::make_L_PAREN(loc);}
{R_PAREN} 		{return yy::parser::make_R_PAREN(loc);}
{L_SQUARE_BRACKET} 	{return yy::parser::make_L_SQUARE_BRACKET(loc);}
{R_SQUARE_BRACKET} 	{return yy::parser::make_R_SQUARE_BRACKET(loc);}
{ASSIGN} 		{return yy::parser::make_ASSIGN(loc);}

{function} 		{return yy::parser::make_FUNCTION(loc);}
{BEGIN_PARAMS}		{return yy::parser::make_BEGIN_PARAMS(loc);}
{END_PARAMS}		{return yy::parser::make_END_PARAMS(loc);}
{BEGIN_LOCALS}		{return yy::parser::make_BEGIN_LOCALS(loc);}
{END_LOCALS}		{return yy::parser::make_END_LOCALS(loc);}
{BEGIN_BODY}		{return yy::parser::make_BEGIN_BODY(loc);}
{END_BODY}		{return yy::parser::make_END_BODY(loc);}
{INTEGER}		{return yy::parser::make_INTEGER(loc);}
{ARRAY}			{return yy::parser::make_ARRAY(loc);}
{OF}			{return yy::parser::make_OF(loc);}
{IF}			{return yy::parser::make_IF(loc);}
{THEN}			{return yy::parser::make_THEN(loc);}
{ENDIF}			{return yy::parser::make_ENDIF(loc);}
{ELSE}			{return yy::parser::make_ELSE(loc);}
{WHILE}			{return yy::parser::make_WHILE(loc);}
{DO}			{return yy::parser::make_DO(loc);}
{BEGINLOOP}		{return yy::parser::make_BEGINLOOP(loc);}
{ENDLOOP}		{return yy::parser::make_ENDLOOP(loc);}
{CONTINUE}		{return yy::parser::make_CONTINUE(loc);}
{READ}			{return yy::parser::make_READ(loc);}
{WRITE}			{return yy::parser::make_WRITE(loc);}
{AND}			{return yy::parser::make_AND(loc);}
{OR}			{return yy::parser::make_OR(loc);}
{NOT}			{return yy::parser::make_NOT(loc);}
{TRUE}			{return yy::parser::make_TRUE(loc); }
{FALSE}			{return yy::parser::make_FALSE(loc);}
{RETURN}		{return yy::parser::make_RETURN(loc);}

{IDENT} 		{return yy::parser::make_IDENT(yytext, loc);}
{NUMBER} 		{return yy::parser::make_NUMBER(atoi(yytext), loc);}
{WH}+			{loc.step();}
\n			{loc.lines(yyleng); loc.step();}
{TAB}+		        {loc.step();}
"##".*
{IDENT}_+ 			{std::cout << "Error. Invalid identifier \"" << yytext << "\" at: " << loc << std::endl;}
(_|{NUMBER})+({IDENT})	        {std::cout << "Error. Invalid identifier \"" << yytext << "\" at: " << loc << std::endl;}
.				{std::cout << "Error. Unrecognized symbol \"" << yytext << "\" at: " << loc << std::endl;}

    /* use this structure to pass the Token :
     * return yy::parser::make_TokenName(loc)
     * if the token has a type you can pass the
     * as the first argument. as an example we put
     * the rule to return token function.
     */


 <<EOF>>    {return yy::parser::make_END(loc);}
    /* your rules end */

%%
