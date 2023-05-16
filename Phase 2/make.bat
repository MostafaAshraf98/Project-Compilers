flex++ lexer.l 
bison --language=C++ -d -v parser.y -o parser.cpp
g++ -o program.exe lex.yy.cc parser.cpp
program.exe
pause