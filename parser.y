%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 1024

//variable decl
int current_indent = 0;
int previous_indent = 0;

// Function declarations
void yyerror(const char *s);
int yylex(void);

void emit(const char *code) {
    printf("%s", code);
}

struct symbol {
    char name[128];
    int scope_id;
} sym_tbl[MAX];

int sym_count = 0;
int scope_count = 0;

int is_declared(char *name, int scope) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(sym_tbl[i].name, name) == 0 && sym_tbl[i].scope_id == scope) {
            return 1;
        }
    }
    return 0;
}

void declare(char *name, int scope) {
    strcpy(sym_tbl[sym_count].name, name);
    sym_tbl[sym_count].scope_id = scope;
    sym_count++;
}

%}

%union {
    char *str;
    int intval;
}

%token <str> VARIABLE
%token <str> DEF IF ELSE WHILE FOR RETURN BREAK CONTINUE PRINT IN RANGE
%token <str> STRING
%token <str> NUMBER
%token EQUALS ASSIGN NOT_EQUALS LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL
%left PLUS MINUS MULT DIVIDE
%token LPAREN RPAREN LBRACE RBRACE COLON COMMA
%token NEWLINE INDENT DEDENT
%type <str> expression term program statements statement print_statement assignment if_statement for_statement while_statement relop function_definition parameter_list

%%

program:
    statements {
        emit($1);
    }
    ;

statements:
    statement NEWLINE statements
    {
        char *buffer = malloc(strlen($1) + strlen($3) + 2);
        sprintf(buffer, "%s\n%s", $1, $3);
        $$ = buffer;
    }
    |
    statement NEWLINE
    {
        char *buffer = malloc(strlen($1) + 2);
        sprintf(buffer, "%s\n", $1);
        $$ = buffer;
    }
    |
    statement
    {
        $$ = $1;
    }
    | NEWLINE statements
    {
        char *buffer = malloc(strlen($2) + 1);
        sprintf(buffer, "\n%s", $2);
        $$ = buffer;
    }
    | NEWLINE
    {
        $$ = "\n";
    }
    // | block
    // {
    //     $$ = $1;
    // }
    ;

// block:
//     INDENT block DEDENT
//     {
//         $$ = $2;  // the statements inside the block
//     }
//     | INDENT statements
//     {
//         $$ = $2;
//     }
//     ;

statement:
    print_statement
    | assignment
    | if_statement
    | for_statement
    | while_statement
    | function_definition
    ;

print_statement:
    PRINT LPAREN expression RPAREN
    {
        char *buffer = malloc(strlen($3) + 15);
        sprintf(buffer, "console.log(%s);", $3);
        $$ = buffer;
    }
    ;

assignment:
    VARIABLE ASSIGN expression
    {
        char *buffer = malloc(strlen($1) + strlen($3) + 10);
        if (is_declared($1, 0) == 0) {
            declare($1, 0);
            sprintf(buffer, "let %s = %s;", $1, $3);
        } else {
            sprintf(buffer, "%s = %s;", $1, $3);
        }
        $$ = buffer;
    }
    ;

if_statement:
    IF expression COLON NEWLINE statements
    {
        char *buffer = malloc(strlen($2) + strlen($5) + 16);
        sprintf(buffer, "if (%s) {\n%s\n}\n", $2, $5);
        $$ = buffer;
    }
    | IF expression COLON NEWLINE statements ELSE COLON NEWLINE statements
    {
        char *buffer = malloc(strlen($2) + strlen($5) + strlen($9) + 32);
        sprintf(buffer, "if (%s) {\n%s}\nelse {\n%s}", $2, $5, $9);
        $$ = buffer;
    }
    ;

for_statement:
    FOR VARIABLE IN RANGE LPAREN NUMBER COMMA NUMBER RPAREN COLON NEWLINE statements
    {
        char *buffer = malloc(strlen($2) + strlen($6) + strlen($8) + strlen($12) + 32);
        sprintf(buffer, "for (let %s = %s; %s < %s; %s++) {\n%s\n}\n", $2, $6, $2, $8, $2, $12);
        $$ = buffer;
    }
    ;

while_statement:
    WHILE expression COLON NEWLINE statements
    {
        char *buffer = malloc(strlen($2) + strlen($5) + 16);
        sprintf(buffer, "while (%s) {\n%s\n}\n", $2, $5);
        $$ = buffer;
    }
    ;

function_definition:
    DEF VARIABLE LPAREN parameter_list RPAREN COLON NEWLINE statements
    {
        char *buffer = malloc(1024);
        sprintf(buffer, "function %s(%s) {\n%s}\n", $2, $4, $8);
        $$ = buffer;
    }
    ;

parameter_list:
    /* empty */
    {
        $$ = "";
    }
    | VARIABLE
    {
        $$ = strdup($1);
    }
    | parameter_list COMMA VARIABLE
    {
        $$ = malloc(strlen($1) + strlen($3) + 2);
        sprintf($$, "%s, %s", $1, $3);
    }
    ;

expression:
    expression PLUS term
    {
        $$ = malloc(strlen($1) + strlen($3) + 3);
        sprintf($$, "%s + %s", $1, $3);
    }
    | expression MINUS term
    {
        $$ = malloc(strlen($1) + strlen($3) + 3);
        sprintf($$, "%s - %s", $1, $3);
    }
    | expression relop expression
    {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 3);
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
    | term
    {
        $$ = $1;
    }
    ;

relop:
    EQUALS
    {
        $$ = "==";
    }
    | NOT_EQUALS
    {
        $$ = "!=";
    }
    | LESS_THAN
    {
        $$ = "<";
    }
    | LESS_EQUAL
    {
        $$ = "<=";
    }
    | GREATER_THAN
    {
        $$ = ">";
    }
    | GREATER_EQUAL
    {
        $$ = ">=";
    }
    ;

term:
    term MULT term
    {
        $$ = malloc(strlen($1) + strlen($3) + 3);
        sprintf($$, "%s * %s", $1, $3);
    }
    | term DIVIDE term
    {
        $$ = malloc(strlen($1) + strlen($3) + 3);
        sprintf($$, "%s / %s", $1, $3);
    }
    | NUMBER
    {
        $$ = malloc(16);
        snprintf($$, 16, "%s", $1);
    }
    | LPAREN expression RPAREN
    {
        $$ = malloc(strlen($2) + 3);
        sprintf($$, "(%s)", $2);
    }
    | VARIABLE
    {
        $$ = strdup($1);
    }
    | STRING
    {
        $$ = strdup($1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    return yyparse();
}
