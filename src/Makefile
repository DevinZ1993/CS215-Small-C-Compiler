all: Parser Symbols Lexer

DEST=com/gmail/devinz1993/smallc/frontend
LIB=../lib

Parser: smallc.grm 
	java -jar ${LIB}/java-cup-11a.jar -parser Parser -symbols Symbols -interface < smallc.grm -destdir ${DEST}

Symbols: smallc.grm
	java -jar ${LIB}/java-cup-11a.jar -parser Parser -symbols Symbols -interface < smallc.grm -destdir ${DEST}

Lexer: smallc.lex
	java -cp ${LIB}/JFlex.jar JFlex.Main smallc.lex -d ${DEST}
	rm -f ${DEST}/*~

clean:
	rm -rf ${DEST}/Parser.java* ${DEST}/Symbols.java* ${DEST}/Lexer.java*
