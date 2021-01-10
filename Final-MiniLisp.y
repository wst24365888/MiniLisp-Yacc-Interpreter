%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    #define bool int
    #define true  1
    #define false 0

    #define DEBUG 0
    #define MAX 999

    #define no_type                 2647672694
    #define equals_to_parent        1265483310
    #define print_num               3328096084
    #define print_bool              418110896
    #define if_else                 3488659535
    #define if_stmts                17783521
    #define define_variable         1904048008
    #define get_variable            563528797
    #define define_function         2756550056
    #define function                451124702
    #define function_parameters     434998129
    #define call_function           1684390617
    #define define_inside_function  1499862659
    #define integer                 1958354022
    #define string                  1561885455
    #define boolean                 3847221336
    #define add                     2194969249
    #define sub                     2196162498
    #define mul                     2195766214
    #define div                     2195168699
    #define mod                     2195764664
    #define bigger_than             2719375090
    #define smaller_than            415250802
    #define equal                   3689648016
    #define and                     2194971819
    #define or                      58680153
    #define not                     2195830729

    int yylex();
    void yyerror(const char *message);

    struct Dynamic {
        unsigned long   type;

        char*           name;
        int             intVal;
        bool            boolVal;
    };

    struct ASTNode {
        struct Dynamic*  val;
        
        struct ASTNode* parent;
        struct ASTNode* leftChild;
        struct ASTNode* rightChild;
    };

    struct Dynamic* newDynamic(unsigned long type, char* variableName, int intVal, bool boolVal);
    struct Dynamic* emptyDynamic();

    struct ASTNode* newNode(struct Dynamic* val, struct ASTNode* leftChild, struct ASTNode* rightChild);
    struct ASTNode* emptyNode();

    void traverse(struct ASTNode* node, unsigned long parent_type, bool insideFunction);

    struct ASTNode* root;

    struct ASTNode* definedVariables[MAX];
    int definedVariablesTop;

    void addDefinedVariable(struct ASTNode* node);
    struct ASTNode* getDefinedVariable(char* variableName);

    struct Function {
        char* functionName;
        
        struct ASTNode* params;
        struct ASTNode* task;
    };
    
    struct Function* definedFunctions[MAX];
    int definedFunctionsTop;

    struct ASTNode* cloneAST(struct ASTNode* node);

    void addFunction(char* functionName, struct ASTNode* functionToAdd);
    struct Function* getFunction(char* functionName);

    void assignParamsNameAndBind(struct ASTNode* parametersName, struct ASTNode* parametersToAssign, struct ASTNode* functionTask);
    void bindParams(struct ASTNode* taskNode, struct ASTNode* toReplace);
}

%define parse.error verbose

%union {
    struct ASTNode* ASTN;
}

%type   <ASTN>  stmt
%type   <ASTN>  stmts
%type   <ASTN>  print_stmt

%type   <ASTN>  exp
%type   <ASTN>  exps

%type   <ASTN>  num_op
%type   <ASTN>  logical_op

%type   <ASTN>  def_stmt
%type   <ASTN>  variable

%type   <ASTN>  function_exp
%type   <ASTN>  ids
%type   <ASTN>  function_call
%type   <ASTN>  function_ids
%type   <ASTN>  function_body
%type   <ASTN>  function_name
%type   <ASTN>  parameters

%type   <ASTN>  if_exp
%type   <ASTN>  test_exp
%type   <ASTN>  then_exp
%type   <ASTN>  else_exp

%token  <ASTN>  NUMBER
%token  <ASTN>  ID
%token  <ASTN>  BOOL

%token  <ASTN>  PRINT_NUM
%token  <ASTN>  PRINT_BOOL

%token  <ASTN>  ADD
%token  <ASTN>  SUB
%token  <ASTN>  MUL
%token  <ASTN>  DIV
%token  <ASTN>  MOD

%token  <ASTN>  BIGGER_THAN
%token  <ASTN>  SMALLER_THAN
%token  <ASTN>  EQUAL

%token  <ASTN>  AND
%token  <ASTN>  OR
%token  <ASTN>  NOT

%token  <ASTN>  DEFINE
%token  <ASTN>  FUNCTION
%token  <ASTN>  IF
%%

