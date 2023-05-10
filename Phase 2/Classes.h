#ifndef CLASSES_H
#define CLASSES_H

#include<unordered_map>
#include <iostream>
using namespace std;

static enum variableType{
    INT,
    FLOAT,
    STRING,
    BOOL,
    CHAR,
    VOID,
    FUNCTION
};

class Lexeme{
    public:
        variableType type;
        int intVal;
        float floatVal;
        string stringVal;
        bool boolVal;
        char charVal;
        vector<variableType> functionInputs;
        variableType functionOutput;
};

class SymbolTableEntry{
    Lexeme lexeme;
    bool isConst;
    bool isInit;
};

class SymbolTable
{
public:
    unordered_map<string, SymbolTableEntry*> entries;
    SymbolTable* parent = NULL;
    vector<SymbolTable *> children;
};

#endif // CLASSES_H