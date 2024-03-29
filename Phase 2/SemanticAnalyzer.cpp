#ifndef SEMANTICANALYZER_H
#define SEMANTICANALYZER_H

#include "Classes.hpp"
#include <string>
#include <cstring>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <stack>
using namespace std;

SymbolTable *currentSymbolTable;
SymbolTable *rootSymbolTable;
SymbolTableEntry *currentFunction = NULL;
SymbolTableEntry *currentEnum = NULL;
stack<VariableType> functionParameters;

FILE *semanticFile = fopen("semantic-error.txt", "w");
FILE *quadrupleFile = fopen("quadruple.txt", "w");
FILE *syntaxFile = fopen("syntax-error.txt", "w");
ofstream symbolTablesFile("symbol-tables.txt");

int currentCount = 0;

void Init()
{
    currentSymbolTable = new SymbolTable();
    unordered_map<string, SymbolTableEntry *> map;
    vector<SymbolTable *> children;
    currentSymbolTable->children = children;
    currentSymbolTable->entries = map;
    rootSymbolTable = currentSymbolTable;
}

void createNewTable()
{
    SymbolTable *newSymbolTable = new SymbolTable();

    unordered_map<string, SymbolTableEntry *> map;
    vector<SymbolTable *> children;
    newSymbolTable->children = children;
    newSymbolTable->entries = map;

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
    entry->functionInput = vector<VariableType>();
    entry->enumValues = vector<char *>();
    string id(identifier);
    if (kind == FUNC)
        currentFunction = entry;
    if (kind == ENUMERATOR)
        currentEnum = entry;

    (currentSymbolTable->entries)[id] = entry;
    return true;
}

bool idExistsInEnum(SymbolTableEntry *pointerToEnum, char *identifier)
{
    for (int i = 0; i < pointerToEnum->enumValues.size(); i++)
    {
        if (strcmp(pointerToEnum->enumValues[i], identifier) == 0)
        {
            return true;
        }
    }
    return false;
}

