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
    ENUM_TYPE
};

enum Kind{
    CONSTANT,
    VAR,
    FUNC,
    PARAM
};

struct LexemeEntry{
        VariableType type;
        char *stringRep;
        int intVal;
        float floatVal;
        char* stringVal;
        bool boolVal;
        char charVal;
        unordered_map<char*, int> enumValues;
};

class SymbolTableEntry{
    public:
        LexemeEntry* lexeme;
        Kind kind;
        bool isInit = false;
        bool isUsed = false;
        vector<VariableType> functionInputs;
        VariableType functionOutput;
        SymbolTableEntry* pointerToEnum = NULL;
};

class SymbolTable
{
    public:
        unordered_map<char*, SymbolTableEntry*> entries;
        SymbolTable* parent = NULL;
        vector<SymbolTable *> children;
};

#endif // CLASSES_H