program         :   stmts       {
                    root = $1;
                }

stmts           :   stmt stmts  {
                    $$ = newNode(emptyDynamic(), $1, $2);
                }
                |   stmt        {
                    $$ = $1;
                }

stmt            :   exp         {
                    $$ = $1;
                }
                |   def_stmt    {
                    $$ = $1;
                }
                |   print_stmt  {
                    $$ = $1;
                }
                ;

print_stmt      :   '(' PRINT_NUM   exp ')' {
                    $$ = newNode(newDynamic(print_num, NULL, 0, false), $3, NULL);
                }
                |   '(' PRINT_BOOL  exp ')' {
                    $$ = newNode(newDynamic(print_bool, NULL, 0, false), $3, NULL);
                }

exps            :   exp exps    {
                    $$ = newNode(newDynamic(equals_to_parent, NULL, 0, false), $1, $2);
                }
                |   exp         {
                    $$ = $1;
                }

exp             :   BOOL            {
                    $$ = $1;
                }
                |   NUMBER          {
                    $$ = $1;
                }
                |   variable        {
                    $$ = newNode(newDynamic(get_variable, $1->val->name, 0, false), NULL, NULL);
                }
                |   num_op          {
                    $$ = $1;
                }
                |   logical_op      {
                    $$ = $1;
                }
                |   function_exp    {                    
                    $$ = $1;
                }
                |   function_call   {                    
                    $$ = $1;
                }
                |   if_exp   {                    
                    $$ = $1;
                }
                ;

num_op          :   '(' ADD             exp exps    ')' {
                    $$ = newNode(newDynamic(add, NULL, 0, false), $3, $4);
                }
                |   '(' SUB             exp exp     ')' {
                    $$ = newNode(newDynamic(sub, NULL, 0, false), $3, $4);
                }
                |   '(' MUL             exp exps    ')' {
                    $$ = newNode(newDynamic(mul, NULL, 0, false), $3, $4);
                }
                |   '(' DIV             exp exp     ')' {
                    $$ = newNode(newDynamic(div, NULL, 0, false), $3, $4);
                }
                |   '(' MOD             exp exp     ')' {
                    $$ = newNode(newDynamic(mod, NULL, 0, false), $3, $4);
                }
                |   '(' BIGGER_THAN     exp exp     ')' {
                    $$ = newNode(newDynamic(bigger_than, NULL, 0, false), $3, $4);
                }
                |   '(' SMALLER_THAN    exp exp     ')' {
                    $$ = newNode(newDynamic(smaller_than, NULL, 0, false), $3, $4);
                }
                |   '(' EQUAL           exp exps    ')' {
                    $$ = newNode(newDynamic(equal, NULL, 0, false), $3, $4);
                }

logical_op      :   '(' AND     exp exps    ')' {
                    $$ = newNode(newDynamic(and, NULL, 0, false), $3, $4);
                }
                |   '(' OR      exp exps    ')' {
                    $$ = newNode(newDynamic(or, NULL, 0, false), $3, $4);
                }
                |   '(' NOT     exp         ')' {
                    $$ = newNode(newDynamic(not, NULL, 0, false), $3, NULL);
                }

def_stmt        :   '(' DEFINE ID exp ')'   {
                    if($4->val->type == function) {
                        $$ = newNode(newDynamic(define_function, NULL, 0, false), $3, $4);
                    } else {
                        $$ = newNode(newDynamic(define_variable, NULL, 0, false), $3, $4);
                    }
                }
                ;

variable        :   ID  {
                    $$ = $1;
                }

function_exp    :   '(' FUNCTION function_ids function_body ')' {
                    $$ = newNode(newDynamic(function, NULL, 0, false), $3, $4);
                }

ids             :   ID  ids     {
                    $$ = newNode(newDynamic(function_parameters, NULL, 0, false), $1, $2);
                }
                |               {
                    $$ = emptyNode();
                }
                ; 

function_ids    :   '(' ids ')' {
                    $$ = $2;
                }

function_body   :   def_stmt function_body   {
                    $$ = newNode(newDynamic(define_inside_function, NULL, 0, false), $1, $2);
                }
                |   exp             {
                    $$ = $1;
                }

