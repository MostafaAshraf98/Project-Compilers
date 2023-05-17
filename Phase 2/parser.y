%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
        #include "SemanticAnalyzer.cpp"
	extern FILE *yyin;
	extern int yylineno; /* Line Number tacker from lexer */
	extern int yylex(); 
	extern void yyerror(string s);
%}

        /* Union */
%union {
        int varType;
        struct Lexeme{
                int type;
                char *stringRep;
                int intVal;
                float floatVal;
                char* stringVal;
                bool boolVal;
                char charVal;
        }lexeme;

        char* stringValue;
};

        /* Rules types */
%type<varType> type
%type<lexeme> value
%type<lexeme> constant
%type<lexeme> expression
%type<lexeme> boolean_expression
%type<lexeme> arithmetic_expression
%type<lexeme> unary_expression
%type<lexeme> binary_expression
%type<lexeme> term
%type<lexeme> factor
/* %type<lexeme> return_value */
%type<lexeme> function_call 



        /* Identifier and Values */
%token IDENTIFIER
%token INT_VAL
%token FLOAT_VAL
%token CHAR_VAL
%token STRING_VAL
%token TRUE_VAL
%token FALSE_VAL
%type<stringValue> IDENTIFIER
%type<lexeme> INT_VAL
%type<lexeme> FLOAT_VAL
%type<lexeme> CHAR_VAL
%type<lexeme> STRING_VAL
%type<lexeme> TRUE_VAL
%type<lexeme> FALSE_VAL

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
%type<varType> INT  
%type<varType> FLOAT
%type<varType> CHAR
%type<varType> BOOL
%type<varType> STRING


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
	
	expression SEMICOLON 
	| assignment_statement
	| var_declaration 
	| constant_declaration			
        | enum_statement                 
	| if_statement						
	| while_statement                   
	| do_while_statement                
	| for_statement                     
        | switch_statement
	| function							
	| OPENCURL {createNewTable();} statements CLOSEDCURL {exitCurrentScope();}
	| RETURN return_value SEMICOLON
        | SEMICOLON
	;

/* Values & Types*/

value: expression | STRING_VAL;

type:  INT | FLOAT | CHAR | STRING | BOOL;

constant: INT_VAL | FLOAT_VAL | STRING_VAL | TRUE_VAL | FALSE_VAL;

/* Expression */

expression:
        boolean_expression
        | arithmetic_expression
        ;

/*  Boolean Expressions */

