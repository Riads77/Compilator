/* decl-var.h */
/* Analyse descendante récursive des déclarations de variables en C */
#define MAXNAME 32
#define MAXARG 32
#define TAILLE_INITIALE_TABLE 64
#define MAX_LENGTH_IDENTIFIER 64
#define MAX_NAME_LENGTH 64
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include "abstract-tree.h"


typedef enum
{
    Int,
    Char
} EnumType;

    typedef enum {
        Func,
        Primitive,
        Str,
        DeclStr //temporaire ?
    } KindType;

typedef struct StruVar
{
    char identifier[128];
} StruVar;

typedef struct Stru
{
    char identifier[64];
} Stru;

typedef struct TypeOrStruct
{
    KindType kind;
    union
    {
        EnumType type;
        Stru struc;
    } u;
} TypeOrStruct;

typedef struct Fonction
{
    TypeOrStruct entree[MAXARG];
    int isvoid;
    union
    {
        TypeOrStruct sortie;
    } u;
    int countarg;
} Fonction;

typedef struct TypeEntry
{
    KindType kind;
    union
    {
        EnumType ident;
        Fonction fonc;
        Stru struc;
        StruVar strvar;
    } u;
} TypeEntry;

typedef struct
{
    char identifier[MAX_NAME_LENGTH];
    TypeEntry type;
    size_t offset; // Offset in bytes.
} TableEntry;

typedef struct SymbolTable {
    TableEntry **array;
    char name[MAX_NAME_LENGTH];
    struct SymbolTable *parent;
    int count_symbols;
    int size_array;
} SymbolTable;

//extern char yylval[MAXNAME];

void printTable(SymbolTable *table);
SymbolTable *createTable(Node *tree);