function_call   :   '(' function_exp    parameters ')'  {
                    $$ = newNode(newDynamic(call_function, NULL, 0, false), $2, $3);
                }
                |   '(' function_name   parameters ')'  {
                    $$ = newNode(newDynamic(call_function, NULL, 0, false), $2, $3);
                }

parameters      :   exp parameters  {
                    $$ = newNode(newDynamic(function_parameters, NULL, 0, false), $1, $2);
                }
                |                   {
                    $$ = emptyNode();
                }

/* last_exp        :   exp */

function_name   :   ID  {
                    $$ = $1;
                }

if_exp          :   '(' IF test_exp then_exp else_exp ')'     {
                    struct ASTNode* ifStatements = newNode(newDynamic(if_stmts, NULL, 0, false), $4, $5);
                    $$ = newNode(newDynamic(if_else, NULL, 0, false), $3, ifStatements);
                }

test_exp        :   exp     {
                    $$ = $1;
                }

then_exp        :   exp     {
                    $$ = $1;
                }

else_exp        :   exp     {
                    $$ = $1;
                }

%%

struct Dynamic* newDynamic(unsigned long type, char* name, int intVal, bool boolVal) {
    struct Dynamic* toCreate = (struct Dynamic *) malloc(sizeof(struct Dynamic));

    toCreate->type = type;
    toCreate->name = name;

    toCreate->intVal = intVal;
    toCreate->boolVal = boolVal;

    return toCreate;
}

struct Dynamic* emptyDynamic() {
    return newDynamic(no_type, NULL, 0, false);
}

struct ASTNode* newNode(struct Dynamic* val, struct ASTNode* leftChild, struct ASTNode* rightChild) {
    struct ASTNode* toCreate = (struct ASTNode *) malloc(sizeof(struct ASTNode));

    toCreate->val = val;
    toCreate->leftChild = leftChild;
    toCreate->rightChild = rightChild;

    if(leftChild != NULL) {
        leftChild->parent = toCreate;
    }
    if(rightChild != NULL) {
        rightChild->parent = toCreate;
    }

    return toCreate;
}

struct ASTNode* emptyNode() {
    return newNode(emptyDynamic(), NULL, NULL);
}

void addDefinedVariable(struct ASTNode* node) {
    definedVariables[++definedVariablesTop] = node;
}

struct ASTNode* getDefinedVariable(char* name) {
    for(int i = 0; i <= definedVariablesTop; i++) {
        if(strcmp(definedVariables[i]->val->name, name) == 0) {
            return definedVariables[i];
        }
    }
}

struct ASTNode* cloneAST(struct ASTNode* node) {
    if(node == NULL) {
        return NULL;
    }
    
    struct ASTNode* toClone = emptyNode();

    toClone->val->type = node->val->type;
    toClone->val->name = node->val->name;

    toClone->val->intVal = node->val->intVal;
    toClone->val->boolVal = node->val->boolVal;

    toClone->leftChild = cloneAST(node->leftChild);
    toClone->rightChild = cloneAST(node->rightChild);

    return toClone;
}

void addFunction(char* functionName, struct ASTNode* functionToAdd) {
    struct Function* toAdd = (struct Function *) malloc(sizeof(struct Function));

    toAdd->functionName = functionName;
    toAdd->params = functionToAdd->leftChild;
    toAdd->task = functionToAdd->rightChild;

    definedFunctions[++definedFunctionsTop] = toAdd;
}

struct Function* getFunction(char* functionName) {
    for(int i = 0; i <= definedFunctionsTop; i++) {
        if(strcmp(definedFunctions[i]->functionName, functionName) == 0) {
            struct Function* result = (struct Function *) malloc(sizeof(struct Function));

            result->functionName = strdup(definedFunctions[i]->functionName);
            result->params = cloneAST(definedFunctions[i]->params);
            result->task = cloneAST(definedFunctions[i]->task);

            return result;
        }
    }
}

