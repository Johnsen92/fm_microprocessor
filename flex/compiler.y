%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
 
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
		exit(2);
}
 
int yywrap()
{
        return 0;
} 
  
main()
{
        yyparse();
	fprintf(stdout, "Successful\n");
	return 0;
} 

%}

%token NUM EQUALSMALLER

%union
{
	char*string;
}

%token <string> ID

%start Program

%%

Program:
		| Program Funcdef ';' 
		;

Funcdef: ID '(' Parameters ')' Stats 'end'
		;

Parameters:
		| 	ID
		| 	ID ',' Parameters
		;
	
Stats:
		| Stats Labeldef Stat ';'
		;
		
Stat: 	'return' Expression
		| 'goto' ID
		| 'if' Expression 'then' Stats 'end'
		| 'var' ID '=' Expression
		| LeftExpression '=' Expression
		| Term;

Labeldef: 
		| Labeldef ID ':'
		;
		
LeftExpression: ID
		| '*' Unary
		;
	
Expression: Unary
		| Term '+' Term PlusTermList
		| Term '*' Term MulTermList
		| Term 'and' Term AndTermList
		| Term EQUALSMALLER Term
		| Term '#' Term
		;

PlusTermList: 
		| PlusTermList '+' Term
		;
		
MulTermList:
		| MulTermList '*' Term
		;
		
AndTermList:
		| AndTermList 'and' Term
		;

Unary:	'-' Unary
		|'not' Unary
		| '*' Unary
		| Term
		;
		
Term:	'(' Expression ')'
		| NUM
		| ID
		| ID '(' ExpressionList ')'
		;
		
ExpressionList: 
		| Expression
		| Expression ',' ExpressionList
		;
		
