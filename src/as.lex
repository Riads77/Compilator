%{
#include "abstract-tree.h"
#include "as.tab.h"
int lineno = 1;
int charno = 0;
%}

%option noinput
%option nounput
%x COMMENT


%%
^.*[\n<<EOF>>]                  {strcpy(yylval.ident, yytext); REJECT;}
void                            {charno += yyleng; yylval.node = makeNode(Void); return VOID;}
int|char                        {charno += yyleng; yylval.node = makeNode(Type); strcpy(yylval.node->u.identifier, yytext); return TYPE;}
print                           {charno += yyleng; yylval.node = makeNode(Print); return PRINT;}
\|\|                            {charno += yyleng; yylval.node = makeNode(Or); return OR;}
&&                              {charno += yyleng; yylval.node = makeNode(And); return AND;}
==                              {charno += yyleng; yylval.node = makeNode(Equal); return EQ;}
!=                              {charno += yyleng; yylval.node = makeNode(Inequal); return EQ;}
if                              {charno += yyleng; yylval.node = makeNode(If); return IF;}
else                            {charno += yyleng; yylval.node = makeNode(Else); return ELSE;}
return                          {charno += yyleng; yylval.node = makeNode(Return); return RETURN;}
while                           {charno += yyleng; yylval.node = makeNode(While); return WHILE;}
readc                           {charno += yyleng; yylval.node = makeNode(ReadC); return READC;}
reade                           {charno += yyleng; yylval.node = makeNode(ReadE); return READE;}
struct 							{charno += yyleng; return STRUCT;}
"<"                             {charno += yyleng; yylval.node = makeNode(Lower); return ORDER;}
>                               {charno += yyleng; yylval.node = makeNode(Higher); return ORDER;}
"<="                            {charno += yyleng; yylval.node = makeNode(LowEq); return ORDER;}
">="                            {charno += yyleng; yylval.node = makeNode(HighEq); return ORDER;}
"+"                             {charno += yyleng; yylval.node = makeNode(Add); return ADDSUB;}
"-"                             {charno += yyleng; yylval.node = makeNode(Sub); return ADDSUB;}
"*"							    {charno += yyleng; yylval.node = makeNode(Star); return DIVSTAR;}
"/"							    {charno += yyleng; yylval.node = makeNode(Div); return DIVSTAR;}
%							    {charno += yyleng; yylval.node = makeNode(Modulo); return DIVSTAR;}
[a-zA-Z_][a-zA-Z0-9_]*          {charno += yyleng; yylval.node = makeNode(Identifier); strcpy(yylval.node->u.identifier, yytext); return IDENT;}
\'([^']|\\n|\\'|\\t)\'          {charno += yyleng; yylval.node = makeNode(CharLiteral); yylval.node->u.character = yytext[1]; return CHARACTER;}
[0-9]+                      	{charno += yyleng; yylval.node = makeNode(IntLiteral); yylval.node->u.integer = atoi(yytext); return NUM;}
"/*"                            BEGIN COMMENT;
<COMMENT>"*/"                   BEGIN INITIAL;
<COMMENT>.                      {charno += yyleng;}
<COMMENT>\n                     {lineno += 1; charno = 0;}
\/\/.*\n                        {lineno += 1; charno = 0;}
\t                              {charno += 4;}
" "                             {charno += 1;}
[\=\+\-\/%!&,;\(\)\{\}\[\].]    {charno += 1; return yytext[0];}
\n                              {lineno += 1; charno = 0;}
.                               {return 0;}
%%
