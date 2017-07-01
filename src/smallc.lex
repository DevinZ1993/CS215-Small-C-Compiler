package com.gmail.devinz1993.smallc.frontend;

import java_cup.runtime.Symbol;

%%

%class Lexer
%unicode
%line
%column
%cup
%implements Symbols

%{  
    private Symbol symbol(int tag) {
        return new Symbol(tag, yyline, yycolumn);
    }
    private Symbol symbol(int tag, Object value) {
        return new Symbol(tag, yyline, yycolumn, value);
    }
%}

%eofval{
    if (yystate() == YYCOMMENT) {
        throw new ParseError("Comment mismatch, need */ at EOF.", yyline, yycolumn);
    }
    return symbol(EOF, null);
%eofval}

DecInt = 0|[1-9][0-9]*
OctInt = 0[0-7]+
HexInt = 0[Xx][0-9A-Fa-f]+
Identifier = [_a-zA-Z][_a-zA-Z0-9]*
LineTerm = \n|\r|\r\n
EOLComment = "//"[^\r\n]*{LineTerm}?
Whitespace = {LineTerm}|[ \t\f]

%yylexthrow{
	ParseError
%yylexthrow}

%state YYCOMMENT

%%

<YYINITIAL> {
    "int"           { return symbol(TYPE); }
    "struct"        { return symbol(STRUCT); }
    "return"        { return symbol(RETURN); }
    "if"            { return symbol(IF, new IDNode(yytext(), yyline, yycolumn)); }
    "else"          { return symbol(ELSE); }
    "break"         { return symbol(BREAK, new IDNode(yytext(), yyline, yycolumn)); }
    "continue"      { return symbol(CONT, new IDNode(yytext(), yyline, yycolumn)); }
    "for"           { return symbol(FOR); }
    {DecInt}    {
        return symbol(INT, new CstNode(Integer.valueOf(yytext()), yyline, yycolumn));
    }
    {OctInt}    {
        return symbol(INT, new CstNode(Integer.valueOf(yytext().substring(1), 8), yyline, yycolumn));
    }
    {HexInt}    {
        return symbol(INT, new CstNode(Integer.valueOf(yytext().substring(2), 16), yyline, yycolumn));
    }
    {Identifier}    {
        return symbol(ID, new IDNode(yytext(), yyline, yycolumn));
    }
    ";"             { return symbol(SEMI); }
    ","             { return symbol(COMMA); }
    "."             { return symbol(DOT); }
    "("             { return symbol(LP); }
    ")"             { return symbol(RP); }
    "["             { return symbol(LB); }
    "]"             { return symbol(RB); }
    "{"             { return symbol(LC); }
    "}"             { return symbol(RC); }
    "!"             { return symbol(NOT, new UniOp("!", yyline, yycolumn)); }
    "++"            { return symbol(DOUBLE_PLUS, new UniOp("++", yyline, yycolumn)); }
    "--"            { return symbol(DOUBLE_MINUS, new UniOp("--", yyline, yycolumn)); }
    "~"             { return symbol(BIT_NOT, new UniOp("~", yyline, yycolumn)); }
    "*"             { return symbol(MULT, new BinOp("*", yyline, yycolumn)); }
    "/"             { return symbol(DIV, new BinOp("/", yyline, yycolumn)); }
    "%"             { return symbol(MOD, new BinOp("%", yyline, yycolumn)); }
    "+"             { return symbol(PLUS, new BinOp("+", yyline, yycolumn)); }
    "<<"            { return symbol(SL, new BinOp("<<", yyline, yycolumn)); }
    ">>"            { return symbol(SR, new BinOp(">>", yyline, yycolumn)); }
    ">"             { return symbol(GT, new BinOp(">", yyline, yycolumn)); }
    "<"             { return symbol(LT, new BinOp("<", yyline, yycolumn)); }
    ">="            { return symbol(NLT, new BinOp(">=", yyline, yycolumn)); }
    "<="            { return symbol(NGT, new BinOp("<=", yyline, yycolumn)); }
    "=="            { return symbol(EQ, new BinOp("==", yyline, yycolumn)); }
    "!="            { return symbol(NE, new BinOp("!=", yyline, yycolumn)); }
    "&"             { return symbol(BIT_AND, new BinOp("&", yyline, yycolumn)); }
    "^"             { return symbol(BIT_XOR, new BinOp("^", yyline, yycolumn)); }
    "|"             { return symbol(BIT_OR, new BinOp("|", yyline, yycolumn)); }
    "&&"            { return symbol(AND, new BinOp("&&", yyline, yycolumn)); }
    "||"            { return symbol(OR, new BinOp("||", yyline, yycolumn)); }
    "+="            { return symbol(PLUS_ASSIGN, new OpAssign("+=", yyline, yycolumn)); }
    "-="            { return symbol(MINUS_ASSIGN, new OpAssign("-=", yyline, yycolumn)); }
    "*="            { return symbol(MULT_ASSIGN, new OpAssign("*=", yyline, yycolumn)); }
    "/="            { return symbol(DIV_ASSIGN, new OpAssign("/=", yyline, yycolumn)); }
    "%="            { return symbol(MOD_ASSIGN, new OpAssign("%=", yyline, yycolumn)); }
    "&="            { return symbol(AND_ASSIGN, new OpAssign("&=", yyline, yycolumn)); }
    "^="            { return symbol(XOR_ASSIGN, new OpAssign("^=", yyline, yycolumn)); }
    "|="            { return symbol(OR_ASSIGN, new OpAssign("|=", yyline, yycolumn)); }
    "<<="           { return symbol(SL_ASSIGN, new OpAssign("<<=", yyline, yycolumn)); }
    ">>="           { return symbol(SR_ASSIGN, new OpAssign(">>=", yyline, yycolumn)); }
    "-"             { return symbol(MINUS, new Term("-", yyline, yycolumn)); }
    "="             { return symbol(ASSIGN, new Assign("=", yyline, yycolumn)); }
    "/*"    { 
        yybegin(YYCOMMENT); 
    }
    "*/"    { 
        throw new ParseError("comment mismatch, extra '*/' found.", yyline, yycolumn); 
    }
    {LineTerm}		{}
    {EOLComment}	{}
    {Whitespace}	{}
    [^] { 
        throw new ParseError("illegal character '"+yychar+"'.", yyline, yycolumn);
    }
}

<YYCOMMENT> {
    "*/"    { 
        yybegin(YYINITIAL); 
    }
    [^]  {}
}

