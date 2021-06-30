#include "decl-var.h"

SymbolTable *makeTable(char name[MAX_NAME_LENGTH], SymbolTable *parent) {
    SymbolTable *table;
    if ((table = (SymbolTable*) (malloc(sizeof(SymbolTable)))) == NULL) {
        fprintf(stderr, "Problem of memory allocation\n");
        exit(EXIT_FAILURE);
    }
    assert(name != NULL);
    if ((table->array = (TableEntry**) malloc(TAILLE_INITIALE_TABLE * sizeof(TableEntry*))) == NULL) {
        fprintf(stderr, "Problem of memory allocation\n");
        exit(EXIT_FAILURE);
    }

    strcpy(table->name, name);
    table->parent = parent;
    table->size_array = TAILLE_INITIALE_TABLE;
    table->count_symbols = 0;
    return table;
}

int readEntry(SymbolTable *table, char *identifier) {
    int i;
    assert(table != NULL && identifier != NULL);
    for (i = 0; i < table->count_symbols; i++) {
        if (!strcmp(table->array[i]->identifier, identifier))
            return SEMANTIC_ERROR;
    }
    return NO_ERROR;
}

TypeEntry createTypeEntry(KindType kind) {
    TypeEntry type;
    type.kind = kind;
    return type;
}

TableEntry *createTableEntry(char identifier[MAX_NAME_LENGTH], TypeEntry type) {
    TableEntry *entry;
    if ((entry = (TableEntry *)malloc(sizeof(TableEntry))) == NULL) {
        fprintf(stderr, "Problem of memory allocation\n");
        exit(EXIT_FAILURE);
    }
    assert(identifier != NULL);
    strcpy(entry->identifier, identifier);
    entry->type = type;
    entry->offset = sizeof(TableEntry);
    return entry;
}

static void increaseTable(SymbolTable *table) {
    assert(table != NULL);
    table->array = (TableEntry **) realloc(table->array, 2 * table->size_array * sizeof(TableEntry *));
    table->size_array *= 2;
}

void insertEntry(SymbolTable *table, char *identifier, TypeEntry entry) {
    assert(table != NULL && identifier != NULL);
    if (readEntry(table, identifier)) {
        fprintf(stderr, "Redeclaration of the variable %s\n", identifier);
        exit(SEMANTIC_ERROR);
    }
    if (table->count_symbols >= table->size_array)
        increaseTable(table);
    table->array[table->count_symbols] = createTableEntry(identifier, entry);
    table->count_symbols++;
}

void printEntry(char *id, char *type) {
    assert(id != NULL && type != NULL);
    printf("Id : %s | Type : %s\n", id, type);
}

void printTableEntry(TableEntry *entry) {
    assert(entry != NULL);
    switch (entry->type.kind) {
        case Func:
            /*
            if (entry->type.u.fonc.is_void) {
                printEntry(entry->identifier, "Void");
            }
            else if()
            printEntry(entry->identifier, entry->type.u.fonc.identifier);
            */
            break;
        case Primitive:
            if (entry->type.u.ident == Int)
                printEntry(entry->identifier, "Int");
            else
                printEntry(entry->identifier, "Char");
            break;
        case Str:
            printEntry(entry->identifier, entry->type.u.strvar.identifier);
            break;
        case DeclStr:
            printEntry(entry->identifier, entry->type.u.struc.identifier);
            break;
    }
}

void printTable(SymbolTable *table) {
    int i;
    assert(table != NULL);
    printf("----------%s----------\n", table->name);
    for (i = 0; i < table->count_symbols; i++) {
        printTableEntry(table->array[i]);
    }
    printf("---------------------------------\n");
    //appel récursif ou itératif sur parent. ??
}

void insert_declarations(Node *node, SymbolTable *table, TypeEntry type) {
    assert(table != NULL);
    if (node == NULL)
        return;
    insertEntry(table, node->u.identifier, type);
    insert_declarations(node->nextSibling, table, type);
}
/*
void insert_functions(Node *node, SymbolTable *table) {
    Node *en_tete = FIRSTCHILD(node);
    Node *corps = SECONDCHILD(node);
    Node *type_fun = SECONDCHILD(en_tete);
        TypeEntry type;
    assert(table != NULL);
    if (node != NULL) {
        assert(en_tete != NULL && corps != NULL);
        type = createTypeEntry(Func);
        type_fun->fonc.isvoid = 0;
        switch (type_fun) {
            case Type:
                if (!(strcmp(type_fun->u.identifier)), "int")
                    type.u.fonc.u.sortie.ident.u.type = Int;
                else
                    type.u.fonc.u.sortie.ident.u.type = Char;
            case Void:
                type_fun->fonc.isvoid = 1;
            case StructType:
                strcpy(type.u.fonc.u.sortie.strvar.identifier, strcat(struct_type, type_fun->u.identifier));
            default:
                fprintf(stderr, "Unknown type of function\n");
                exit(SEMANTIC_ERROR);
        }
        type = strcpy(type.u.fonc.u.kind, SECONDCHILD(en_tete)->u.identifier);
        insertEntry(table, FIRSTCHILD(en_tete)->u.identifier, type);
    }
    insert_functions(node->nextSibling, table);
}
*/

void browsing_tree(Node *tree, SymbolTable *table) {
    char id_type[64];
    char struct_type[128];
    strcpy(struct_type, "struct ");
    TypeEntry type;
    assert(table != NULL);
    if (tree != NULL) {
        switch (tree->kind) {
            case Type:
                type = createTypeEntry(Primitive);
                strcpy(id_type, tree->u.identifier);
                if (!strcmp(id_type, "int"))
                    type.u.ident = Int;
                else
                    type.u.ident = Char;
                insert_declarations(FIRSTCHILD(tree), table, type);
                browsing_tree(tree->nextSibling, table);
                return;
            case StructType:
                type = createTypeEntry(Str);
                strcpy(id_type, tree->u.identifier);
                strcpy(type.u.strvar.identifier, strcat(struct_type, id_type));
                insert_declarations(FIRSTCHILD(tree), table, type);
                browsing_tree(tree->nextSibling, table);
                return;
            case DeclStruct:
                type = createTypeEntry(DeclStr);
                strcpy(id_type, tree->u.identifier);
                strcpy(type.u.struc.identifier, "struct");
                insertEntry(table, id_type, type);
                browsing_tree(tree->nextSibling, table);
                return;
            case DeclFoncts:
                //insert_functions(Node *tree, SymbolTable *table);
                break;
            default:
                break;
        }
        browsing_tree(FIRSTCHILD(tree), table);
        browsing_tree(tree->nextSibling, table);
    }
}

SymbolTable *createTable(Node *tree) {
    SymbolTable *table = makeTable("global", NULL);
    assert(tree != NULL);
    browsing_tree(tree, table);
    return table;
}
