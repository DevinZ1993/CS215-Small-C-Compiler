all: y.tab.o lex.yy.o
	g++ y.tab.o lex.yy.o  -ly -ll -o ./bin/scc
	rm lex.* y.tab.* y.output

y.tab.o: y.tab.c ./src/def.h
	g++ -c y.tab.c -o y.tab.o

lex.yy.o: ./src/def.h lex.yy.c
	g++ -c lex.yy.c -o lex.yy.o

lex.yy.c: ./src/smallc.l ./src/def.h
	flex ./src/smallc.l

y.tab.c y.tab.h: ./src/smallc.y ./src/def.h
	yacc ./src/smallc.y -v -d

clean:
	rm  output/* bin/* 
