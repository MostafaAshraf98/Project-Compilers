.PHONY: all clean

all: clean program.exe

lexer.cpp: lexer.l
	flex -o lexer.c lexer.l

parser.cpp: parser.y
	bison -d -o parser.c parser.y

program.exe: lexer.cpp parser.cpp
	g++ -m64 -g -static -o program.exe lexer.c parser.c

clean:
	rm -f lexer.c parser.c parser.h program.exe semantic-error.txt syntax-error.txt quadruple.txt symbol-tables.txt

run: clean program.exe
	./program.exe