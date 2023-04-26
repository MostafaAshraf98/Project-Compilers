%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern int yylineno; /* Line Number tacker from lexer */
	extern int yylex(); 
	extern void yyerror(char *s);
%}

        /* Identifier and Numbers */
%token IDENTIFIER
%token NUMBER
%token FLOAT_NUM
%token TRUE_VAL
%token FALSE_VAL

        /* Constant */
%token CONST

        /* Mathematical Expressions */
%token PLUS
%token MINUS
%token MULT
%token DIV
%token PLUS_EQ
%token MINUS_EQ
%token MULT_EQ
%token DIV_EQ
%token INC
%token DEC
   
        /* Comparison Op */
%token LT
%token GT
%token GE
%token LE
%token EQ_EQ
%token NE

        /* Logical Expressions */
%token AND
%token OR
%token NOT

        /* Assignment Operator */
%token EQUAL

        /* Types */
%token INT  
%token FLOAT
%token CHAR
%token BOOL
%token STRING


        /* if then else statement */
%token IF
%token ELSEIF
%token ELSE

        /* While & do-while statement */
%token WHILE
%token DO
%token FOR
%token SWITCH
%token CASE
%token DEFAULT
%token BREAK
%token CONTINUE

        /* Functions */
%token VOID 
%token RETURN  
%token COMMA
%token COLON

        /* Enums */
%token ENUM

        /* Brackets */
%token OPENBRACKET
%token CLOSEDBRACKET
%token OPENCURL
%token CLOSEDCURL

        /* Stop Characters */
%token SEMICOLON

        /* Associativity */

// Non Associative
%nonassoc OR AND NOT

// Left Associative
%left PLUS MINUS PLUS_EQ MINUS_EQ INC DEC
%left MULT DIV MULT_EQ DIV_EQ
%left GE LE EQ_EQ NE GT LT

%start statements

%%

statements : 
    statements statement
    | statement
    ;

statement : 
	
	expression SEMICOLON 	{printf("Expression statement\n")}		
	| assignment_statement	{printf("Assignment Statement \n")}	
	| var_declaration 				
	| constant_declaration			
        | enum_statement                 
	| if_statement						
	| while_statement                   
	| do_while_statement                
	| for_statement                     
        | switch_statement 
        | break_statement 
        | continue_statement 
	| function							
	| function_call						
	| OPENCURL statements CLOSEDCURL
	| RETURN return_value SEMICOLON
        | SEMICOLON
	;

/* Values & Types*/

type:  INT | FLOAT | CHAR | STRING | BOOL;

constant: NUMBER | FLOAT_NUM | STRING;

/* Expression */

expression:
        boolean_expression
        | arithmetic_expression

/*  Boolean Expressions */

boolean_expression:
        expression EQ_EQ arithmetic_expression 
        | expression NE arithmetic_expression 
        | expression GE arithmetic_expression 
        | expression LE arithmetic_expression 
        | expression GT arithmetic_expression 
        | expression LT arithmetic_expression 
        | expression AND arithmetic_expression 
        | expression OR arithmetic_expression 
        | NOT expression
        | TRUE_VAL 
        | FALSE_VAL 
        
/*  Mathematical Expressions */

arithmetic_expression:
        binary_expression 
        | unary_expression
        ;

unary_expression:
        IDENTIFIER INC 
        | IDENTIFIER DEC 
        ;

binary_expression:
        binary_expression PLUS term 
        | binary_expression MINUS term 
        | term
        ;

term:
        factor 
        | term MULT factor 
        | term DIV factor
        ;

factor: 
        NUMBER
        | FLOAT_NUM
        | IDENTIFIER 
        | OPENBRACKET expression CLOSEDBRACKET
        ;
                

/* Variable Declaration */

assignment_statement: 	
        type IDENTIFIER EQUAL expression SEMICOLON
        | IDENTIFIER EQUAL expression SEMICOLON 
        | IDENTIFIER PLUS_EQ expression 
	| IDENTIFIER MINUS_EQ expression 
	| IDENTIFIER MULT_EQ expression 
	| IDENTIFIER DIV_EQ expression
        ;