boolean_expression:
        expression EQ_EQ arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkEQ_EQ(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" == "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        }
        | expression NE arithmetic_expression 
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkNE(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" != "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        }
        | expression GE arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkGE(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" >= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | expression LE arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkNE(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" <= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | expression GT arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkGT(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" > "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        }
        | expression LT arithmetic_expression 
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in boolean expression at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        LexemeEntry* lex1 = convertLexemeToEntry($1.type, $1.stringRep, $1.intVal, $1.floatVal, $1.stringVal, $1.boolVal, $1.charVal);
                        LexemeEntry* lex2 = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        $$.boolVal = checkLT(lex1,lex2);
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" < "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        }
        | expression AND arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(type1 != BOOL_TYPE || type2 != BOOL_TYPE)
                {
                        printSemanticError("AND Operation should be between boolean types at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        $$.boolVal = $1.boolVal && $3.boolVal;
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" AND "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | expression OR arithmetic_expression
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if(type1 != BOOL_TYPE || type2 != BOOL_TYPE)
                {
                        printSemanticError("OR Operation should be between boolean types at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        $$.boolVal = $1.boolVal || $3.boolVal;
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" AND "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | NOT expression
        {
                int type = $2.type;
                if(type != BOOL_TYPE)
                {
                        printSemanticError("NOT Operation should be on boolean type at line number ",yylineno);
                }else{
                        $$.type = BOOL_TYPE;
                        $$.stringRep = getCurrentCount();
                        $$.boolVal = !$2.boolVal;
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,strdup(" NOT "));
                        temp = concatStrings(temp,$2.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | TRUE_VAL 
        | FALSE_VAL 
        ;
        
/*  Mathematical Expressions */

arithmetic_expression:
        binary_expression 
        | unary_expression
        ;

unary_expression:
        IDENTIFIER INC
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Variable not declared at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                VariableType type = entry->lexeme->type;
                if(type != INT_TYPE && type != FLOAT_TYPE)
                {
                        printSemanticError("Unary Operation should be on integer or float type at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type == INT_TYPE)
                        {
                                $$.type = INT_TYPE;
                                $$.intVal = entry->lexeme->intVal + 1;
                                entry->lexeme->intVal = $$.intVal;
                        }else
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = entry->lexeme->floatVal + 1;
                                entry->lexeme->floatVal = $$.floatVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,strdup(" INC "));
                        temp = concatStrings(temp,$1);
                        addIntermidiateRep(temp);
                }
        } 
        | IDENTIFIER DEC
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Variable not declared at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                VariableType type = entry->lexeme->type;
                if(type != INT_TYPE && type != FLOAT_TYPE)
                {
                        printSemanticError("Unary Operation should be on integer or float type at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type == INT_TYPE)
                        {
                                $$.type = INT_TYPE;
                                $$.intVal = entry->lexeme->intVal -1 ;
                                entry->lexeme->intVal = $$.intVal;
                        }else
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = entry->lexeme->floatVal - 1;
                                entry->lexeme->floatVal = $$.floatVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,strdup(" DEC "));
                        temp = concatStrings(temp,$1);
                        addIntermidiateRep(temp);
                }
        } 
        ;

binary_expression:
        binary_expression PLUS term
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Addition operation must be between 2 numbers at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type1 == FLOAT_TYPE || type2 == FLOAT_TYPE)
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = $1.floatVal + $3.floatVal;
                        }
                        else{
                                $$.type = INT_TYPE;
                                $$.intVal = $1.intVal + $3.intVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" ADD "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | binary_expression MINUS term 
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Subtraction operation must be between 2 numbers at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type1 == FLOAT_TYPE || type2 == FLOAT_TYPE)
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = $1.floatVal - $3.floatVal;
                        }
                        else{
                                $$.type = INT_TYPE;
                                $$.intVal = $1.intVal - $3.intVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" SUB "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | term
        ;

term:
        factor 
        | term MULT factor
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Multiplication operation must be between 2 numbers at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type1 == FLOAT_TYPE || type2 == FLOAT_TYPE)
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = $1.floatVal * $3.floatVal;
                        }
                        else{
                                $$.type = INT_TYPE;
                                $$.intVal = $1.intVal * $3.intVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" MUL "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        | term DIV factor
        {
                int type1 = $1.type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Division operation must be between 2 numbers at line number ",yylineno);
                }else{
                        $$.stringRep = getCurrentCount();
                        if(type1 == FLOAT_TYPE || type2 == FLOAT_TYPE)
                        {
                                $$.type = FLOAT_TYPE;
                                $$.floatVal = $1.floatVal / $3.floatVal;
                        }
                        else{
                                $$.type = INT_TYPE;
                                $$.intVal = $1.intVal / $3.intVal;
                        }
                        char* temp = concatStrings($$.stringRep,strdup(" := "));
                        temp = concatStrings(temp,$1.stringRep);
                        temp = concatStrings(temp,strdup(" DIV "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                }
        } 
        ;

factor: 
        INT_VAL
        | FLOAT_VAL
        | function_call
        | IDENTIFIER
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Variable not declared at line number ",yylineno);
                        return 0;
                }
                entry->isUsed = true;
                $$.type = (int)entry->lexeme->type;
                $$.stringRep = $1;
                $$.intVal = entry->lexeme->intVal;
                $$.floatVal = entry->lexeme->floatVal;
                $$.stringVal = entry->lexeme->stringVal;
                $$.boolVal = entry->lexeme->boolVal;
                $$.charVal = entry->lexeme->charVal;
        }  
        | OPENBRACKET expression CLOSEDBRACKET
        {
                $$ = $2;
        }
        ;
                

/* Variable Declaration */

