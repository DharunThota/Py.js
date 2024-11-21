%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// For token storage
#include "parser.tab.h"

extern int current_indent;
extern int previous_indent;

void print_token(const char *token, const char *value) {
    printf("<%s, %s>\n", token, value);
}

// Undefine yywrap macro to avoid conflicts
#undef yywrap
%}


%%

\n              {  print_token("NEWLINE", "\\n"); previous_indent = current_indent; current_indent = 0 ; return NEWLINE; }
\r              { print_token("CARRIAGE RETURN", "\\r"); return NEWLINE; }
"def"           { print_token("KEYWORD", "def"); return DEF; }
"if"            { print_token("KEYWORD", "if"); return IF; }
"else"          { print_token("KEYWORD", "else"); return ELSE; }
"while"         { print_token("KEYWORD", "while"); return WHILE; }
"for"           { print_token("KEYWORD", "for"); return FOR; }
"in"            { print_token("KEYWORD", "in"); return IN; }
"range"         { print_token("KEYWORD", "range"); return RANGE; }
"return"        { print_token("KEYWORD", "return"); return RETURN; }
"break"         { print_token("KEYWORD", "break"); return BREAK; }
"continue"      { print_token("KEYWORD", "continue"); return CONTINUE; }
"print"         { print_token("KEYWORD", "print"); return PRINT; }

[a-zA-Z_][a-zA-Z0-9_]* {
    print_token("VARIABLE", yytext);
    yylval.str = strdup(yytext);
    return VARIABLE;
}

[0-9]+ {
    print_token("NUMBER", yytext);
    yylval.str = strdup(yytext);
    return NUMBER;
}

\"[^\"]*\" {
    print_token("STRING", yytext);
    yylval.str = strdup(yytext);
    return STRING;
}

"=="            { print_token("OPERATOR", "=="); return EQUALS; }
"="             { print_token("OPERATOR", "="); return ASSIGN; }
"!="            { print_token("OPERATOR", "!="); return NOT_EQUALS; }
"<"             { print_token("OPERATOR", "<"); return LESS_THAN; }
"<="            { print_token("OPERATOR", "<="); return LESS_EQUAL; }
">"             { print_token("OPERATOR", ">"); return GREATER_THAN; }
">="            { print_token("OPERATOR", ">="); return GREATER_EQUAL; }
"+"             { print_token("OPERATOR", "+"); return PLUS; }
"-"             { print_token("OPERATOR", "-"); return MINUS; }
"*"             { print_token("OPERATOR", "*"); return MULT; }
"/"             { print_token("OPERATOR", "/"); return DIVIDE; }

"("             { print_token("DELIMITER", "("); return LPAREN; }
")"             { print_token("DELIMITER", ")"); return RPAREN; }
"{"             { print_token("DELIMITER", "{"); return LBRACE; }
"}"             { print_token("DELIMITER", "}"); return RBRACE; }
":"             { print_token("DELIMITER", ":"); return COLON; }
","             { print_token("DELIMITER", ","); return COMMA; }

[ ] 			{print_token("SPACE", " ");}

[\t]+       {
	// current_indent = strlen(yytext);
    // printf("%d", current_indent);
	// if(current_indent > previous_indent) {
	// 	print_token("INDENT", yytext);
	// 	return INDENT;
	// } else if(current_indent < previous_indent) {
	// 	print_token("DEDENT", yytext);
	// 	return DEDENT;
	// }
}

"#"[^\n]*       { /* Ignore comments */ }

.               { printf("Unrecognized character: %s\n", yytext); }
%%

int yywrap(void) {
    return 1;
}
