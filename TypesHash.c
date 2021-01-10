#include <stdio.h>

const unsigned long hash(const char* str) {
    unsigned long hash = 888;  
    int c;

    while ((c = *str++))
        hash = ((hash << 8) + hash) + c;
    return hash;
}

int main() {
    char* types[27] = {
        "no_type",
        "equals_to_parent",
        "print_num",
        "print_bool",
        "if_else",
        "if_stmts",
        "define_variable",
        "get_variable",
        "define_function",
        "function",
        "function_parameters",
        "call_function",
        "define_inside_function",
        "integer",
        "string",
        "boolean",
        "add",   
        "sub",       
        "mul",      
        "div",  
        "mod",
        "bigger_than",     
        "smaller_than",    
        "equal",
        "and",
        "or",  
        "not",
    };

    for(int i = 0; i < 26; i++) {
        printf("%s: %lu\n", types[i], hash(types[i]));
    }
}