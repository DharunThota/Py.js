all: parser

parser: parser.tab.c lex.yy.c
	gcc parser.tab.c lex.yy.c -o parser -lfl

lex.yy.c: tokenizer.l
	flex tokenizer.l

parser.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f parser lex.yy.c parser.tab.c parser.tab.h

run: parser
	./parser < test.py