assignment_statement: 	
        IDENTIFIER EQUAL expression SEMICOLON
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Undeclared Variable at line number ",yylineno);
                        return 0;
                }
                if(entry->kind != VAR)
                {
                        printSemanticError("Cannot assign value to a non variable type at line number ",yylineno);
                        return 0;
                }
                int type1 = (int) entry->lexeme->type;
                int type2 = $3.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in assignment statement at line number ",yylineno);
                }else{
                        char* temp = concatStrings($1,strdup(" := "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                        entry->isInit = true;
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                entry->lexeme->intVal = (int)$3.floatVal;
                                 
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->floatVal = (float)$3.intVal;
                        }else{
                                entry->lexeme = convertLexemeToEntry($3.type, $3.stringRep, $3.intVal, $3.floatVal, $3.stringVal, $3.boolVal, $3.charVal);
                        }
                }
        } 
        | IDENTIFIER PLUS_EQ expression SEMICOLON
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Undeclared Variable at line number ",yylineno);
                        return 0;
                }
                if(entry->kind != VAR)
                {
                        printSemanticError("Cannot assign value to a non variable type at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                int type1 = (int)entry->lexeme->type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Addition operation must be between 2 numbers at line number ",yylineno);
                }else{
                        char* temp = concatStrings($1,strdup(" :+= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal + (int)$3.floatVal ;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->floatVal = entry->lexeme->floatVal + (float)$3.intVal ;
                        }else if (type1 == INT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal + $3.intVal ;
                        }else{
                                entry->lexeme->floatVal = entry->lexeme->floatVal + $3.floatVal ;
                        }
                }
        } 
	| IDENTIFIER MINUS_EQ expression SEMICOLON
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Undeclared Variable at line number ",yylineno);
                        return 0;
                }
                if(entry->kind != VAR)
                {
                        printSemanticError("Cannot assign value to a non variable type at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                int type1 = (int)entry->lexeme->type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Subtraction operation must be between 2 numbers at line number ",yylineno);
                
                }else{
                        char* temp = concatStrings($1,strdup(" :-= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal - (int)$3.floatVal ;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->floatVal = entry->lexeme->floatVal - (float)$3.intVal ;
                        }else if (type1 == INT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal - $3.intVal ;
                        }else{
                                entry->lexeme->floatVal = entry->lexeme->floatVal - $3.floatVal ;
                        }
                }
        } 
	| IDENTIFIER MULT_EQ expression SEMICOLON
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Undeclared Variable at line number ",yylineno);
                        return 0;
                }
                if(entry->kind != VAR)
                {
                        printSemanticError("Cannot assign value to a non variable type at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                int type1 = (int)entry->lexeme->type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Multiplication operation must be between 2 numbers at line number ",yylineno);
                
                }else{
                        char* temp = concatStrings($1,strdup(" :*= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal * (int)$3.floatVal ;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->floatVal = entry->lexeme->floatVal * (float)$3.intVal ;
                        }else if (type1 == INT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal * $3.intVal ;
                        }else{
                                entry->lexeme->floatVal = entry->lexeme->floatVal * $3.floatVal ;
                        }
                }
        } 
	| IDENTIFIER DIV_EQ expression SEMICOLON
        {
                SymbolTableEntry* entry = getIdEntry($1);
                if(entry == NULL){
                        printSemanticError("Undeclared Variable at line number ",yylineno);
                        return 0;
                }
                if(entry->kind != VAR)
                {
                        printSemanticError("Cannot assign value to a non variable type at line number ",yylineno);
                        return 0;
                }
                if(entry->isInit == false)
                {
                        printSemanticError("Variable not initialized at line number ",yylineno);
                        return 0;
                }
                int type1 = (int) entry->lexeme->type;
                int type2 = $3.type;
                if((type1 != INT_TYPE && type1 != FLOAT_TYPE) || (type2 != INT_TYPE && type2 != FLOAT_TYPE))
                {
                        printSemanticError("Division operation must be between 2 numbers at line number ",yylineno);
                
                }else{
                        char* temp = concatStrings($1,strdup(" :/= "));
                        temp = concatStrings(temp,$3.stringRep);
                        addIntermidiateRep(temp);
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal / (int)$3.floatVal ;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->floatVal = entry->lexeme->floatVal / (float)$3.intVal ;
                        }else if (type1 == INT_TYPE && type2 == INT_TYPE)
                        {
                                entry->lexeme->intVal = entry->lexeme->intVal / $3.intVal ;
                        }else{
                                entry->lexeme->floatVal = entry->lexeme->floatVal / $3.floatVal ;
                        }
                }
        } 
        ;