void assignParamsNameAndBind(struct ASTNode* parametersName, struct ASTNode* parametersToAssign, struct ASTNode* functionTask) {
    /* sleep(1); */
    switch(parametersName->val->type) {
        case no_type:
            return;
        case string:
            parametersToAssign->val->name = parametersName->val->name;
            
            if(DEBUG) {
                printf("to assign: %d\n", parametersToAssign->val->intVal);
            }

            bindParams(functionTask, cloneAST(parametersToAssign));

            break;
        case function_parameters:
            parametersToAssign->leftChild->val->name = parametersName->leftChild->val->name;
            
            if(DEBUG) {
                printf("to assign: %d\n", parametersToAssign->leftChild->val->intVal);
            }

            bindParams(functionTask, cloneAST(parametersToAssign->leftChild));

            assignParamsNameAndBind(parametersName->rightChild, parametersToAssign->rightChild, functionTask);
            break;
    }
}

void bindParams(struct ASTNode* taskNode, struct ASTNode* toReplace) {
    if(taskNode == NULL || taskNode->val->type == define_function) {
        return;
    }

    if(taskNode->val->type == get_variable) {
        if(strcmp(taskNode->val->name, toReplace->val->name) == 0) {
            if(DEBUG) {
                printf("bind: %lu -> ", taskNode->val->type);
            }

            taskNode->val->type = toReplace->val->type;
            taskNode->val->intVal = toReplace->val->intVal;
            taskNode->val->boolVal = toReplace->val->boolVal;

            taskNode->leftChild = toReplace->leftChild;
            taskNode->rightChild = toReplace->rightChild;

            if(DEBUG) {
                printf("%lu\n", taskNode->val->type);
            }

            return;
        }
    }

    bindParams(taskNode->leftChild, toReplace);
    bindParams(taskNode->rightChild, toReplace);
}

