#ifndef CLASSES_H
#define CLASSES_H

#include<unordered_map>
#include <iostream>
#include <vector>
using namespace std;

enum VariableType{
    INT_TYPE,
    FLOAT_TYPE,
    STRING_TYPE,
    BOOL_TYPE,
    CHAR_TYPE,
    VOID_TYPE,
};

enum Kind{
    CONSTANT,
    VAR,
    FUNC,
    PARAM,
};

struct Lexeme{
        VariableType type;
        char *stringRep;
        int intVal;
        float floatVal;
        char* stringVal;
        bool boolVal;
        char charVal;
};

class SymbolTableEntry{
    public:
        Lexeme* lexeme;
        Kind kind;
        bool isInit = false;
        bool isUsed = false;
        vector<VariableType> functionInputs;
        VariableType functionOutput;
};

class SymbolTable
{
public:
    unordered_map<char*, SymbolTableEntry*> entries;
    SymbolTable* parent = NULL;
    vector<SymbolTable *> children;
};

#endif // CLASSES_H