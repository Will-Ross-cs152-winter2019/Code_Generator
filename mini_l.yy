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
#include <vector>
#include <stack>
#include <functional>
    /* define the sturctures using as types for non-terminals */

enum err_code{unDec, noMain, reDef, key, noIn, badUse, out, badCont} ;
enum token_type{var, array, function}; 
enum expr_type{reg, arr};
enum comp_type{eq, neq, lte, gte, lt, gt, no}; 
/* STRUCTS BEGIN HERE!!!!! */
struct label_struct{
    std::string s = "";
    std::string name;

};
struct funct_struct{
    std::string s = "";
    std::vector<std::string> f;
};

struct function_struct{
    std::string s = "";
};

struct prog_struct{
    std::string s = "";
};

struct temp_struct{
    std::string s;
    std::string name;
    int val;
};
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
    std::string id_val = "";
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
    enum expr_type t = expr_type::reg;
    std::vector<std::string> arr;
    std::string tmp_num;
};

struct expr_struct{
    std::string s = "";
    std::string tmp_num;
    enum expr_type t = expr_type::reg;
    int LHS = 0;
    std::vector<std::string> arr;
};
struct multiExpr_struct{
    std::string s = "";
    std::string tmp_num;
    enum expr_type t = expr_type::reg;
    int LHS;
    std::vector<std::string> arr;
};
struct term_struct{
    std::string s = "";
    std::string tmp_num;
    enum expr_type t = expr_type::reg;
    int val;
    std::vector<std::string> arr;
};
struct identVar_struct{
    std::string s = "";
    std::string tmp_num;
    enum expr_type t = expr_type::reg;
    std::string name;
};
struct varWriteLoop_struct{
    std::string s = "";
    enum expr_type t = expr_type::reg;
    int val;
};
struct varReadLoop_struct{
    std::string s = "";
    enum expr_type t = expr_type::reg;
    int val;
};
struct writeState_struct{
    std::string s = "";
    int val;
};
struct readState_struct{
    std::string s= "";
    int val;
};
struct comp_struct{
    std::string s = "";
    enum comp_type t;
};
struct rel_struct{
    std::string s = "";
    std::string tmp_num;
    std::string lbl_num;
};
struct relAnd_struct{
    std::string s = "";
    std::string tmp_num;
    std::string lbl_num;
};
struct bool_struct{
    std::string s = "";
    std::string tmp_num;
    std::string lbl_num;
};
struct param_struct{
    std::string s = "";
};
struct paramLoop_struct{
    std::string s = "";
};
struct identTerm_struct{
    std::string s = "";
    std::string tmp_num;
};
struct elseLoop_struct{
    std::string s = "";
};
struct if_struct{
    std::string s = "";
    std::string condition;
};
struct while_struct{
    std::string s = "";
    std::string condition;
};
struct doWhile_struct{
    std::string s = "";
    std::string condition;
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

/* FORWARD DECLARATIONS */
yy::parser::symbol_type yylex();
void fillTable(std::set<std::string> &s);
std::string writeVar(std::string s, enum expr_type t);
std::string readVar(std::string s, enum expr_type t);
std::string printExpr(enum expr_type t);
std::string declareTemps();
std::string assignParams();
std::string declareLabels();
void semanticErr(enum err_code ec);
int isValid(std::string id);
std::string makeTemp();
std::string makeLabel();
void addToUsed(std::string, enum token_type t);
std::string readComp(enum comp_type t);

/* VECTORS */
std::vector<std::string> usedFuncts;
std::vector<std::string> writes;
std::vector<std::string> reads;
std::vector<std::string> temps;
std::vector<std::string> labels;
std::vector<std::string> parameters;

    /* define your symbol table, global variables,
     * list of keywords or any function you may need here */
std::stack<std::string> conts;
std::map<std::string, enum token_type> usedVars;
std::set<std::string> keywordTable; 
int labelCnt = 0;
int tempCnt = 0;  

std::string output = "";

int searchFuncts(std::string f){
    int result = 1;
    for(unsigned i = 0; i < usedFuncts.size(); i++){
        if(usedFuncts.at(i).compare(f) == 0){
            result = 0; 
        }
    }
    return result;
}
    /* end of your code */
}

%token END 0 "end of file";

%start prog_start

    /* specify tokens, type of non-terminals and terminals here */
%token	FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token	INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE IDENT NUMBER
%token	READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA

