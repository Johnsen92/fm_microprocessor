all:
	flex parser.flex && yacc -dv parser.y && gcc -o parser lex.yy.c y.tab.c
clean:
	rm -f *.c && rm -f *.h && rm -f rm parser && rm -f *.output