var_declaration:        
         type IDENTIFIER EQUAL value SEMICOLON
         {
                SymbolTableEntry* entry = getIdEntry($2);
                if(entry != NULL){
                        printSemanticError("Variable already declared at line number ",yylineno);
                        return 0;
                }
                int type1 = $1;
                int type2 = $4.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in variable declaration at line number ",yylineno);
                }else{
                        LexemeEntry* lexeme = new LexemeEntry;
                        lexeme->type = static_cast<VariableType>(type1);
                        lexeme->stringRep = getCurrentCount();
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                lexeme->intVal = (int)$4.floatVal;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                lexeme->floatVal = (float)$4.intVal;
                        }else{
                                lexeme->intVal = $4.intVal;
                                lexeme->floatVal = $4.floatVal;
                                lexeme->stringVal = $4.stringVal;
                                lexeme->boolVal = $4.boolVal;
                                lexeme->charVal = $4.charVal;
                        }
                        char* temp = concatStrings($2,strdup(" := "));
                        temp = concatStrings(temp,$4.stringRep);
                        addIntermidiateRep(temp);
                        addEntryToTable($2,lexeme,VAR,true);
                }
         }
        | type IDENTIFIER SEMICOLON
         {
                SymbolTableEntry* entry = getIdEntry($2);
                if(entry != NULL){
                        printSemanticError("Variable already declared at line number ",yylineno);
                        return 0;
                }

                LexemeEntry* lexeme = new LexemeEntry;
                lexeme->type = static_cast<VariableType>($1);
                lexeme->stringRep = getCurrentCount();
                addEntryToTable($2,lexeme,VAR,false);
        
         }
        | ENUM IDENTIFIER IDENTIFIER SEMICOLON
         {
                SymbolTableEntry* pointerToEnum = getIdEntry($2);
                SymbolTableEntry* entry = getIdEntry($3);
                if(pointerToEnum == NULL){
                        printSemanticError("Enumerator not declared at line number ",yylineno);
                        return 0;
                }
                if(entry != NULL){
                        printSemanticError("Variable already declared at line number ",yylineno);
                        return 0;
                }

                LexemeEntry* lexeme = new LexemeEntry;
                lexeme->type = ENUM_TYPE;
                lexeme->stringRep = getCurrentCount();
                addEntryToTable($2,lexeme,VAR,false,pointerToEnum);
        
         }

constant_declaration: 	
        CONST type IDENTIFIER EQUAL value SEMICOLON  
        {
                SymbolTableEntry* entry = getIdEntry($3);
                if(entry != NULL){
                        printSemanticError("Variable already declared at line number ",yylineno);
                        return 0;
                }
                int type1 = $2;
                int type2 = $5.type;
                if(!isTypeMatching(type1,type2))
                {
                        printSemanticError("Type mismatch in variable declaration at line number ",yylineno);
                }else{
                        LexemeEntry* lexeme = new LexemeEntry;
                        lexeme->type = static_cast<VariableType>(type1);
                        lexeme->stringRep = getCurrentCount();
                        if(type1 == INT_TYPE && type2 == FLOAT_TYPE)
                        {
                                lexeme->intVal = (int)$5.floatVal;
                        }else if (type1 == FLOAT_TYPE && type2 == INT_TYPE)
                        {
                                lexeme->floatVal = (float)$5.intVal;
                        }else{
                                lexeme->intVal = $5.intVal;
                                lexeme->floatVal = $5.floatVal;
                                lexeme->stringVal = $5.stringVal;
                                lexeme->boolVal = $5.boolVal;
                                lexeme->charVal = $5.charVal;
                        }
                        char* temp = concatStrings($3,strdup(" := "));
                        temp = concatStrings(temp,$5.stringRep);
                        addIntermidiateRep(temp);
                        addEntryToTable($3,lexeme,CONSTANT,true);
                }        
        };

