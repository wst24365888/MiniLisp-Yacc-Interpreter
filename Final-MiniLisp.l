
%{
#include "Final-MiniLisp.tab.h"
%}

/* Preliminary Definitions */
separator   [\t|\n|\r| ]
letter      [a-z]
digit       [0-9]

/* Token Definitions */
number      0|[1-9]{digit}*|-[1-9]{digit}*
id          {letter}({letter}|{digit}|-)*
bool        "#t"|"#f"
%%
"print-num"     {return PRINT_NUM;}
"print-bool"	{return PRINT_BOOL;}

"+"             {
                    return ADD;
                }
"-"             {
                    return SUB;
                }
"*"             {
                    return MUL;
                }
"/"             {
                    return DIV;
                }
"mod"           {
                    return MOD;
                }

">"             {
                    return BIGGER_THAN;
                }
"<"             {
                    return SMALLER_THAN;
                }
"="             {
                    return EQUAL;
                }

"and"           {
                    return AND;
                }
"or"            {
                    return OR;
                }
"not"           {
                    return NOT;
                }

"define"        {return DEFINE;}
"fun"           {return FUNCTION;}
"if"            {return IF;}

"("|")"         {return yytext[0];}

{id}            {   
                    /* The reason that id places here is because if id matches, than words like "define", "function" will not match. */
                    yylval.ASTN = newNode(newDynamic(string, strdup(yytext), 0, false), NULL, NULL);
                    return ID;
                }

{number}        {
                    yylval.ASTN = newNode(newDynamic(integer, NULL, atoi(yytext), false), NULL, NULL);
                    return NUMBER;
                }

{bool}          {
                    yylval.ASTN = newNode(newDynamic(boolean, NULL, 0, yytext[1] == 't' ? true : false), NULL, NULL);
                    return BOOL;
                }

{separator}     {/* Do nothing. */}
.|\n            {/* Do nothing. */}

%%