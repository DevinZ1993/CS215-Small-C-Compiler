/* Lexical Analyzer */
%{
#include "./src/def.h"
#include "y.tab.h"
int lineCnt = 1;
%}

Dig	[0-9]
Int	{Dig}+|0[Xx][0-9A-Fa-f]+|0[0-7]+
Id	[_a-zA-Z][_a-zA-Z0-9]*
%%

{Int}	{
	yylval.node = new Node(yytext,0);
	return INT;
}
"int"	{
	yylval.node = new Node(yytext,0);
	return TYPE;
}
"struct"	{
	yylval.node = new Node(yytext,0);
	return STRUCT;
}
"return"	{
	yylval.node = new Node(yytext,0);
	return RETURN;
}
"if"	{
	yylval.node = new Node(yytext,0);
	return IF;
}
"else"	{
	yylval.node = new Node(yytext,0);
	return ELSE;
}
"break"	{
	yylval.node = new Node(yytext,0);
	return BREAK;
}
"continue"	{
	yylval.node = new Node(yytext,0);
	return CONT;
}
"for"	{
	yylval.node = new Node(yytext,0);
	return FOR;
}
{Id}	{
	yylval.node = new Node(yytext,0);
	return ID;
}
";"	{
	yylval.node = new Node(yytext,0);
	return SEMI;
}
","	{
	yylval.node = new Node(yytext,0);
	return COMMA;
}
"."	{
	yylval.node = new Node(yytext,0);
	return DOT;
}
"("	{
	yylval.node = new Node(yytext,0);
	return LP;
}
")"	{
	yylval.node = new Node(yytext,0);
	return RP;
}
"["	{
	yylval.node = new Node(yytext,0);
	return LB;
}
"]"	{
	yylval.node = new Node(yytext,0);
	return RB;
}
"{"	{
	yylval.node = new Node(yytext,0);
	return LC;
}
"}"	{
	yylval.node = new Node(yytext,0);
	return RC;
}
"!"	{
	yylval.node = new Node(yytext,0);
	return NOT;
}
"++"	{
	yylval.node = new Node(yytext,0);
	return DOUBLE_PLUS;
}
"--"	{
	yylval.node = new Node(yytext,0);
	return DOUBLE_MINUS;
}
"~"	{
	yylval.node = new Node(yytext,0);
	return BIT_NOT;
}
"*"	{
	yylval.node = new Node(yytext,0);
	return MULT;
}
"/"	{
	yylval.node = new Node(yytext,0);
	return DIV;
}
"%"	{
	yylval.node = new Node(yytext,0);
	return MOD;
}
"+"	{
	yylval.node = new Node(yytext,0);
	return PLUS;
}
"<<"	{
	yylval.node = new Node(yytext,0);
	return SL;
}
">>"	{
	yylval.node = new Node(yytext,0);
	return SR;
}
">"	{
	yylval.node = new Node(yytext,0);
	return GT;
}
"<"	{
	yylval.node = new Node(yytext,0);
	return LT;
}
">="	{
	yylval.node = new Node(yytext,0);
	return NLT;
}
"<="	{
	yylval.node = new Node(yytext,0);
	return NGT;
}
"=="	{
	yylval.node = new Node(yytext,0);
	return EQ;
}
"!="	{
	yylval.node = new Node(yytext,0);
	return NE;
}
"&"	{
	yylval.node = new Node(yytext,0);
	return BIT_AND;
}
"^"	{
	yylval.node = new Node(yytext,0);
	return BIT_NOR;
}
"|"	{
	yylval.node = new Node(yytext,0);
	return BIT_OR;
}
"&&"	{
	yylval.node = new Node(yytext,0);
	return AND;
}
"||"	{
	yylval.node = new Node(yytext,0);
	return OR;
}
"+="	{
	yylval.node = new Node(yytext,0);
	return PLUS_ASSIGN;
}
"-="	{
	yylval.node = new Node(yytext,0);
	return MINUS_ASSIGN;
}
"*="	{
	yylval.node = new Node(yytext,0);
	return MULT_ASSIGN;
}
"/="	{
	yylval.node = new Node(yytext,0);
	return DIV_ASSIGN;
}
"%="	{
	yylval.node = new Node(yytext,0);
	return MOD_ASSIGN;
}
"&="	{
	yylval.node = new Node(yytext,0);
	return AND_ASSIGN;
}
"^="	{
	yylval.node = new Node(yytext,0);
	return NOR_ASSIGN;
}
"|="	{
	yylval.node = new Node(yytext,0);
	return OR_ASSIGN;
}
"<<="	{
	yylval.node = new Node(yytext,0);
	return SR_ASSIGN;
}
">>="	{
	yylval.node = new Node(yytext,0);
	return SL_ASSIGN;
}
"-"	{
	yylval.node = new Node(yytext,0);
	return MINUS;
}
"="	{
	yylval.node = new Node(yytext,0);
	return ASSIGN;
}
[\n]	lineCnt++;
[ \t]+	/* eat up whitespace */
.	return UNREC;
%%

