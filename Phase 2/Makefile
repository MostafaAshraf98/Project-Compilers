.PHONY: all clean

all: program.exe

lexer.cpp: lexer.l
	flex++ -o lexer.cpp lexer.l

parser.cpp: parser.y
	bison --language=C++ -d -o parser.cpp parser.y

program.exe: lexer.cpp parser.cpp
	g++ -o program.exe lexer.cpp parser.cpp

clean:
	rm -f lexer.cpp parser.cpp parser.hpp parser.output program.exe lex.yy.cc lex.yy.cpp parser.tab.cpp parser.tab.hpp stack.hh

run: program.exe
	./program.exe