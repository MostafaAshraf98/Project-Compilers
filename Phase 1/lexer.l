%{
#include<stdio.h>
#include "parser.tab.h"
int yylineno = 0;
void yyerror (char *s);
int yylex();
%}

%%

        /* Constant */
"const"                         return CONST;

        /* Mathematical Expressions */
"+"                             return PLUS;
"-"                             return MINUS;
"*"                             return MULT;
"/"                             return DIV;
"+="                            return PLUS_EQ;
"-="                            return MINUS_EQ;
"*="                            return MULT_EQ;
"/="                            return DIV_EQ;
"++"                            return INC;
"--"                            return DEC;
   
        /* Comparison Op */
"<"				return LT;
">"				return GT;
">="                            return GE;
"<="                            return LE;
"=="                            return EQ_EQ;
"!="                            return NE;

        /* Logical Expressions */
"&&"                            return AND;
"||"                            return OR;
"!"                             return NOT;

        /* Assignment Operator */
"="				return EQUAL;

        /* Types */
"int"                           return INT;  
"float"                         return FLOAT;
"char"                          return CHAR;
"bool"                          return BOOL;
"string"                        return STRING;


        /* if then else statement */
"if"                            return IF;
"else if"                       return ELSEIF;
"else"                          return ELSE;

        /* While & do-while statement */
"while"                         return WHILE;
"do"                            return DO;
"for"                           return FOR;
"switch"                        return SWITCH;
"case"                          return CASE;
"default"                       return DEFAULT;
"break"                         return BREAK;
"continue"                      return CONTINUE;

        /* Functions */
"void"                          return VOID; 
"return"                        return RETURN;  
","                             return COMMA;
":"                             return COLON;

        /* Enums */
"enum"                          return ENUM;

        /* Brackets */
"("                             return OPENBRACKET;
")"                             return CLOSEDBRACKET;
"{"                             return OPENCURL;
"}"                             return CLOSEDCURL;

        /* Stop Characters */
"\n"                            {yylineno += 1;}
[\t\r ]+                        {;}
";"                             return SEMICOLON;

        /* Identifier and Numbers */
"true"                          return TRUE_VAL;
"false"                         return FALSE_VAL;
[a-zA-Z_][a-zA-Z0-9_]*          return IDENTIFIER;
[0-9]+                          return NUMBER;
[0-9]+\.[0-9]+                  return FLOAT_NUM;
\"[^\"]*\"                      return STRING_VAL;

%%


int yywrap(void)
{
   return 0;
}

/* This is called by our parser whenever there is a syntactical error. In other words something that does not suit the grammar. */
void yyerror (char *s) {
    fprintf(stderr, "\n ERROR LINE %d :\n %s \n", yylineno, s);
    exit(0);
} 