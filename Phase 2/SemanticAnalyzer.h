#ifndef SEMANTICANALYZER_H
#define SEMANTICANALYZER_H

#include "Classes.h"
#include <iostream>
using namespace std;

SymbolTable *currentSymbolTable = new SymbolTable();

void createNewTable()
{
    SymbolTable *newSymbolTable = new SymbolTable();
    newSymbolTable->parent = currentSymbolTable;
    currentSymbolTable->children.push_back(newSymbolTable);
    currentSymbolTable = newSymbolTable;
}

bool addEntryToTable(SymbolTableEntry *entry, string identifier)
{
    unordered_map<string, SymbolTableEntry *> map = currentSymbolTable->entries;
    auto lex = map.find(identifier);
    if (lex != map.end())
        return false;
    (currentSymbolTable->entries)[identifier] = entry;
    return true;
}

SymbolTableEntry *entryExistsInTable(string identifier)
{
    unordered_map<string, SymbolTableEntry *> map = currentSymbolTable->entries;
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

#endif