/*types*/
%type <funct_struct> funct
%type <prog_struct> program
%type <int> NUMBER
%type <std::string> IDENT
%type <id_struct> id
%type <idLoop_struct> ident_loop
%type <dec_struct> declaration
%type <decLoop_struct> dec_loop
%type <expr_struct> expression
%type <state_struct> statement
%type <stateLoop_struct> statement_loop
%type <var_struct> var
%type <multiExpr_struct> multi_express
%type <term_struct> term
%type <identVar_struct> ident_var
%type <writeState_struct> write_state
%type <readState_struct> read_state
%type <varWriteLoop_struct> varWrite_loop
%type <varReadLoop_struct> varRead_loop
%type <comp_struct> comp
%type <rel_struct> relation_expr
%type <relAnd_struct> relation_and_expr
%type <bool_struct> bool_expr
%type <paramLoop_struct> param_loop
%type <param_struct> para
%type <identTerm_struct> ident_term
%type <elseLoop_struct> else_loop
%type <if_struct> if_state
%type <while_struct> while_state
%type <doWhile_struct> dowhile_state
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
prog_start:     program     {std::cout << $1.s;if(!searchFuncts("main")){semanticErr(err_code::noMain);}}

program:        /* empty */  {$$.s += "";}
                    | funct program {$$.s += $1.s + $2.s; }
                ;

funct:       	FUNCTION id SEMICOLON BEGIN_PARAMS param_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement_loop END_BODY
		{
                usedFuncts.push_back($2.s);
                $$.s += "func" + $2.s + "\n" + declareTemps() + $5.s  + assignParams() + $8.s + $11.s + "endfunc\n"; /*addToUsed($2.s, token_type::function)*/;}
                ;

param_loop:     /* empty */ 				{$$.s = "";}
                | declaration SEMICOLON param_loop 	{$$.s += $1.s + $3.s; parameters.push_back($1.s);}
                ;

dec_loop:       /* empty */  	{$$.s = "";}
                | declaration SEMICOLON dec_loop	{$$.s += $1.s + "\n" + $3.s;}
		;	

declaration:    ident_loop COLON INTEGER	{$$.s += $1.s; /*addToUsed($1.s, token_type::var);*/}
                | ident_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER	
                    {$$.s += ".[]" + $1.s + ", " + std::to_string($5); /*addToUsed($1.s, token_type::array);*/}
		;

ident_loop:     id 				{$$.s += ("." + $1.s);}
		| id COMMA ident_loop	{$$.s += ("." + $1.s + "\n" + $3.s); /*addToUsed($1.s, token_type::var);*/}
		; 

statement:      var ASSIGN expression	{
                    if($1.t == expr_type::arr){
                        $$.s += $1.s + $3.s;
                        $$.s += "[]=" + $1.arr.at(0) + "," + $1.arr.at(1) + "," + $3.tmp_num;
                    }
                    else{
                        $$.s += $3.s; 
                        $$.s += "=" + $1.s + "," + $3.tmp_num;
                    }
                }
                | if_state		{$$.s = $1.s;}
                | while_state		{$$.s = $1.s;}
                | dowhile_state		{$$.s = $1.s;}
                | read_state		{$$.s += $1.s;}
                | write_state		{$$.s += $1.s;}
                | CONTINUE 		{
                    if(!conts.empty()){
                        $$.s += ":=" + conts.top() + "\n";
                    }
                    else{
                        std::cerr << "error at: " << @$ << " "; 
                        semanticErr(err_code::badCont);
                    }                    
                }
		| RETURN expression	{$$.s += $2.s + "ret" + $2.tmp_num;}
		;

if_state:       IF bool_expr THEN statement_loop else_loop ENDIF		
                {
                    std::string l1 = makeLabel();
                    std::string l2 = makeLabel();
                    std::string l3 = makeLabel();
                    $$.s += $2.s;
                    $$.s += "?:=" + l1 + "," + $2.tmp_num + "\n"; //If true, goto l1
                    $$.s += ":=" + l2 + "\n"; //goto label 2
                    $$.s += ":" + l1 + "\n"; // l1
                    $$.s += $4.s;
                    $$.s += ":=" + l3 + "\n"; //goto l3
                    $$.s += ":" + l2 + "\n"; // l2
                    $$.s += $5.s;
                    $$.s += ":" + l3; // l3
                }
		; 

while_state:    WHILE bool_expr BEGINLOOP statement_loop ENDLOOP		
                {
                    $$.s += $2.s;
                    std::string l1 = makeLabel();
                    std::string l2 = makeLabel();
                    conts.push(l1);
                    $$.s += "?:=" + l1 + "," + $2.tmp_num + "\n"; //if true, goto l1
                    $$.s += ":=" + l2 + "\n"; // goto l
                    $$.s += ":" + l1;// + "\n";l1
                    $$.s += $4.s;
                    $$.s += $2.s; 
                    $$.s += "?:=" + l1 + "," + $2.tmp_num + "\n"; //if true, goto l1
                    $$.s += ":" + l2; // l2
                    conts.pop();
                }
		;

