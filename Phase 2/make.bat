flex lexer.l
bison -d -v parser.y
g++ -o program.exe lex.yy.c parser.tab.c
program.exe
pause