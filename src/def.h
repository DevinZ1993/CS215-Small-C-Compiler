/* Structs and Classes */
#ifndef _HEADER_H
#define _HEADER_H
#define MAX 65535
#define NUM 9967
#define BLK 128
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
using namespace std;

// NODE OF PARSE TREE
struct Node {
	char *data;		// yytext
	int prod;		// production rule
	Node *left,*right;
	Node (char *str,int p);
	~Node();
};

// ARRAY SIZE:
struct Size {
	int data;		// size of one dimension
	Size *next;		// for linked-list
	Size(int sz);
	~Size();
};

// VARIABLE (ARRAY):
struct Var {
	char *scope;	// "<lbl_list><funct>"; "" for global
	char *tag;		// "?"; "<strt>" for flds; "#<pos>" for paras
	char *id;		// variable (array) or field identifier
	Size *size;		// linked-list of array sizes
	Var *next;		// for chaining-hash
	int addr;		// MIPS virtual address (data or stack)
	bool mem;		// whether stored in memory
	int reg;		// whether stored in regs
	Var();
	~Var();
	bool backUp() const;
};

// STRUCTURE FIELD:
struct Fld {
	char *name;		// field identifier
	Fld *next;		// for linked-list
	Fld(char *id);
	~Fld();
};

// STRUCTURE:
struct Strt {
	char *scope;	// "<lbl_list><funct>"; "" for global
	char *id;		// structure identifier
	Fld *fld;		// linked-list of fields
	Strt *next;		// for chaining-hash
	Strt();
	~Strt();
};

// FUNCTION:
struct Func {
	char *id;		// function identifier
	int argc;		// number of paras
	int spc;		// size of stack
	Func *next;		// for chaining-hash
	Func();
	~Func();
};

// HASHING FOR SYMBOL TABLE:
class Hash {
	Var varTbl[NUM];		// variables
	Strt strtTbl[NUM];		// structures
	Func funcTbl[NUM];		// functions
	int getIndex(char *id) const;
	void getVarSize(Size* sz,Node *var);
	void getStrtFld(Fld* fld,Node *sdefs);
	void getStrtFldHelp(Fld* &fld,Node *sdecs);
	void addStrtVarsHelp(Fld *fld,Node *vars);
	void getFuncParas(int &argc,Node *paras);
	void transArrs(Size *sz,Node *arrs,char *buf) const;
	bool testArgc(int argc,Node *args) const;
	void calArgs(char *id,int argc,Node *args) const;
public:
	void insVar(char *tag,char *id,Node *var=NULL);
	void insStrt(char *id,Node *sdecs,Node *vars);
	void addStrtVars(char *id,Node *vars);
	void insFunc(char *id,Node *paras);
	void setFuncSpc(char *id);
	void srchVar(char *tag,char *id,Node *arrs,char *idx) const;
	void srchFunc(char *id,Node *args,char *str) const;
	void callMain() const;
	int getStackSz(char *id) const;
	Var *search(char *tag,char *id) const;
};

// SCOPE DETERMINATION:
struct StrNode {
	char data[BLK];		// scope name
	StrNode *next;		// for linked-stack
	StrNode();
	~StrNode();
};
class StrStack {
	StrNode *head;
public:
	StrStack();
	~StrStack();
	void push(char *str);
	bool pop(char *str);
};

// REGISTER DESCRIPTOR:
struct Ref {
	Var *var;			// variable pointer
	Ref *next;			// for linked-list
	Ref(Ref *n=NULL);
	~Ref();
};
class Reg {
	int idx;		// register number
	Ref *ref;		// variables that it stores
	void insert(Var *var);
	bool remove(Var *var);
	void store(Var *var);
public:
	Reg();
	~Reg();
	void setIdx(int i);
	bool search(Var *var) const;
	bool empty() const;
	bool bestDst(Var *var) const;
	int getCost() const;
	void clearArrHelp(Var *var);
	void dstAct(Var *var);
	void load(Var *var);
	void spill();
	void clear(bool st);
	void showHelp();
};

#endif