dowhile_state:	DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr 		
                   {
                    std::string l1 = makeLabel();
                    std::string l2 = makeLabel();
                    conts.push(l1);
                    $$.s += ":" + l1 + "\n"; //l1
                    $$.s += $3.s;
                    $$.s += $6.s; 
                    $$.s += "?:=" + l1 + "," + $6.tmp_num; //if true, goto l1
                    conts.pop();
                }       
		;

read_state:     READ varRead_loop		{$$.s += $2.s;}
		;

write_state:    WRITE varWrite_loop		{$$.s += $2.s;}
		;

varWrite_loop:  var 			{
                    if($1.t == expr_type::arr){
                        $$.s += writeVar($1.arr.at(0), $1.t) + "," + $1.arr.at(1);// + "\n";
                    }
                    else{
                        $$.s += writeVar($1.s, $1.t);// + "\n";
                    }
                }
		| var COMMA varWrite_loop	{ 
                    if($1.t == expr_type::arr){
                        $$.s += writeVar($1.arr.at(0), $1.t) + "," + $1.arr.at(1)/* + "\n"*/ + $3.s;
                    }
                    else{
                        $$.s += writeVar($1.s, $1.t)/* + "\n"*/ + $3.s;
                    }
                }
		;

varRead_loop:   var 	    {
                    if($1.t == expr_type::arr){
                        $$.s += readVar($1.arr.at(0), $1.t) + "," + $1.arr.at(1);// + "\n";
                    }
                    else{
                        $$.s += readVar($1.s, $1.t);// + "\n";
                    }
                }
		| var COMMA varRead_loop	{
                    if($1.t == expr_type::arr){
                    $$.s += readVar($1.arr.at(0), $1.t) + "," + $1.arr.at(1)/* + "\n"*/ + $3.s;
                    }
                    else{  
                        $$.s += readVar($1.s, $1.t)/* + "\n"*/ + $3.s;
                    }
                }
		;

else_loop:      /* empty */					{$$.s += "";}  
                | ELSE statement_loop				{$$.s += $2.s;}
		;

statement_loop: /*empty */ {$$.s += "";}		 
                | statement SEMICOLON statement_loop	{$$.s +=  ($1.s + "\n" + $3.s);}
		; 

