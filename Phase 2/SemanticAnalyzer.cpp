#ifndef SEMANTICANALYZER_H
#define SEMANTICANALYZER_H

#include "Classes.hpp"
#include <string>
#include <cstring>
using namespace std;

SymbolTable *currentSymbolTable = new SymbolTable();
FILE *semanticFile = fopen("semantic.txt", "w");
FILE *quadrupleFile = fopen("quadruple.txt", "w");

int currentCount = 0;

void createNewTable()
{
    SymbolTable *newSymbolTable = new SymbolTable();
    newSymbolTable->parent = currentSymbolTable;
    currentSymbolTable->children.push_back(newSymbolTable);
    currentSymbolTable = newSymbolTable;
}

bool addEntryToTable(char *identifier, LexemeEntry *lexeme, Kind kind, bool isInit, SymbolTableEntry *pointerToEnum = NULL, VariableType functionOutput = VOID_TYPE)
{
    SymbolTableEntry *entry = new SymbolTableEntry();
    entry->lexeme = lexeme;
    entry->kind = kind;
    entry->isInit = isInit;
    entry->pointerToEnum = pointerToEnum;
    entry->functionOutput = functionOutput;

    (currentSymbolTable->entries)[identifier] = entry;
    return true;
}

bool idExistsInEnum(SymbolTableEntry* pointerToEnum, char* identifier)
{
    for(int i=0;i<pointerToEnum->enumValues.size();i++)
    {
        if(strcmp(pointerToEnum->enumValues[i],identifier)==0)
        {
            return true;
        }
    }
    return false;
}

SymbolTableEntry *getIdEntry(char *identifier)
{
    unordered_map<char *, SymbolTableEntry *> map = currentSymbolTable->entries;
    SymbolTable *temp = currentSymbolTable;
    while (currentSymbolTable != NULL)
    {
        auto entry = map.find(identifier);
        if (entry == map.end())
        {
            currentSymbolTable = currentSymbolTable->parent;
            continue;
        }
        else
        {
            return entry->second;
        }
    }
    return NULL;
}

void exitCurrentScope()
{
    currentSymbolTable = currentSymbolTable->parent;
}

VariableType checkIdType(char *identifier)
{
    SymbolTableEntry *entry = getIdEntry(identifier);
    if (entry == NULL)
        return VOID_TYPE;
    return entry->lexeme->type;
}

bool isTypeMatching(int type1, int type2)
{
    if (type1 == type2 || (type1 == INT_TYPE && type2 == FLOAT_TYPE) || (type1 == FLOAT_TYPE && type2 == INT_TYPE))
        return true;
    return false;
}

void printSemanticError(string error, int lineNo)
{
    fprintf(semanticFile, "%s At Line Number %d\n", error.c_str(), lineNo);
    exit(0);
}

void addIntermidiateRep(string quad)
{
    // operator first_operand second_operand result
    // operator first_operand result
    fprintf(quadrupleFile, "%s\n", quad.c_str());
}

char *getCurrentCount()
{
    char *strCount = (char *)malloc(sizeof(char) * 10);                               // allocate space for the count string
    snprintf(strCount, 10, "%d", currentCount);                                       // convert the count to a string
    char *temp = (char *)malloc(sizeof(char) * (strlen("t") + strlen(strCount) + 1)); // allocate space for the concatenated string
    strcpy(temp, "t");                                                                // copy the "t" character to the stringRep
    strcat(temp, strCount);
    return temp;
}

char *concatStrings(char *str1, char *str2)
{
    char *temp = (char *)malloc(sizeof(char) * (strlen(str1) + strlen(str2) + 1)); // allocate space for the concatenated string
    strcpy(temp, str1);                                                            // copy the "t" character to the stringRep
    strcat(temp, str2);
    return temp;
}

LexemeEntry *convertLexemeToEntry(int type, char *stringRep, int intVal, float floatVal, char *stringVal, bool boolVal, char charVal)
{
    LexemeEntry *lexeme = new LexemeEntry();
    lexeme->type = static_cast<VariableType>(type);
    lexeme->stringRep = stringRep;
    lexeme->intVal = intVal;
    lexeme->floatVal = floatVal;
    lexeme->stringVal = stringVal;
    lexeme->boolVal = boolVal;
    lexeme->charVal = charVal;
    return lexeme;
}

void checkIfLexemIsBool(bool isBool, int lineNo)
{
    if (isBool)
        printSemanticError("Expected a boolean value", lineNo);
}

bool checkEQ_EQ(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal == lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal == lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal == lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal == lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) == 0;
    }
    else
    {
        return false;
    }
}

bool checkNE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal != lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal != lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal != lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal != lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) != 0;
    }
    else
    {
        return false;
    }
}

bool checkGE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal >= lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal >= lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal >= lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal >= lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) >= 0;
    }
    else
    {
        return false;
    }
}

bool checkLE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal <= lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal <= lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal <= lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal <= lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) <= 0;
    }
    else
    {
        return false;
    }
}

bool checkGT(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal > lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal > lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal > lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal > lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) > 0;
    }
    else
    {
        return false;
    }
}

bool checkLT(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE)
    {
        return lex1->intVal < lex2->intVal;
    }
    else if (lex1->type == FLOAT_TYPE)
    {
        return lex1->floatVal < lex2->floatVal;
    }
    else if (lex1->type == BOOL_TYPE)
    {
        return lex1->boolVal < lex2->boolVal;
    }
    else if (lex1->type == CHAR_TYPE)
    {
        return lex1->charVal < lex2->charVal;
    }
    else if (lex1->type == STRING_TYPE)
    {
        return strcmp(lex1->stringVal, lex2->stringVal) < 0;
    }
    else
    {
        return false;
    }
}

#endif