void traverse(struct ASTNode* node, unsigned long parent_type, bool insideFunction) {
    if(node == NULL) {
        return;
    }

    switch(node->val->type) {
        case no_type:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);
            
            break;
        case equals_to_parent:
            node->val->type = parent_type;
            traverse(node, node->val->type, insideFunction);

            if(DEBUG) {
                printf("Inherit parents type.\n");
            }
            break;
        case print_num:
            traverse(node->leftChild, node->val->type, insideFunction);

            if(DEBUG) {
                printf("print_num: %d\n", node->leftChild->val->intVal);
            }

            printf("%d\n", node->leftChild->val->intVal);

            break;
        case print_bool:
            traverse(node->leftChild, node->val->type, insideFunction);

            if(DEBUG) {
                printf("print_bool: %s\n", node->leftChild->val->boolVal ? "#t" : "#f");
            }

            printf("%s\n", node->leftChild->val->boolVal ? "#t" : "#f");

            break;
        case add:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->intVal = node->leftChild->val->intVal + node->rightChild->val->intVal;

            if(DEBUG) {
                printf("%d = %d + %d\n", node->val->intVal, node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            break;
        case sub:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->intVal = node->leftChild->val->intVal - node->rightChild->val->intVal;

            if(DEBUG) {
                printf("%d = %d - %d\n", node->val->intVal, node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            break;
        case mul:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->intVal = node->leftChild->val->intVal * node->rightChild->val->intVal;

            if(DEBUG) {
                printf("%d = %d * %d\n", node->val->intVal, node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            break;
        case div:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->intVal = node->leftChild->val->intVal / node->rightChild->val->intVal;

            if(DEBUG) {
                printf("%d = %d / %d\n", node->val->intVal, node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            break;
        case mod:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            if(DEBUG) {
                printf("%d = %d %% %d\n", node->val->intVal, node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            node->val->intVal = node->leftChild->val->intVal % node->rightChild->val->intVal;

            break;
        case bigger_than:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            if(DEBUG) {
                printf("%s = %d > %d\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            node->val->boolVal = node->leftChild->val->intVal > node->rightChild->val->intVal ? true : false;
            
            break;
        case smaller_than:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->boolVal = node->leftChild->val->intVal < node->rightChild->val->intVal ? true : false;
            
            if(DEBUG) {
                printf("%s = %d < %d\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->intVal, node->rightChild->val->intVal);
            }
            break;
        case equal:
            if(node->rightChild->val->type != equal || node->rightChild->val->type != equals_to_parent) {
                node->rightChild->val->boolVal = 1;
            }

            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);
            
            node->val->intVal = node->leftChild->val->intVal;
            node->val->boolVal = (node->leftChild->val->intVal == node->rightChild->val->intVal)*node->rightChild->val->boolVal ? true : false;

            if(DEBUG) {
                printf("%s = (%d == %d)*(%s)\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->intVal, node->rightChild->val->intVal, node->rightChild->val->boolVal ? "#t" : "#f");
            }
            break;
        case and:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            if(DEBUG) {
                printf("%s = %s && %s\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->boolVal ? "#t" : "#f", node->rightChild->val->boolVal ? "#t" : "#f");
            }
            node->val->boolVal = node->leftChild->val->boolVal && node->rightChild->val->boolVal;
            
            break;
        case or:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->boolVal = node->leftChild->val->boolVal || node->rightChild->val->boolVal;
            
            if(DEBUG) {
                printf("%s = %s || %s\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->boolVal ? "#t" : "#f", node->rightChild->val->boolVal ? "#t" : "#f");
            }
            break;
        case not:
            traverse(node->leftChild, node->val->type, insideFunction);

            node->val->boolVal = !node->leftChild->val->boolVal;
            
            if(DEBUG) {
                printf("%s = !%s\n", node->val->boolVal ? "#t" : "#f", node->leftChild->val->boolVal ? "#t" : "#f");
            }
            break;
        case define_variable:
            node->rightChild->val->name = node->leftChild->val->name;
            addDefinedVariable(node->rightChild);

            break;
        case get_variable: {
            /* If we use variable declartion in a case, we must use curly brackets {} in that case. */
            if(!insideFunction) {
                struct ASTNode* temp;

                temp = getDefinedVariable(node->val->name);

                node->val = temp->val;
                node->leftChild = temp->leftChild;
                node->rightChild = temp->rightChild;
                
                traverse(node, node->val->type, insideFunction);

                if(DEBUG) {
                    printf("Get variable: %s\n", node->val->name);
                }
            }
            break;
        }
        case define_function:
            addFunction(node->leftChild->val->name, node->rightChild);

            break;
        case define_inside_function:
            traverse(node->leftChild, node->val->type, insideFunction);
            traverse(node->rightChild, node->val->type, insideFunction);

            node->val->intVal = node->rightChild->val->intVal;
            node->val->boolVal = node->rightChild->val->boolVal;

            break;
        case call_function:
            if(node->leftChild->val->type == function) {
                assignParamsNameAndBind(node->leftChild->leftChild, node->rightChild, node->leftChild->rightChild);

                traverse(node->leftChild->rightChild, node->leftChild->val->type, true);

                node->val->intVal = node->leftChild->rightChild->val->intVal;
                node->val->boolVal = node->leftChild->rightChild->val->boolVal;
            } else if(node->leftChild->val->type == string) {
                struct Function* functionToCall = getFunction(node->leftChild->val->name);

                assignParamsNameAndBind(functionToCall->params, node->rightChild, functionToCall->task);

                traverse(functionToCall->task, functionToCall->task->val->type, true);

                node->val->intVal = functionToCall->task->val->intVal;
                node->val->boolVal = functionToCall->task->val->boolVal;
            }

            break;
        case if_else:
            traverse(node->leftChild, node->val->type, insideFunction);

            if(node->leftChild->val->boolVal) {
                traverse(node->rightChild->leftChild, node->rightChild->val->type, insideFunction);
                
                node->val->intVal = node->rightChild->leftChild->val->intVal;
                node->val->boolVal = node->rightChild->leftChild->val->boolVal;
            } else {
                traverse(node->rightChild->rightChild, node->rightChild->val->type, insideFunction);
                
                node->val->intVal = node->rightChild->rightChild->val->intVal;
                node->val->boolVal = node->rightChild->rightChild->val->boolVal;
            }

            break;

    }
}

void yyerror(const char *message) {
    fprintf(stderr, "%s\n", message);
}

void init() {
    definedVariablesTop = -1;
    definedFunctionsTop = -1;

    root = emptyNode();
}

int main() {
    init();
    yyparse();
    traverse(root, root->val->type, false);
    return 0;
}