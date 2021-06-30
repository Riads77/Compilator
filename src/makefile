CC=gcc
CFLAGS=-Wall -g
LDFLAGS=-Wall -lfl
EXEC=as


all: $(EXEC) clean

$(EXEC): y.tab.o lex.yy.o abstract-tree.o decl-var.o
	$(CC) -o $@ $^ $(LDFLAGS)

$(EXEC).tab.c $(EXEC).tab.h: $(EXEC).y abstract-tree.h decl-var.h
	bison -d $(EXEC).y

lex.yy.c: $(EXEC).lex $(EXEC).tab.h abstract-tree.h
	flex $(EXEC).lex

decl-var.o: decl-var.c decl-var.h
	$(CC) -o $@ -c $< $(CFLAGS)

abstract-tree.o: abstract-tree.c abstract-tree.h
	$(CC) -o $@ -c $< $(CFLAGS)

y.tab.o: $(EXEC).tab.c
	$(CC) -o $@ -c $< $(CFLAGS)

lex.yy.o: lex.yy.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f lex.yy.* *.tab.* abstract-tree.o decl-var.o
