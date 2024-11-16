%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function declarations
void yyerror(const char *s);
int yylex(void);

void emit(const char *code) {
    printf("%s",code);
}


%}

%union {
    char *str;
    int intval;
}

%token <str> VARIABLE
%token <str> DEF IF ELSE WHILE FOR RETURN BREAK CONTINUE PRINT
%token <str> STRING
%token <intval> NUMBER
%token EQUALS ASSIGN NOT_EQUALS LESS_THAN LESS_EQUAL GREATER_THAN GREATER_EQUAL
%left PLUS MINUS MULT DIVIDE
%token LPAREN RPAREN LBRACE RBRACE COLON COMMA
%token NEWLINE
%type <str> expression term program  statement 

%%

program:
    statement NEWLINE program
    |
    statement NEWLINE
    |
    statement
    /* empty */
    ;

statement:
    PRINT LPAREN expression RPAREN
    {
        char buffer[1024];
        snprintf(buffer, sizeof(buffer), "%s", $3);
        emit("console.log(");
        emit(buffer); // Expression to print
        emit(");\n");
        $$ = ""; // Return an empty string

    }
    | VARIABLE ASSIGN expression
    {
        char buffer[128];
        snprintf(buffer, sizeof(buffer), "let %s = %s;\n", $1, $3);
        emit(buffer);
        $$ = "";
    }
    ;

expression:
    expression PLUS term
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "%s + %s", $1, $3);
    }
    | expression MINUS term
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "%s - %s", $1, $3);
    }
    | term
    {
        $$ = $1;
    }
    ;

term:
    term MULT term
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "%s * %s", $1, $3);
    }
    | term DIVIDE term
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "%s / %s", $1, $3);
    }
    | NUMBER
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "%d", $1);
    }
    | LPAREN expression RPAREN
    {
        $$ = malloc(128);
        snprintf($$, sizeof($$), "(%s", $2);
        strcat($$,")");
    }
    |
    VARIABLE 
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    /* printf("Enter your program (end with Ctrl+D):\n"); */
    return yyparse();
}
