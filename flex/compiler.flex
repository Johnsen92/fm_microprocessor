%option noyywrap
identifier		[a-zA-Z\_][a-zA-Z0-9\_]*
dec				\&[0-9]+
hex				[0-9][0-9a-fA-F]+
keyword			(end|return|goto|if|then|var|not|and|";"|"("|")"|","|":"|"="|"*"|"-"|"+"|"=<"|"#")
whitespace		[\n\t ]
comment			"(*"([^*]|\*[^\)])*"*)"
%%
{comment}		;
{whitespace}+		;
{keyword}		{ printf("%s\n", yytext); }
{identifier}		{ printf("ident %s\n",yytext); }
{dec}			{ printf("num %ld\n", strtol(yytext+1,NULL,10));}
{hex}			{ printf("num %ld\n", strtol(yytext,NULL,16));}
.				printf("Error");exit(1);
%%

int main()
{
	yylex();
}
