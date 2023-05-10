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
    FUNCTION_TYPE
};

struct Lexeme{
        VariableType type;
        int intVal;
        float floatVal;
        char* stringVal;
        bool boolVal;
        char charVal;
        // vector<VariableType> functionInputs;
        // VariableType functionOutput;
};

class SymbolTableEntry{
    public:
        Lexeme* lexeme;
        bool isConst;
        bool isInit;
};

class SymbolTable
{
public:
    unordered_map<char*, SymbolTableEntry*> entries;
    SymbolTable* parent = NULL;
    vector<SymbolTable *> children;
};

#endif // CLASSES_H