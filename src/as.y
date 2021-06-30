%{
/* tpc-2020-2021.y */
/* Syntaxe du TPC pour le projet d'analyse syntaxique de 2020-2021*/
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include "abstract-tree.h"
#include "decl-var.h"
int yylex();
int parse = 0;
int result;
int tree, symtabs;
void yyerror(char *s);
extern int lineno;
extern int charno;
%}

%union{
    char ident[256];
    Node *node;
}

%token <node> ORDER EQ CHARACTER ADDSUB DIVSTAR NUM IDENT TYPE VOID READE READC PRINT IF ELSE WHILE RETURN OR AND STRUCT

%type <node> ListExp Arguments LValue F T E M FB TB Exp Instr SuiteInstr Corps ListTypVar Parametres EnTeteFonct DeclFonct DeclFoncts Declarateurs DeclVars DeclStructsVars Prog '=' '.' '!'

%expect 1

%%
Prog:  DeclStructsVars DeclFoncts                                   {$$ = makeNode(Program); addChild($$, $1); addChild($$, $2); SymbolTable *table = createTable($$); if(tree){printTree($$);} if(symtabs) {printTable(table);}}
    ;

DeclStructsVars:
        DeclStructsVars STRUCT IDENT '{' DeclVars '}' ';'           {$$ = $1; Node *node = makeNode(DeclStruct); strcpy(node->u.identifier, $3->u.identifier); addChild(node, $5); addChild($$, node);}
    |   DeclStructsVars STRUCT IDENT Declarateurs ';'               {$$ = $1; Node *node = makeNode(StructType); strcpy(node->u.identifier, $3->u.identifier); addChild(node, $4); addChild($$, node);}
    |   DeclStructsVars TYPE Declarateurs ';'                       {$$ = $1; addChild($$, $2); addChild($2, $3);}
    |                                                               {$$ = makeNode(DeclStructsVars);}
    ;

DeclVars:
        DeclVars TYPE Declarateurs ';'                              {$$ = $1; addChild($2, $3); addSibling($$, $2);}
    |   DeclVars STRUCT IDENT Declarateurs ';'                      {$$ = $1; Node *node = makeNode(StructType); strcpy(node->u.identifier, $3->u.identifier); addChild(node, $4); addSibling($$, node);}
    |   TYPE Declarateurs ';'                                       {$$ = $1; addChild($$, $2);}
    |   STRUCT IDENT Declarateurs ';'                               {$$ = makeNode(StructType); strcpy($$->u.identifier, $2->u.identifier); addChild($$, $3);}
    ;
Declarateurs:
       Declarateurs ',' IDENT                                       {$$ = $1; addSibling($$, $3);}
    |  IDENT                                                        {$$ = $1;}
    ;
DeclFoncts:
       DeclFoncts DeclFonct                                         {$$ = $1; addChild($1, $2);}
    |  DeclFonct                                                    {$$ = makeNode(DeclFoncts); addChild($$, $1);}
    |  error                                                        {$$ = NULL; yyclearin;}
    ;
DeclFonct:
       EnTeteFonct Corps                                            {$$ = makeNode(Fonct); addChild($$, $1); addChild($$, $2);}
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'                                {$$ = makeNode(EnTeteFonct); addChild($$, $2); addChild($$, $1); addChild($$, $4);}
    |  VOID IDENT '(' Parametres ')'                                {$$ = makeNode(EnTeteFonct); addChild($$, $2); addChild($$, $1); addChild($$, $4);}
    |  STRUCT IDENT IDENT '(' Parametres ')'                        {$$ = makeNode(EnTeteFonct); addChild($$, $3); Node *node = makeNode(StructType); strcpy(node->u.identifier, $2->u.identifier); addChild($$, node); addChild($$, $5);}
    |  error                                                        {$$ = NULL; yyclearin;}
    ;
Parametres:
       VOID                                                         {$$ = makeNode(Parametres); addChild($$, $1);}
    |  ListTypVar                                                   {$$ = makeNode(Parametres); addChild($$, $1);}
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT                                    {$$ = $1; Node *n = makeNode(Parametre); addChild(n, $3); addChild(n, $4); addSibling($$, n);}
    |  ListTypVar ',' STRUCT IDENT IDENT                            {$$ = $1; Node *n = makeNode(Parametre); Node *node = makeNode(StructType); strcpy(node->u.identifier, $4->u.identifier); addChild(n, node); addChild(n, $5); addSibling($$, n);}
    |  TYPE IDENT                                                   {$$ = makeNode(Parametre); addChild($$, $1); addChild($$, $2);}
    |  STRUCT IDENT IDENT                                           {$$ = makeNode(Parametre); Node *node = makeNode(StructType); strcpy(node->u.identifier, $2->u.identifier); addChild($$, node); addChild($$, $3);}
    |  error                                                        {$$ = NULL; yyclearin;}
    ;
Corps: '{' DeclStructsVars SuiteInstr '}'                           {$$ = makeNode(Corps); addChild($$, $2); addChild($$, $3);}
    ;
SuiteInstr:
       SuiteInstr Instr                                             {$$ = $1; addChild($$, $2);}
    |                                                               {$$ = makeNode(SuiteInstr);}
    ;