var_declaration:        type IDENTIFIER SEMICOLON {printf("Variable declaration\n");};

constant_declaration: 	CONST type IDENTIFIER EQUAL expression SEMICOLON  {printf("Constant declaration\n");};

/* If statement */

if_statement: 
		IF OPENBRACKET expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL else_if_statement  {printf("If then statement\n");}
		| IF OPENBRACKET expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL else_if_statement ELSE OPENCURL statements CLOSEDCURL {printf("If then else statement\n");}
	;

else_if_statement:
    else_if_statement ELSEIF OPENBRACKET expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL | 
    ;

/* While statement */

while_statement:
		WHILE OPENBRACKET expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL   {printf("while statement\n");}
		;

/* Do while statement */

do_while_statement:
	DO OPENCURL statements CLOSEDCURL WHILE OPENBRACKET expression CLOSEDBRACKET  {printf("do-while statement\n");}
	;

/* For statement */

for_statement:
	FOR OPENBRACKET for_initialization expression SEMICOLON for_expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL {printf("for loop\n");}
        | FOR OPENBRACKET for_initialization SEMICOLON for_expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL {printf("for loop\n");}
	;

for_initialization:
        assignment_statement
	| var_declaration 				
	| constant_declaration
        | expression SEMICOLON
        | SEMICOLON
        ;

for_expression:
        IDENTIFIER EQUAL expression SEMICOLON 
        | IDENTIFIER PLUS_EQ expression 
	| IDENTIFIER MINUS_EQ expression 
	| IDENTIFIER MULT_EQ expression 
	| IDENTIFIER DIV_EQ expression
        | expression
        |
        ;

/* Switch statement */

switch_statement:
    SWITCH OPENBRACKET expression CLOSEDBRACKET OPENCURL case_list CLOSEDCURL {printf("switch statement\n");}
    ;

case_list:
    case_list case_statement 
    | case_statement
    ;

case_statement:
    CASE expression COLON statements 
    | DEFAULT COLON statements
    ;

/* Break or Continue */

break_statement: BREAK SEMICOLON {printf("Break statement\n")};
continue_statement: CONTINUE SEMICOLON {printf("Continue statement\n")};

/* Enums */

enum_statement: 		enum_declaration | enum_initialization {printf("Enum statement\n")};
enum_initialization: 	        ENUM IDENTIFIER IDENTIFIER EQUAL expression SEMICOLON {printf("Enum initialization\n")};
enum_declaration: 	        ENUM IDENTIFIER OPENCURL enum_list CLOSEDCURL SEMICOLON | ENUM IDENTIFIER SEMICOLON | CONST ENUM IDENTIFIER SEMICOLON {printf("Enum declaration\n")};
enum_list:                      enum_val | ;
enum_val:                       enum_val COMMA IDENTIFIER | IDENTIFIER EQUAL NUMBER |IDENTIFIER ;

/* Function Declaration */

function: 			function_prototype statement {printf("Function Definition\n");};
						
return_value: 			expression | ;

function_prototype:		
    type IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET 
    | type IDENTIFIER OPENBRACKET CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET CLOSEDBRACKET
    ;

parameters: 			parameters COMMA single_parameter | single_parameter ;

single_parameter: 		type IDENTIFIER | type IDENTIFIER EQUAL constant ;

function_call: 			IDENTIFIER OPENBRACKET call_parameters CLOSEDBRACKET SEMICOLON ;

call_parameters:		call_parameter |;

call_parameter:			call_parameter COMMA expression | expression ;

%%

int main (void)
{
    yyin = fopen("test.txt", "r+");
    if (yyin == NULL)
    {
        printf("File Not Found\n");
    }
    else
    {
        printf("====== Test File =====\n\n");
        FILE* testFile; char ch;
        testFile = fopen("test.txt","r");
        while((ch=fgetc(testFile))!=EOF)
        {
            printf("%c",ch);
        }
        printf("\n\n ====== Parsing =====\n\n");
        yyparse();
    }
    fclose(yyin);
    return 0;
}