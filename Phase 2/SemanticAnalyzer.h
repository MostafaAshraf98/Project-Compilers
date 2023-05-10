#ifndef SEMANTICANALYZER_H
#define SEMANTICANALYZER_H

#include "Classes.h"
using namespace std;

SymbolTable *currentSymbolTable = new SymbolTable();

void createNewTable()
{
    SymbolTable *newSymbolTable = new SymbolTable();
    newSymbolTable->parent = currentSymbolTable;
    currentSymbolTable->children.push_back(newSymbolTable);
    currentSymbolTable = newSymbolTable;
}

bool addEntryToTable(SymbolTableEntry *entry, char* identifier)
{
    unordered_map<char*, SymbolTableEntry *> map = currentSymbolTable->entries;
    auto lex = map.find(identifier);
    if (lex != map.end())
        return false;
    (currentSymbolTable->entries)[identifier] = entry;
    return true;
}

SymbolTableEntry *getIdEntry(char* identifier)
{
    unordered_map<char*, SymbolTableEntry *> map = currentSymbolTable->entries;
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

VariableType checkIdType(char* identifier)
{
    SymbolTableEntry *entry = getIdEntry(identifier);
    if (entry == NULL)
        return VOID_TYPE;
    return entry->lexeme->type;
}

bool isTypeMatching(VariableType type1, VariableType type2)
{
    if (type1 == type2 || (type1 == INT_TYPE && type2 == FLOAT_TYPE) || (type1 == FLOAT_TYPE && type2 == INT_TYPE))
        return true;
    return false;
}

#endif