Instr:
       LValue '=' Exp ';'                                           {$$ = makeNode(Assign); addChild($$, $1); addChild($$, $3);}
    |  READE '(' IDENT ')' ';'                                      {$$ = $1; addChild($$, $3);}
    |  READC '(' IDENT ')' ';'                                      {$$ = $1; addChild($$, $3);}
    |  PRINT '(' Exp ')' ';'                                        {$$ = $1; addChild($$, $3);}
    |  IF '(' Exp ')' Instr                                         {$$ = $1; Node *cond = makeNode(Condition); addChild(cond, $3); addChild($$, cond); addChild($$, $5);}
    |  IF '(' Exp ')' Instr ELSE Instr                              {$$ = $1; Node *cond = makeNode(Condition); addChild(cond, $3); addChild($$, cond); addChild($$, $5); addChild($$, $6); addChild($6, $7);}
    |  WHILE '(' Exp ')' Instr                                      {$$ = $1; Node *cond = makeNode(Condition); addChild(cond, $3); addChild($$, cond); addChild($$, $5);}
    |  IDENT '(' Arguments  ')' ';'                                 {$$ = makeNode(FonctCall); strcpy($$->u.identifier, $1->u.identifier); addChild($$, $3);}
    |  RETURN Exp ';'                                               {$$ = $1; addChild($$, $2);}
    |  RETURN ';'                                                   {$$ = $1;}
    |  '{' SuiteInstr '}'                                           {$$ = $2;}
    |  ';'                                                          {$$ = NULL;}
    |  error                                                        {$$ = NULL; yyclearin;}
    ;
Exp :  Exp OR TB                                                    {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  TB                                                           {$$ = $1;}
    |  error                                                        {$$ = NULL; yyclearin;}
    ;
TB  :  TB AND FB                                                    {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  FB                                                           {$$ = $1;}
    ;
FB  :  FB EQ M                                                      {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  M                                                            {$$ = $1;}
    ;
M   :  M ORDER E                                                    {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  E                                                            {$$ = $1;}
    ;
E   :  E ADDSUB T                                                   {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  T                                                            {$$ = $1;}
    ;
T   :  T DIVSTAR F                                                  {$$ = $2; addChild($$, $1); addChild($$, $3);}
    |  F                                                            {$$ = $1;}
    ;
F   :  ADDSUB F                                                     {$$ = $2; addChild($$, $1);}
    |  '!' F                                                        {$$ = makeNode(NegStruct); addChild($$, $2);}
    |  '(' Exp ')'                                                  {$$ = $2;}
    |  NUM                                                          {$$ = $1;}
    |  CHARACTER                                                    {$$ = $1;}
    |  LValue                                                       {$$ = makeNode(ValueOf); addChild($$, $1);}
    |  IDENT '(' Arguments ')'                                     {$$ = makeNode(FonctCall); strcpy($$->u.identifier, $1->u.identifier); addChild($$, $3);}
    ;
LValue:
       IDENT                                                        {$$ = $1;}
    |  IDENT '.' LValue                                             {$$ = makeNode(PointStruct); addChild($$, $1); addChild($$, $3);}
    ;
Arguments:
       ListExp                                                      {$$ = $1;}
    |                                                               {$$ = NULL;}
    ;
ListExp:
       ListExp ',' Exp                                              {$$ = $1; addSibling($1, $3);}
    |  Exp                                                          {$$ = $1;}
    ;
%%

void print_help(void) {
    printf("Use : ./tpcc [OPTION]... [FILE]\n");
    printf("Options :\n");
    printf("-h --help\tShow this help.\n");
    printf("-t --tree\tDisplay the abstract tree of FILE.tpc on the terminal.\n");
    printf("-s --symtabs\tDisplay the symbol table of FILE.tpc on the terminal.\n");
}

int main(int argc, char * const* argv) {
    tree = 0;
    symtabs = 0;
    char c;
    static struct option long_options[] =
        {
          {"tree", no_argument, 0, 't'},
          {"symtabs", no_argument, 0, 's'},
          {"help", no_argument, 0, 'h'},
          {0, 0, 0, 0}
        };
    while((c = getopt_long(argc, argv, "tsh", long_options, 0)) != -1) {
        switch(c) {
            case 't': tree = 1; break;
            case 's': symtabs = 1; break;
            case 'h': print_help(); return NO_ERROR;
            case '?': printf("unknown option -%c ignored\n", optopt); break;
            default:
                printf("unknown error when parsing arguments\n");
                exit(USAGE_ERROR);
        }
    }
    result = yyparse();
    if(parse > 0){
        if(parse == 1)
            printf("There is 1 error in your code\n");
        else
            printf("There are %d errors in your code\n", parse);
    }
    else
        printf("Your code is correct.\n");
    if (result == 2) {
        return result;
    }
    return result || parse != 0;
}

void yyerror(char *s) {
    fprintf(stderr, "%s", yylval.ident);
    for(int i = 0; i < charno - 1; i++)
        fprintf(stderr, " ");
    fprintf(stderr, "^\n");
    fprintf(stderr, "error : %s", yylval.ident);
    fprintf(stderr, "%s in line %d, in character %d\n\n", s, lineno, charno);
    parse ++;
}
