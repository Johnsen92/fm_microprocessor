%option noyywrap
%{
#include <stdio.h>
#include "y.tab.h"
%}
identifier		[a-zA-Z\_][a-zA-Z0-9\_]*
dec				\&[0-9]+
hex				[0-9][0-9a-fA-F]*
keyword			(end|return|goto|if|then|var|not|and|";"|"("|")"|","|":"|"="|"*"|"-"|"+"|"#")
whitespace		[\n\t \r]
comment			"(*"([^*]|\*[^\)])*"*)"
%%
{comment}		;
{whitespace}+	;
"=<"			return EQUALSMALLER;
{keyword}		return (int) yytext[0];
{identifier}	yylval.string=strdup(yytext); return ID;
{dec}			return NUM;
{hex}			return NUM;
.				fprintf(stderr, "Lexical Error\n");exit(1);
%%
