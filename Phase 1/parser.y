%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern int yylineno; /* Line Number tacker from lexer */
	extern int yylex(); 
	extern void yyerror(char *s);
%}

        /* Identifier and Numbers */
%token IDENTIFIER
%token NUMBER
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

%start program

%%

program: statements;

statements : 
    statements statement
    | statement
    ;

statement : 
	
	expression SEMICOLON 			
	| assignment_statement			
	| var_declaration 				
	| constant_declaration			
    | enum_declaration                 
    | enum_initialization              
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
	;

/* Values & Types*/

value: IDENTIFIER | NUMBER | TRUE_VAL | FALSE_VAL ;

type:  INT | FLOAT | CHAR | STRING | BOOL;

/* Variable Declaration */

assignment_statement: 	type IDENTIFIER EQUAL value SEMICOLON | IDENTIFIER EQUAL value SEMICOLON {printf ("Assignment statement\n");};

var_declaration:        type IDENTIFIER SEMICOLON {printf("Variable declaration\n");};

constant_declaration: 	CONST type IDENTIFIER EQUAL value SEMICOLON  {printf("Constant declaration\n");};

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
		WHILE OPENBRACKET expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL   {printf("while statment\n");}
		| WHILE
		;

/* Do while statement */

do_while_statement:
	DO OPENCURL statements CLOSEDCURL WHILE OPENBRACKET expression CLOSEDBRACKET  {printf("do-while statment\n");}
	;

/* For statement */

for_statement:
	FOR OPENBRACKET assignment_statement expression SEMICOLON expression SEMICOLON CLOSEDBRACKET OPENCURL statements CLOSEDCURL {printf("for loop\n");}
	;

/* Switch statement */

switch_statement:
    SWITCH OPENBRACKET IDENTIFIER CLOSEDBRACKET OPENCURL case_list CLOSEDCURL {printf("switch statement\n");}
    ;

case_list:
    case_list case_statement 
    | case_statement
    ;

case_statement:
    CASE value COLON statements 
    | DEFAULT COLON statements
    ;

/* Break or Continue */
break_statement: BREAK SEMICOLON;
continue_statement: CONTINUE SEMICOLON;

/* Enums */

enum_initialization: 	ENUM IDENTIFIER IDENTIFIER EQUAL value SEMICOLON {printf("Enum initialization\n")};
enum_declaration: 	    ENUM IDENTIFIER OPENCURL enum_list CLOSEDCURL SEMICOLON | ENUM IDENTIFIER SEMICOLON | CONST ENUM IDENTIFIER SEMICOLON {printf("Enum declaration\n")};
enum_list:              enum_val | ;
enum_val:               enum_val COMMA IDENTIFIER | IDENTIFIER EQUAL NUMBER |IDENTIFIER ;

//  Mathematical Expressions

expression:
	expression PLUS expression |
	expression MINUS expression |
	expression MULT expression |
	expression DIV expression |

	expression PLUS_EQ expression |
	expression MINUS_EQ expression |
	expression MULT_EQ expression |
	expression DIV_EQ expression |
	expression EQ_EQ expression |

	expression GE expression |
	expression LE expression |
	
	expression NE expression |
	expression GT expression |
	expression LT expression |


	expression INC |
	INC expression |
	expression DEC |
	DEC expression |

	expression EQUAL expression |
	expression AND expression |
	expression OR expression |
	NOT expression |
    value 
	;

/* Function Declaration */

function: 				function_prototype statements {printf("Function Definition\n");};
						
return_value: 			value | ;

function_prototype:		
    type IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET 
    | type IDENTIFIER OPENBRACKET CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET CLOSEDBRACKET
    ;

parameters: 			parameters COMMA single_parameter | single_parameter ;

single_parameter: 		type IDENTIFIER | type IDENTIFIER EQUAL constant ;

constant: 				NUMBER | STRING;

function_call: 			IDENTIFIER OPENBRACKET call_parameters CLOSEDBRACKET SEMICOLON ;

call_parameters:		call_parameter |;

call_parameter:			call_parameter COMMA value | value ;

%%

int main (void)
{
    FILE * yyin = fopen("test.txt", "r+");
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
        printf("\n\n ====== Parsing ===== ");
        yyparse();
    }
    fclose(yyin);
    return 0;
}