SymbolTableEntry *getIdEntry(char *identifier)
{
    string id(identifier);
    unordered_map<string, SymbolTableEntry *> map;
    SymbolTable *temp = currentSymbolTable;
    while (currentSymbolTable != NULL)
    {
        map = currentSymbolTable->entries;
        auto entry = map.find(id);
        if (entry == map.end())
        {
            currentSymbolTable = currentSymbolTable->parent;
            continue;
        }
        else
        {
            currentSymbolTable = temp;
            return entry->second;
        }
    }
    currentSymbolTable = temp;
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

void convertFunctionParamsToStack(SymbolTableEntry *currentFunc)
{
    functionParameters = stack<VariableType>();
    for (int i = currentFunc->functionInput.size() - 1; i >= 0; i--)
    {
        functionParameters.push(currentFunc->functionInput[i]);
    }
}

bool idExistsInAnEnum(SymbolTable *table, char *id)
{
    for (auto entry : table->entries)
    {
        if (entry.second->kind == ENUMERATOR)
        {
            if (idExistsInEnum(entry.second, id))
            {
                return true;
            }
        }
    }
    for (auto child : table->children)
    {
        if (idExistsInAnEnum(child, id))
        {
            return true;
        }
    }
    return false;
}

void traverseSymbolTable(SymbolTable *table, int level, ofstream &outputFile)
{
    outputFile << std::setw(level * 4) << ""
               << "Identifier"
               << std::setw(12) << "Level"
               << std::setw(12) << "Kind"
               << std::setw(12) << "Type"
               << std::setw(18) << "Value" << std::endl;
    outputFile << std::setw(level * 4) << ""
               << "----------"
               << std::setw(12) << "-----"
               << std::setw(12) << "----"
               << std::setw(12) << "----"
               << std::setw(18) << "----" << std::endl;

    for (const auto &entry : table->entries)
    {
        SymbolTableEntry *symbolEntry = entry.second;
        LexemeEntry *lexeme = symbolEntry->lexeme;

        outputFile << std::setw(level * 4) << "" << entry.first
                   << std::setw(18) << level;
        switch (symbolEntry->kind)
        {
        case CONSTANT:
            outputFile << std::setw(14) << "CONSTANT";
            break;
        case VAR:
            outputFile << std::setw(14) << "VAR";
            break;
        case FUNC:
            outputFile << std::setw(14) << "FUNC";
            break;
        case ENUMERATOR:
            outputFile << std::setw(14) << "ENUMERATOR";
            break;
        case PARAM:
            outputFile << std::setw(14) << "PARAM";
            break;
        }
        switch (lexeme->type)
        {
        case INT_TYPE:
            outputFile << std::setw(16) << "INT_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->intVal;
            break;
        case FLOAT_TYPE:
            outputFile << std::setw(16) << "FLOAT_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->floatVal;
            break;
        case STRING_TYPE:
            outputFile << std::setw(16) << "STRING_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->stringVal;
            break;
        case BOOL_TYPE:
            outputFile << std::setw(16) << "BOOL_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->boolVal;
            break;
        case CHAR_TYPE:
            outputFile << std::setw(16) << "CHAR_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->charVal;
            break;
        case VOID_TYPE:
            outputFile << std::setw(16) << "VOID_TYPE";
            break;
        case ENUM_TYPE:
            outputFile << std::setw(16) << "ENUM_TYPE";
            if (symbolEntry->kind == VAR || symbolEntry->kind == CONSTANT)
                outputFile << std::setw(15) << lexeme->stringVal;
            break;
        }
        outputFile << std::endl;
        if (entry.second->isUsed == false)
            fprintf(semanticFile, "Warning: %s is declared but not used\n", entry.first.c_str());
    }

    outputFile << std::endl;

    for (SymbolTable *child : table->children)
    {
        traverseSymbolTable(child, level + 1, outputFile);
    }
}

void printSymbolTables()
{
    traverseSymbolTable(rootSymbolTable, 0, symbolTablesFile);
    symbolTablesFile.close();
    fclose(semanticFile);
    fclose(quadrupleFile);
    fclose(syntaxFile);
}

void printSemanticError(string error, int lineNo)
{
    fprintf(semanticFile, "%s At Line Number %d\n", error.c_str(), lineNo);
    printf("There are semantic errors\n");
    printSymbolTables();
    exit(0);
}

SymbolTableEntry *checkIfIdExistsInCurrentScope(char *identifier)
{
    string id(identifier);
    unordered_map<string, SymbolTableEntry *> map = currentSymbolTable->entries;
    auto entry = map.find(id);
    if (entry == map.end())
    {
        return NULL;
    }
    else
    {
        return entry->second;
    }
}

void printSemanticWarning(string warning, int lineNo)
{
    fprintf(semanticFile, "%s At Line No %d\n", warning.c_str(), lineNo);
}

void printSyntaxError(string error, int lineNo)
{
    fprintf(syntaxFile, "%s At Line Number %d\n", error.c_str(), lineNo);
    printf("There are syntax errors\n");
    printSymbolTables();
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
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal == lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal == lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal == lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal == lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal == lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal == lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) == 0;

    else
        return false;
}

bool checkNE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal != lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal != lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal != lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal != lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal != lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal != lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) != 0;

    else
        return false;
}

bool checkGE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal >= lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal >= lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal >= lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal >= lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal >= lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal >= lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) >= 0;

    else
        return false;
}

bool checkLE(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal <= lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal <= lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal <= lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal <= lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal <= lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal <= lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) <= 0;

    else
        return false;
}

bool checkGT(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal > lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal > lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal > lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal > lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal > lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal > lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) > 0;

    else
        return false;
}

bool checkLT(LexemeEntry *lex1, LexemeEntry *lex2)
{
    if (lex1->type == INT_TYPE && lex2->type == FLOAT_TYPE)
        return lex1->intVal < lex2->floatVal;

    else if (lex1->type == FLOAT_TYPE && lex2->type == INT_TYPE)
        return lex1->floatVal < lex2->intVal;

    else if (lex1->type == INT_TYPE)
        return lex1->intVal < lex2->intVal;

    else if (lex1->type == FLOAT_TYPE)
        return lex1->floatVal < lex2->floatVal;

    else if (lex1->type == BOOL_TYPE)
        return lex1->boolVal < lex2->boolVal;

    else if (lex1->type == CHAR_TYPE)
        return lex1->charVal < lex2->charVal;

    else if (lex1->type == STRING_TYPE)
        return strcmp(lex1->stringVal, lex2->stringVal) < 0;

    else
        return false;
}

#endif