/* If statement */

if_statement: 
        IF OPENBRACKET value { checkIfLexemIsBool($3.type != BOOL_TYPE,yylineno);}  CLOSEDBRACKET OPENCURL {createNewTable();} statements CLOSEDCURL {exitCurrentScope();} else_if_statement else_statement 
	;

else_statement: 
        ELSE OPENCURL {createNewTable();} statements CLOSEDCURL {exitCurrentScope();}
        |
        ;
else_if_statement:
        else_if_statement ELSEIF OPENBRACKET  value { checkIfLexemIsBool($4.type != BOOL_TYPE,yylineno);} CLOSEDBRACKET OPENCURL {createNewTable();} statements CLOSEDCURL {exitCurrentScope();} 
        | 
        ;

/* While statement */

while_statement:
		WHILE  OPENBRACKET value { checkIfLexemIsBool($3.type != BOOL_TYPE,yylineno);} CLOSEDBRACKET statement  
		;

/* Do while statement */

do_while_statement:
	DO statement WHILE OPENBRACKET value { checkIfLexemIsBool($5.type != BOOL_TYPE,yylineno);} CLOSEDBRACKET SEMICOLON 
	;

/* For statement */

for_statement:
	FOR {createNewTable();} OPENBRACKET for_initialization value { checkIfLexemIsBool($5.type != BOOL_TYPE,yylineno);} SEMICOLON for_expression CLOSEDBRACKET OPENCURL statements CLOSEDCURL {exitCurrentScope();}
	;

for_initialization:
        assignment_statement
	| var_declaration 				
	| constant_declaration
        | value SEMICOLON
        | SEMICOLON
        ;

for_expression:
        IDENTIFIER EQUAL value SEMICOLON 
        | IDENTIFIER PLUS_EQ expression 
	| IDENTIFIER MINUS_EQ expression 
	| IDENTIFIER MULT_EQ expression 
	| IDENTIFIER DIV_EQ expression
        | value
        |
        ;

/* Switch statement */

switch_statement:
    SWITCH OPENBRACKET value CLOSEDBRACKET OPENCURL {createNewTable();}  case_list CLOSEDCURL {exitCurrentScope();}
    ;

case_list:
    case_list case_statement 
    | case_statement
    ;

case_statement:
    CASE value COLON statements 
    | DEFAULT COLON statements
    ;

/* Enums */

enum_statement: 		enum_declaration | enum_initialization
enum_initialization: 	        ENUM IDENTIFIER IDENTIFIER EQUAL IDENTIFIER SEMICOLON
enum_declaration: 	        ENUM IDENTIFIER OPENCURL enum_list CLOSEDCURL SEMICOLON | ENUM IDENTIFIER SEMICOLON | CONST ENUM IDENTIFIER SEMICOLON
enum_list:                      enum_val | ;
enum_val:                       enum_val COMMA IDENTIFIER | enum_val COMMA IDENTIFIER EQUAL INT_VAL |  IDENTIFIER EQUAL INT_VAL |IDENTIFIER ;

/* Function Declaration */

function: 			function_prototype statement
						
return_value: 			value | ;

function_prototype:		
    type IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET 
    | type IDENTIFIER OPENBRACKET CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET parameters CLOSEDBRACKET
    | VOID IDENTIFIER OPENBRACKET CLOSEDBRACKET
    ;

parameters: 			parameters COMMA single_parameter | single_parameter ;

single_parameter: 		type IDENTIFIER | type IDENTIFIER EQUAL constant ;

function_call: 			IDENTIFIER OPENBRACKET call_parameters CLOSEDBRACKET ;

call_parameters:		call_parameter |;

call_parameter:			call_parameter COMMA value | value ;

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
        fclose(testFile);
        printf("\n\n====== Parsing =====\n\n");
        int result = yyparse();

        printf("\n=================\n");

        if (result == 0) {
            printf("Parsing Successful\n");
        }
        else {
            printf("Parsing Failed\n");
        }
    }
    fclose(yyin);
    return 0;
}