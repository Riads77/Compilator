/* abstract-tree.h */
#ifndef __ABSTRACTTREE__
#define __ABSTRACTTREE__
typedef enum
{
  Program,
  VarDeclList,
  IntLiteral,
  CharLiteral,
  Identifier,
  Exp,
  PointStruct,
  NegStruct,
  Add,
  Sub,
  Star,
  Div,
  Modulo,
  Lower,
  Higher,
  LowEq,
  HighEq,
  Equal,
  Inequal,
  Or,
  And,
  Return,
  While,
  If,
  Else,
  Print,
  ReadE,
  ReadC,
  DeclStructsVars,
  SuiteInstr,
  Corps,
  Type,
  StructType,
  Void,
  DeclFoncts,
  Fonct,
  Parametres,
  Parametre,
  EnTeteFonct,
  Assign,
  Condition,
  FonctCall,
  ValueOf,
  DeclStruct

  /* and all other node labels */
  /* The list must coincide with the strings in abstract-tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} Kind;

typedef struct Node
{
  Kind kind;
  union
  {
    int integer;
    char character;
    char identifier[64];
  } u;
  struct Node *firstChild, *nextSibling;
  int lineno;
} Node;

typedef enum
{
  NO_ERROR,       // 0
  SYNTAX_ERROR,   // 1
  SEMANTIC_ERROR, // 2
  USAGE_ERROR,    // 3
  INTERNAL_ERROR, // 4
  SYSTEM_ERROR    // 5
} status_t;

Node *makeNode(Kind kind);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node *node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling

#endif