bool_expr:      relation_and_expr 		{$$.s += $1.s; $$.tmp_num = $1.tmp_num;}
		| bool_expr OR relation_and_expr    {$$.s += $1.s + $3.s + "||" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		;

relation_and_expr:	relation_expr 		{$$.s += $1.s; $$.tmp_num = $1.tmp_num;}
			| relation_and_expr AND relation_expr	{$$.s += $1.s + $3.s + "&&" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
			;

relation_expr:  NOT relation_expr		{$$.s += $2.s + "!" + makeTemp() + "," + $2.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
                | expression comp expression	{
                    $$.s += $1.s + $3.s + readComp($2.t) + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; 
                    $$.tmp_num = temps.at(tempCnt-1);}
                | TRUE				{
                    $$.s += "==" + makeTemp() + ", " + std::to_string(1) + ", " + std::to_string(1) + "\n";
                    $$.tmp_num = temps.at(tempCnt-1);}
                | FALSE				{
                    $$.s += "==" + makeTemp() + ", " + std::to_string(0) + ", " + std::to_string(1) + "\n";
                    $$.tmp_num = temps.at(tempCnt-1);}
                | L_PAREN bool_expr R_PAREN	{$$.s += $2.s; $$.tmp_num = $2.tmp_num;}
		;

comp:	        EQ 		{$$.t = comp_type::eq;}
		| NEQ 		{$$.t = comp_type::neq;}
		| LT 		{$$.t = comp_type::lt;}
		| GT 		{$$.t = comp_type::gt;}
		| LTE 		{$$.t = comp_type::lte;}
		| GTE 		{$$.t = comp_type::gte;}
		;
	
para:        	expression		        {$$.s += $1.s + "param" + $1.tmp_num + "\n";}
                | expression COMMA para         {$$.s += $1.s + "param" + $1.tmp_num + "\n" + $3.s; } 
		;
		
ident_term:     id L_PAREN para R_PAREN 	{$$.s += $3.s + "call" + $1.s + "," + makeTemp() + "\n"; $$.tmp_num = temps.at(tempCnt -1);
                if(!searchFuncts($1.s)){
                    //std::cerr << "Error at " << @$ << " ";
                    //semanticErr(err_code::notDef);
                }
                }
		;
  
ident_var:      var 	{
                    if($1.t == expr_type::arr){
                        $$.s += $1.s + "=[]" + makeTemp() + "," + $1.arr.at(0) + "," + $1.arr.at(1) + "\n";
                        $$.tmp_num = temps.at(tempCnt-1);
                    }
                    else{
                        $$.s += "=" + makeTemp() + "," + $1.s + "\n"; $$.tmp_num = temps.at(tempCnt-1);
                    }
                }
		| NUMBER 			{$$.s += "=" + makeTemp() + ", " + std::to_string($1) + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		| L_PAREN expression R_PAREN	{$$.s += $2.s + "=" +  makeTemp() + "," + $2.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		;

term:           ident_var 			{
                    $$.s += $1.s; 
                    $$.tmp_num = $1.tmp_num;
                }
                | SUB ident_var			{$$.s += $2.s + "*" + makeTemp() + ", " + std::to_string(-1) + "," + $2.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		| ident_term			{$$.s += $1.s; $$.tmp_num = $1.tmp_num;}
		;	
	
multi_express:  term 						{$$.s += $1.s; $$.tmp_num = $1.tmp_num;}
		| multi_express MULT term			{$$.s += $1.s + $3.s + "*" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		| multi_express DIV term 			{$$.s += $1.s + $3.s + "/" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		| multi_express MOD term			{$$.s += $1.s + $3.s + "%" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);}
		;

expression:     multi_express 	    {
                    $$.s += $1.s;  $$.tmp_num = $1.tmp_num;
                }
		| expression ADD multi_express		{
                    $$.s += $1.s + $3.s + "+" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);
                
                }
		| expression SUB multi_express	    {
                    $$.s += $1.s + $3.s + "-" + makeTemp() + "," + $1.tmp_num + "," + $3.tmp_num + "\n"; $$.tmp_num = temps.at(tempCnt-1);
                 
                }
		;

var:            id 	    							{$$.s += $1.s;}
		| id L_SQUARE_BRACKET expression R_SQUARE_BRACKET		{$$.s += $3.s; $$.arr.push_back($1.s); $$.arr.push_back($3.tmp_num); 
                    $$.t = expr_type::arr;
                    if($3.s.compare("") == 0){
                        std::cerr << "Error at " << @$ << " ";
                        semanticErr(err_code::noIn);
                    }
                    
                }
		;

id:             IDENT 					{$$.s += " " + $1; }
		;


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
    std::string s = " __label__" + std::to_string(labelCnt);
    labelCnt++;
    labels.push_back(s); 
    return s;
}

std::string makeTemp(){
    std::string s = " __temp__" + std::to_string(tempCnt);
    tempCnt++;
    temps.push_back(s);
    return s;
}

std::string writeVar(std::string s, enum expr_type t){
    std::string str = ""; 
    if(t == expr_type::arr){
        str += ".[]>" + s;
    }
    else{
        str += ".>" + s;
    }
    return str;
}

std::string readVar(std::string s, enum expr_type t){
    std::string str = "";
    if(t == expr_type::arr){
        str += ".[]<" + s;
    }
    else{
        str += ".<" + s;
    }
    return str;
}

std::string assignParams(){
    std::string str = "";
    if(!parameters.empty()){
        for(unsigned i = 0; i < parameters.size(); i++){
            str += "\n=" + parameters.at(i).substr(1, parameters.at(i).size()) + ", $" + std::to_string(i) + "\n";
            //std::cout << parameters.at(i) << std::endl; 
        }
    }
    parameters.clear();
    return str;
}

std::string declareTemps(){
    std::string str = "";
    for(unsigned i = 0; i < temps.size(); i++){
        str += "." + temps.at(i) + "\n";
    }
    return str;
}

std::string declareLabels(){
    return "";
}

std::string readComp(enum comp_type t){
    std::string str = "";
    switch(t){
        case comp_type::eq:
            str += "==";
            break;
        case comp_type::neq:
            str += "!=";
            break;
        case comp_type::lt:
            str += "<";
            break;
        case comp_type::lte:
            str += "<=";
            break;
        case comp_type::gt:
            str += ">";
            break;
        case comp_type::gte:
            str += ">=";
            break;
        default:
            break;
    }
    return str;
}

void semanticErr(enum err_code ec){
    switch(ec){
        case err_code::unDec:
            std::cerr << "Variable not declared!" << std::endl;
            break;
        /*case err_code::notDef:
            std::cerr << "Function not defined!" << std::endl;
            break;*/
        case err_code::noMain:
            std::cerr << "Main function not defined." << std::endl;
            break;
        case err_code::reDef:
            std::cerr << "Variable is multiply defined!" << std::endl;
            break;
        case err_code::key:
            std::cerr << "Trying to declare variable with a reserved keyword." << std::endl;
            break;
        case err_code::noIn:
            std::cerr << "Arrays must be accessed with an index!" << std::endl;
            break;
        case err_code::badUse:
            std::cerr << "Bad use of variable name. Are you using an array using as an integer? (or vice-versa)" << std::endl;
            break;
        case err_code::out:
            std::cerr << "Arrays can not have negative size!" << std::endl;
            break;
        case err_code::badCont:
            std::cerr << "use of keyword \"CONTINUE\" can not be used outside of a loop!" << std::endl;
            break;
        default:
            break;

    }

}
