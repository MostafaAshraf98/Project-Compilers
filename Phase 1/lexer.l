%{
#include<stdio.h>
#include "parser.tab.h"
int yylineno = 1;
%}

%%
        /* Identifier and Numbers */
[a-zA-Z_][a-zA-Z0-9_]*          return IDENTIFIER;
[0-9]+                          return NUMBER;

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
"<"				                return LT;
">"				                return GT;
">="                            return GE;
"<="                            return LE;
"=="                            return EQ_EQ;
"!="                            return NE;

        /* Logical Expressions */
"&&"                            return AND;
"||"                            return OR;
"!"                             return NOT;

        /* Assignment Operator */
"="				                return EQUAL;

        /* Types */
"int"                           return INT;  
"float"                         return FLOAT;
"char"                          return CHAR;
"bool"                          return BOOL;
"string"                        return STRING;


        /* if then else statement */
"if"                            return IF;
"then"                          return THEN;
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
[\t\r ]+                         {;}
";"                             return SEMICOLON;

%%


int yywrap(void)
{
   return 0;
}