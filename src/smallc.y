/* Parser and Code Generator */
%{
#include "./src/def.h"
extern int yychar,lineCnt;
extern char *yytext; 
extern FILE *yyin;
///////// GLOBAL VARIABLES ////////
ifstream fin;		// File Reader
ofstream fout;		// File Writer
Node *root = NULL;	// Parse Tree Root
Hash tbl;	        // Symbol Table Object
char scp[BLK];		// current scope
int nymHelp = 0;	// help to generate a tmp var
int lblHelp = 0;	// help to generate a label
int addrLocal = 0;	// help to calculate local/global address
int addrGlobal = 0;	// help to record local address
Reg regfile[32];	// 32 Reg objects in MIPS
int regUsed = 0;	// registers used in a three-addr expression
Var *arrHelp[3];	// sentinel Var pointers for array variables
int arrFlag = 0;	// state of arrHelp
const char* regname[32] = {"$zero","$at","$v0","$v1","$a0","$a1","$a2","$a3",
							"$t0","$t1","$t2","$t3","$t4","$t5","$t6","$t7",
							"$s0","$s1","$s2","$s3","$s4","$s5","$s6","$s7",
							"$t8","$t9","$k0","$k1","$gp","$sp","$fp","$ra"};
//////// FUNCTION DECLARATIONS ////////
int yylex();
static void print_tok();
void yyerror(const char *s);
void transError(char *msg);
Node *trBuild(char *str,int num,Node* arr[],int p);
void show(Node *sub);
void newTmpVar(char *val);
bool getDst(char *dst);
void newLabel(char *buf);
char *getId(Node *sub);
int getInt(Node *sub);
void itoa(char *str,int val);
int atoi(char *str);
bool sameTag(char *a,char *b);
bool sameScp(char *a,char *b);
int ham(int num);
void translate();
void transExtDefs(Node *sub);
void transExtDef(Node *sub);
void transDefs(Node *sub);
void transVarDecs(Node *sub);
void transInit(Node *var,Node *init);
void transInitHelp(Node *args,char *id,int sz);
void transExp(Node *sub,char *dst);
void transExps(Node *sub,bool &cst,char *rev,int &val);
int cstHelp(int op,int val1,int val2=0);
bool transAtom(Node *sub,bool &cst,char *rev,int &val);
void transStspec(Node *stspec,Node *vars);
void transFunc(Node *func,Node *stmtBlk);
void transStmtBlk(Node *stmtBlk,char *preNext=NULL,char *preCont=NULL);
void transStmts(Node *stmts,char *preNext=NULL,char *preCont=NULL);
void transStmt(Node *sub,char *preNext=NULL,char *preCont=NULL);
void genCode();
void genStart();
void genCodeHelp();
void genInst(int argc,char *argv[]);
void genFuncCall(char *stackSize);
void genAssign(char *argv[]);
void genBinOp(char *argv[]);
void genUniOp(char *argv[]);
Var *getTerm(char *str);
int getVarReg(Var *var,bool dst);
void getCstReg(char *cst);
void issue(bool store,int idx,Var *var);
void descriptorClear(bool st);
void descriptorShow();
%}

%union			{ Node *node; };
%token <node>	INT TYPE STRUCT RETURN IF ELSE BREAK CONT FOR ID SEMI COMMA LC RC UNREC
				ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
				AND_ASSIGN NOR_ASSIGN OR_ASSIGN SR_ASSIGN SL_ASSIGN
				OR AND BIT_OR BIT_NOR BIT_AND EQ NE GT LT NLT NGT SL SR PLUS MINUS
				MULT DIV MOD NOT DOUBLE_PLUS DOUBLE_MINUS BIT_NOT DOT LP RP LB RB
%type <node>	PROGRAM EXTDEFS EXTDEF SEXTVARS EXTVARS STSPEC FUNC PARAS STMTBLOCK
				STMTS STMT DEFS SDEFS SDECS DECS VAR INIT EXP EXPS ARRS ARGS
%start 			PROGRAM
%nonassoc 		LOWER_THAN_ELSE
%nonassoc 		ELSE
%right			ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
				AND_ASSIGN NOR_ASSIGN OR_ASSIGN SR_ASSIGN SL_ASSIGN
%left			OR
%left 			AND
%left			BIT_OR
%left			BIT_NOR
%left			BIT_AND
%left			EQ NE
%left			GT LT NLT NGT
%left			SL SR
%left			PLUS MINUS
%left			MULT DIV MOD
%right			NOT DOUBLE_PLUS DOUBLE_MINUS BIT_NOT
%left			DOT LP RP LB RB
%%

PROGRAM: EXTDEFS {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"PROGRAM",1,arr,1);
		root = $$;
		}
		;

EXTDEFS: EXTDEF EXTDEFS {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXTDEFS",2,arr,1);
		}
		| {
		$$ = trBuild((char*)"EXTDEFS",0,NULL,2);
		}
		;
EXTDEF: TYPE EXTVARS SEMI {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXTDEF",3,arr,1);
		}
		| STSPEC SEXTVARS SEMI {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXTDEF",3,arr,2);
		}
		| TYPE FUNC STMTBLOCK {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXTDEF",3,arr,3);
		}
		;
SEXTVARS: ID COMMA SEXTVARS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"SEXTVARS",3,arr,1);
		}
		| ID {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"SEXTVARS",1,arr,2);
		}
		| {
		$$ = trBuild((char*)"SEXTVARS",0,NULL,3);
		}
		;
EXTVARS: VAR ASSIGN INIT COMMA EXTVARS {
		Node *arr[5] = {$1,$2,$3,$4,$5};
		$$ = trBuild((char*)"EXTVARS",5,arr,1);
		}
		| VAR COMMA EXTVARS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXTVARS",3,arr,2);
		}
		| VAR ASSIGN INIT {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXTVARS",3,arr,3);
		}
		| VAR {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"EXTVARS",1,arr,4);
		}
		| {
		$$ = trBuild((char*)"EXTVARS",0,NULL,5);
		}
		;
STSPEC: STRUCT ID LC SDEFS RC {
		Node *arr[5] = {$1,$2,$3,$4,$5};
		$$ = trBuild((char*)"STSPEC",5,arr,1);
		}
		| STRUCT LC SDEFS RC {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"STSPEC",4,arr,2);
		}
		| STRUCT ID {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"STSPEC",2,arr,3);
		}
		;
FUNC: ID LP PARAS RP {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"FUNC",4,arr,1);
		}
		;
PARAS: TYPE ID COMMA PARAS {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"PARAS",4,arr,1);
		}
		| TYPE ID {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"PARAS",2,arr,2);
		}
		| {
		$$ = trBuild((char*)"PARAS",0,NULL,3);
		}
		;
STMTBLOCK: LC DEFS STMTS RC {
		Node *arr[4];
		arr[0] = $1;
		arr[1] = $2;
		arr[2] = $3;
		arr[3] = $4;
		$$ = trBuild((char*)"STMTBLOCK",4,arr,1);
		}
		;
STMTS: STMT STMTS {
		Node *arr[2];
		arr[0] = $1;
		arr[1] = $2;
		$$ = trBuild((char*)"STMTS",2,arr,1);
		}
		| {
		$$ = trBuild((char*)"STMTS",0,NULL,2);
		}
		;
STMT: EXP SEMI {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"STMT",2,arr,1);
		}
		| STMTBLOCK {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"STMT",1,arr,2);
		}
		| RETURN EXP SEMI {
		Node *arr[3]={$1,$2,$3};
		$$ = trBuild((char*)"STMT",3,arr,3);
		}
		| IF LP EXP RP STMT ELSE STMT {
		Node *arr[7] = {$1,$2,$3,$4,$5,$6,$7};
		$$ = trBuild((char*)"STMT",7,arr,4);
		}
		| IF LP EXP RP STMT %prec LOWER_THAN_ELSE {
		Node *arr[5] = {$1,$2,$3,$4,$5};
		$$ = trBuild((char*)"STMT",5,arr,5);
		}
		| FOR LP EXP SEMI EXP SEMI EXP RP STMT {
		Node *arr[9] = {$1,$2,$3,$4,$5,$6,$7,$8,$9};
		$$ = trBuild((char*)"STMT",9,arr,6);
		}
		| CONT SEMI {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"STMT",2,arr,7);
		}
		| BREAK SEMI {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"STMT",2,arr,8);
		}
		;
DEFS: TYPE DECS SEMI DEFS {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"DEFS",4,arr,1);
		}
		| STSPEC SDECS SEMI DEFS {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"DEFS",4,arr,2);
		}
		| {
		$$ = trBuild((char*)"DEFS",0,NULL,3);
		}
		;
SDEFS: TYPE SDECS SEMI SDEFS {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"SDEFS",4,arr,1);
		}
		| {
		$$ = trBuild((char*)"SDEFS",0,NULL,2);
		}
		;
SDECS: ID COMMA SDECS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"SDECS",3,arr,1);
		}
		| ID {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"SDECS",1,arr,2);
		}
		;
DECS: VAR ASSIGN INIT COMMA DECS {
		Node *arr[5] = {$1,$2,$3,$4,$5};
		$$ = trBuild((char*)"DECS",5,arr,1);
		}
		| VAR COMMA DECS {
		Node *arr[3];
		arr[0] = $1;
		arr[1] = $2;
		arr[2] = $3;
		$$ = trBuild((char*)"DECS",3,arr,2);
		}
		| VAR ASSIGN INIT {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"DECS",3,arr,3);
		}
		| VAR {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"DECS",1,arr,4);
		}
		;
VAR: ID {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"VAR",1,arr,1);
		}
		| VAR LB INT RB {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"VAR",4,arr,2);
		}
		;
INIT: EXP {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"INIT",1,arr,1);
		}
		| LC ARGS RC {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"INIT",3,arr,2);
		}
		;
EXP: EXPS {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"EXP",1,arr,1);
		}
		| {
		$$ = trBuild((char*)"EXP",0,NULL,2);
		}
		;
EXPS: EXPS ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,1);
		}
		| EXPS PLUS_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,2);
		}
		| EXPS MINUS_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,3);
		}
		| EXPS MULT_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,4);
		}
		| EXPS DIV_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,5);
		}
		| EXPS MOD_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,6);
		} 
		| EXPS AND_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,7);
		}
		| EXPS NOR_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,8);
		}
		| EXPS OR_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,9);
		}
		| EXPS SR_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,10);
		}
		| EXPS SL_ASSIGN EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,11);
		}
		| EXPS OR EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,12);
		}
		| EXPS AND EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,13);
		}
		| EXPS BIT_OR EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,14);
		}
		| EXPS BIT_NOR EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,15);
		}
		| EXPS BIT_AND EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,16);
		}
		| EXPS NE EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,17);
		}
		| EXPS EQ EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,18);
		}
		| EXPS GT EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,19);
		}
		| EXPS LT EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,20);
		}
		| EXPS NGT EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,21);
		}
		| EXPS NLT EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,22);
		}
		| EXPS SL EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,23);
		}
		| EXPS SR EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,24);
		}
		| EXPS PLUS EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,25);
		}
		| EXPS MINUS EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,26);
		}
		| EXPS MULT EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,27);
		}
		| EXPS DIV EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,28);
		}
		| EXPS MOD EXPS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,29);
		}
		| DOUBLE_PLUS EXPS %prec NOT {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,30);
		}
		| DOUBLE_MINUS EXPS %prec NOT {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,31);
		}
		| MINUS EXPS %prec NOT {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,32);
		}
		| NOT EXPS %prec NOT {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,33);
		}
		| BIT_NOT EXPS %prec NOT {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,34);
		}
		| LP EXPS RP {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,35);
		}
		| ID LP ARGS RP {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"EXPS",4,arr,36);
		}
		| ID ARRS {
		Node *arr[2] = {$1,$2};
		$$ = trBuild((char*)"EXPS",2,arr,37);
		}
	 	| ID DOT ID {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"EXPS",3,arr,38);
		}
		| INT {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"EXPS",1,arr,39);
		}
		;
ARRS: LB EXP RB ARRS {
		Node *arr[4] = {$1,$2,$3,$4};
		$$ = trBuild((char*)"ARRS",4,arr,1);
		}
		| {
		$$ = trBuild((char*)"ARRS",0,NULL,2);
		}
		;
ARGS: EXP COMMA ARGS {
		Node *arr[3] = {$1,$2,$3};
		$$ = trBuild((char*)"ARGS",3,arr,1);
		}
		| EXP {
		Node *arr[1] = {$1};
		$$ = trBuild((char*)"ARGS",1,arr,2);
		}
		;
%%

int main(int argc,char **argv)
{
	++argv; --argc;
	if (argc>0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;
	if (!yyparse()) {
		translate();
		cout<<"\nParsing Complete\n";
		genCode();
	}
	return 0;
}

//////////////////////////////////
//		TOOLS FOR EASY WORK		//
//////////////////////////////////


//////// PARSING ERROR MESSAGES ////////

static void print_tok()
{
	if (yychar>=255)
		cerr<<"\""<<yytext<<"\""<<endl;
	else
		cerr<<"\""<<yychar<<"\""<<endl;
}

void yyerror(const char *s)
{
	cerr<<"["<<lineCnt<<"]Syntax Error:\t";
	print_tok();
}

void transError(char *msg)
{
	cerr<<"[EXCEPTION] "<<msg<<endl;
	cerr<<"Translation Terminated"<<endl;
    exit(1);
}


//////// Tree Building ////////


Node *trBuild(char *str,int num,Node* arr[],int p)
{
	Node *val = new Node(str,p);
	if (num>0) {
		val->left = arr[0];
		Node *itr = val->left;
		int i=1;
		for (;i<num;i++) {
			itr->right = arr[i];
			itr = itr->right;
		}
	}
	return val;
}

void show(Node *sub)
{
	if (sub==NULL) return;
	else if (sub->prod==0)
		cout<<sub->data<<' ';
	else if (sub->left!=NULL) {
		Node *itr = sub->left;
		while (itr!=NULL) {
			show(itr);
			itr = itr->right;
		}
	}
}


//////// Other Tools ////////

// Generate a Temporary Variable:
void newTmpVar(char *val)
{
	bzero(val,BLK);
	strcpy(val,"? @tmp_");
	itoa(val,nymHelp++);
	tbl.insVar((char*)"?",val+2,NULL);
}

// Generate a L-val of an EXP:
bool getDst(char *dst)
{
	if (!strlen(dst)) {
		newTmpVar(dst);
		return true;
	} else
		return false;
}

// Generate a New Label:
void newLabel(char *buf)
{
	bzero(buf,BLK);
	strcpy(buf,"Label_");
	itoa(buf,lblHelp++);
}

// Get Leftmost ID:
char *getId(Node *itr)
{
	while (itr->prod!=0)
		itr = itr->left;
	return itr->data;
}

// Test and Decode INT:
int getInt(Node *sub)
{
	int base, pos = 0, val = 0;
	char *str = sub->data;
	if (str[pos]=='0') {
		if (str[++pos]=='X'||str[pos]=='x') {
			base = 16; pos++;
		} else 
			base = 8;
	} else
		base = 10;
	for (;pos<strlen(str);pos++) {
		val *= base;
		if (str[pos]>='0'&&str[pos]<='9')
			val += str[pos]-'0';
		else if (str[pos]>='A'&&str[pos]<='F')
			val += str[pos]-'A'+10;
		else 
			val += str[pos]-'a'+10; 
		if (val<0)
			transError((char*)"INT out of Range");
	}
	return val;
}

// Convert int into char*
void itoa(char *str,int val)
{
	int tmp = val,len = 0;
	while (tmp>0) {
		tmp /= 10;
		len++;
	}
	int pos = strlen(str);
	if (len==0) str[pos] = '0';
	else for (int i=len-1;i>=0;i--) {
		str[pos+i] = (val%10)+'0';
		val /= 10;
	}
}

// Convert char* into int
int atoi(char *str)
{
	int val=0, pos=0;
	while (str[pos]>='0'&&str[pos]<='9')
		val = val*10+(str[pos++]-'0');
	return val;
}

// Whether of Same Tag:
bool sameTag(char *a,char *b)
{
	if (!strcmp(a,b))
		return true;
	else if (a[0]=='#'&&!strcmp(b,"?"))
		return true;
	else
		return false;
}

// Whether Valid in Current Scope:
bool sameScp(char *a,char *b)
{
	if (!strlen(a))
		return true;
	else if (!strcmp(a,b))
		return true;
	char *c = strstr(b,a);
	if (c!=NULL)
		return (*(c-1)=='@');
	else
		return false;
}

// Hamming Code of a Binary:
int ham(int num)
{
	num = (num&0x55555555)+((num>>1)&0x55555555);
	num = (num&0x33333333)+((num>>2)&0x33333333);
	num = (num&0x0F0F0F0F)+((num>>4)&0x0F0F0F0F);
	num = (num&0x00FF00FF)+((num>>8)&0x00FF00FF);
	num = (num&0x0000FFFF)+((num>>16)&0x0000FFFF);
	return num;
}


//////////////////////////////////////////
//		TRANSLATION BY TRAVERSAL		//
//////////////////////////////////////////


// Traverse PROGRAM:
void translate()
{
	fout.open("./output/InterCode");
    if (!fout) {
		cerr<<"Cannot open file \"";
        cerr<<"./output/InterCode\""<<endl;
        exit(0);
    }
	bzero(scp,BLK);
	transExtDefs(root->left);
    tbl.callMain();
	fout<<"_END_"<<endl;
	fout.close();
	delete root;
}

// Traverse EXTDEFS:
void transExtDefs(Node *sub)
{
	if (sub->prod==1) {
		transExtDef(sub->left);
		transExtDefs(sub->left->right);
	}
}

// Traverse EXTDEF:
void transExtDef(Node *sub)
{
	Node *sub1 = sub->left;
	Node *sub2 = sub1->right;
	Node *sub3 = sub2->right;
	if (sub->prod==1)
		transVarDecs(sub2);
	else if (sub->prod==2)
		transStspec(sub1,sub2);
	else if (sub->prod==3) 
		transFunc(sub2,sub3);
}

// Traverse DEFS:
void transDefs(Node *sub)
{
	if (sub->prod==1)
		transVarDecs(sub->left->right);
	else if (sub->prod==2)
		transStspec(sub->left,sub->left->right);
	if (sub->prod!=3)
		transDefs(sub->left->right->right->right);
}

// Traverse EXTVARS or DECS
void transVarDecs(Node *sub)
{
	if (sub->prod==5) return;
	else if (sub->prod%2==1)
		transInit(sub->left,sub->left->right->right);
	tbl.insVar((char*)"?",getId(sub),sub->left);
	if (sub->prod==1)
		transVarDecs(sub->left->right->right->right->right);
	else if (sub->prod==2)
		transVarDecs(sub->left->right->right);
}


// Traverse INIT:
void transInit(Node *var,Node *init)
{
	if (init->prod==1) {
		if (var->prod!=1) 
			transError((char*)"INIT Error");
		char dst[BLK];
		bzero(dst,BLK);
		strcat(dst,"? ");
		strcat(dst,getId(var));
		transExp(init->left,dst);
	} else {
		if (var->prod!=2||var->left->prod!=1)
			transError((char*)"INIT Error");
		char *id = getId(var);
		int sz = getInt(var->left->right->right);
		transInitHelp(init->left->right,id,sz);
	}
}

// Traverse ARGS in INIT:
void transInitHelp(Node *args,char *id,int sz)
{
//	to test: int arr[num] = {a1,a2,...,an};
	for (int i=0;i<sz;i++) {
		char dst[BLK];
		bzero(dst,BLK);
		strcat(dst,"? ");
		strcat(dst,id);
		strcat(dst," [");
		itoa(dst,i);
		strcat(dst,"]");
		transExp(args->left,dst);
		if (args->prod==1)
			args = args->left->right->right;
		else break;
	}
	if (args->prod==1)
		transError((char*)"INIT Error");
}

// Traverse EXP:
void transExp(Node *sub,char *dst)
{
//	if dst is decided:
//		generate an assignment statement
	if (sub->prod==1) {
		int val; bool cst;
		char rev[BLK];
		bzero(rev,BLK);
		transExps(sub->left,cst,rev,val);
		if (strlen(dst)) {
			if (cst)
				fout<<'\t'<<dst<<"\t=\t"<<val<<endl;
			else
				fout<<'\t'<<dst<<"\t=\t"<<rev<<endl;
		} else if (cst)
			itoa(dst,val);
		else
			strcpy(dst,rev);
	} else {
		getDst(dst);
		fout<<'\t'<<dst<<"\t=\t1"<<endl;
	}
}

// Traverse EXPS:
void transExps(Node *sub,bool &cst,char *rev,int &val)
{
//	decide cst according to production rule
// 	if cst is true:
//		val returns a constant
// 	else:
//		rev returns a variable
	bool cst1, cst2;
	int val1, val2;
	char x[BLK], y[BLK];
	bzero(x,BLK);
	bzero(y,BLK);
	if (sub->prod==1) {					// x = y
		transExps(sub->left->right->right,cst,rev,val);
		if (!transAtom(sub->left,cst1,x,val1))
			transError((char*)"L-val Error");
		if (cst)
			fout<<'\t'<<x<<"\t=\t"<<val<<endl;
		else
			fout<<'\t'<<x<<"\t=\t"<<rev<<endl;
	} else if (sub->prod<12) {			// x op= y
		transExps(sub->left->right->right,cst2,y,val2);
		if (!transAtom(sub->left,cst1,x,val1))
			transError((char*)"L-val Error");
		fout<<'\t'<<x<<"\t=\t"<<x<<'\t';
		char op[5];
		bzero(op,5);
		strcpy(op,sub->left->right->data);
		op[strlen(op)-1] = '\0';
		if (cst2)
			fout<<op<<'\t'<<val2<<endl;
		else
			fout<<op<<'\t'<<y<<endl;
		cst = false;	// otherwise l-val error
		strcpy(rev,x);
	} else if (sub->prod<30) {			// x op y
		transExps(sub->left,cst1,x,val1);
		transExps(sub->left->right->right,cst2,y,val2);
		if (cst1&&cst2) {
			cst = true;
			val = cstHelp(sub->prod,val1,val2);
		} else if (cst1) {
			cst = false;
			getDst(rev);
			fout<<'\t'<<rev<<"\t=\t"<<val1<<'\t';
			fout<<sub->left->right->data<<'\t'<<y<<endl;
		} else {
			cst = false;
			getDst(rev);
			fout<<'\t'<<rev<<"\t=\t"<<x<<'\t';
			if (cst2)
				fout<<sub->left->right->data<<'\t'<<val2<<endl;
			else
				fout<<sub->left->right->data<<'\t'<<y<<endl;
		}
	} else if (sub->prod<32) {			// ++x or --x
		Node *sub1 = sub->left->right;
		if (!transAtom(sub1,cst1,rev,val1))
			transError((char*)"L-val Error");//}
		cst = false; // otherwise l-val error
		fout<<'\t'<<rev<<"\t=\t"<<rev;
		if (sub->prod==30)
			fout<<"\t+\t1"<<endl;
		else
			fout<<"\t-\t1"<<endl;
	} else if (sub->prod<35) {			// op x
		transExps(sub->left->right,cst1,x,val1);
		if (cst1) {
			cst = true;
			val = cstHelp(sub->prod,val1);
		} else {
			cst = false;
			getDst(rev);
			fout<<'\t'<<rev<<"\t=\t";
			fout<<sub->left->data<<'\t'<<x<<endl;
		}
	} else if (sub->prod==35)           // (exps)
        transExps(sub->left->right,cst,rev,val);
    else								// atom
		transAtom(sub,cst,rev,val);
}

// Calculate Constant EXP:
int cstHelp(int op,int val1,int val2)
{
	switch (op) {
	case 2: return (val1+val2);
	case 3: return (val1-val2);
	case 4: return (val1*val2);
	case 5: return (val1/val2);
	case 6: return (val1%val2);
	case 7: return (val1&val2);
	case 8: return (val1^val2);
	case 9: return (val1|val2);
	case 10: return (val1>>val2);
	case 11: return (val1<<val2);
	case 12: return (val1||val2);
	case 13: return (val1&&val2);
	case 14: return (val1|val2);
	case 15: return (val1^val2);
	case 16: return (val1&val2);
	case 17: return (val1!=val2);
	case 18: return (val1==val2);
	case 19: return (val1>val2);
	case 20: return (val1<val2);
	case 21: return (val1<=val2);
	case 22: return (val1>=val2);
	case 23: return (val1<<val2);
	case 24: return (val1>>val2);
	case 25: return (val1+val2);
	case 26: return (val1-val2);
	case 27: return (val1*val2);
	case 28: return (val1/val2);
	case 29: return (val1%val2);
	case 30: return (val1+1);
	case 31: return (val1-1);
	case 32: return (-val1);
	case 33: return (!val1);
	case 34: return (~val1);
	}
}


// Translate Atoms of an Expression:
bool transAtom(Node *sub,bool &cst,char *rev,int &val)
{
//	the function will consult the Symbol Table to
//		identify variables, struct fields or functions
//		and return its name by an int or a string
//	the return value indicates whether it can be a l-val
// 	if EXPS is an INT:
//		cst is true, rev invalid, val returns the INT value
//	else:
//		cst is false, rev returns "<tag> <var>", val invalid
	bzero(rev,BLK);
	cst = false;
	if (sub->prod==39) {		// INT
		cst = true;
		val = getInt(sub->left);
		return false;
	} else if (sub->prod==38) {	// ID DOT ID
		char *tag = getId(sub->left);
		strcpy(rev,tag);
		strcat(rev," ");
		char *id = getId(sub->left->right->right);
		strcat(rev,id);
		tbl.srchVar(tag,id,NULL,NULL);
		return true;
	} else if (sub->prod==37) {	// ID ARRS
		strcpy(rev,(char*)"? ");
		char *id = getId(sub->left);
		strcat(rev,id);
		Node *arrs = sub->left->right;
		tbl.srchVar((char*)"?",id,arrs,rev);
		return true;
	} else if (sub->prod==36) {	// funct(ARGS)
		char *id = getId(sub);
		Node *args = sub->left->right->right;
		if (!strcmp(id,(char*)"read")) {
			if (args->prod!=2||args->left->prod==2)
				transError((char*)"ARGS Error");
			else if (!transAtom(args->left->left,cst,rev,val))
				transError((char*)"READ Error");
			else
				fout<<"\tread\t"<<rev<<endl;
		} else if (!strcmp(id,(char*)"write")) {
			if (args->prod!=2||args->left->prod==2)
				transError((char*)"ARGS Error");
			else {
				getDst(rev);
				transExp(args->left,rev);
				fout<<"\twrite\t"<<rev<<endl;
			}
		} else
			tbl.srchFunc(id,args,rev);
	} else
		return false;
}

// Traverse STSPEC & (SEXTVARS|SDECS):
void transStspec(Node *stspec,Node *vars)
{
	char id[BLK];
	bzero(id,BLK);
	if (stspec->prod==2)
		getDst(id);
	else
		strcpy(id,stspec->left->right->data);
	if (stspec->prod==1)
		tbl.insStrt(id,stspec->left->right->right->right,vars);
	else if (stspec->prod==2)
		tbl.insStrt(id,stspec->left->right->right,vars);
	else if (stspec->prod==3)
		tbl.addStrtVars(id,vars);
}

// Traverse FUNC:
void transFunc(Node *func,Node *stmtBlk)
{
// mark scope, calulate space and set labels
	char *id = getId(func);
	fout<<endl;
	if (strcmp(id,(char*)"main"))
		fout<<"\tgoto\t_"<<id<<endl;
	strcpy(scp,id);
	addrGlobal = addrLocal;
	addrLocal = 0;
	tbl.insFunc(id,func->left->right->right);
	fout<<id<<':'<<endl;
	transStmtBlk(stmtBlk);
	tbl.setFuncSpc(id);
	addrLocal = addrGlobal;
	fout<<"_"<<id<<":\n"<<endl;
	bzero(scp,BLK);
}


// Traverse STMTBLOCK:
void transStmtBlk(Node *stmtBlk,char *preNext,char *preCont)
{
	char scptmp[BLK];
	bzero(scptmp,BLK);
	strcpy(scptmp,scp);
	bzero(scp,BLK);
	strcpy(scp,(char*)"BLK_");
	itoa(scp,lblHelp++);
	strcat(scp,"@");
	strcat(scp,scptmp);
	fout<<'&'<<scp<<endl;
	transDefs(stmtBlk->left->right);
	transStmts(stmtBlk->left->right->right,preNext,preCont);
	fout<<'#'<<scp<<endl;
	strcpy(scp,scptmp);
}


// Traverse STMTS:
void transStmts(Node *stmts,char *preNext,char *preCont)
{
	if (stmts->prod==1) {
		transStmt(stmts->left,preNext,preCont);
		transStmts(stmts->left->right,preNext,preCont);
	}
}

// Traverse STMT:
void transStmt(Node *sub,char *preNext,char *preCont)
{
	switch (sub->prod) {
	case 1: {				// EXP SEMI
		char dst[BLK];
		bzero(dst,BLK);
		transExp(sub->left,dst);
		break;
	}
	case 2:					// STMTBLOCK
		transStmtBlk(sub->left,preNext,preCont);
		break;
	case 3: {				// RETURN EXP SEMI
		char dst[BLK];
		bzero(dst,BLK);
		getDst(dst);
		transExp(sub->left->right,dst);
		fout<<"\treturn\t"<<dst<<endl;
		break;
	}
	case 4: {				// IF LP EXP RP STMT ELSE STMT
		char dst[BLK],Else[BLK],Next[BLK],scpTmp[BLK];
		bzero(dst,BLK);
		getDst(dst);
		newLabel(Next);
		bzero(Else,BLK);
		strcpy(Else,Next);
		strcat(Next,"_NEXT");
		strcat(Else,"_ELSE");
		Node *tmp = sub->left->right->right;
        if (tmp->prod==2)
            transError((char*)"IF Condition Error");
		transExp(tmp,dst);
		fout<<"\tifFalse\t"<<dst<<"\tgoto\t"<<Else<<endl;
		tmp = tmp->right->right;
		transStmt(tmp,preNext,preCont);
		fout<<"\tgoto\t"<<Next<<endl;
		fout<<Else<<":\n";
		transStmt(tmp->right->right,preNext,preCont);
		fout<<Next<<":\n";
		break;
	}
	case 5: {				// IF LP EXP RP STMT
		char dst[BLK],Next[BLK],scpTmp[BLK];
		bzero(dst,BLK);
		getDst(dst);
		newLabel(Next);
		strcat(Next,"_NEXT");
		Node *tmp = sub->left->right->right;
        if (tmp->prod==2)
            transError((char*)"IF Condition Error");
		transExp(tmp,dst);
		fout<<"\tifFalse\t"<<dst<<"\tgoto\t"<<Next<<endl;
		transStmt(tmp->right->right,preNext,preCont);
		fout<<Next<<":\n";
		break;
	}
	case 6: {				// FOR LP EXP SEMI EXP SEMI EXP RP STMT
		char dst[BLK],For[BLK],Cont[BLK],Next[BLK],scpTmp[BLK];
		bzero(dst,BLK);
		newLabel(For);
		bzero(Next,BLK);
		strcpy(Next,For);
		bzero(Cont,BLK);
		strcpy(Cont,For);
		strcat(For,"_FOR");
		strcat(Next,"_NEXT");
		strcat(Cont,"_CONT");
		Node *tmp = sub->left->right->right;
		transExp(tmp,dst);
		fout<<For<<":\n";
		tmp = tmp->right->right;
		bzero(dst,BLK);
		getDst(dst);
		transExp(tmp,dst);
		fout<<"\tifFalse\t"<<dst<<"\tgoto\t"<<Next<<endl;
		tmp = tmp->right->right;
		transStmt(tmp->right->right,Next,Cont);
		fout<<Cont<<":\n";
		bzero(dst,BLK);
		transExp(tmp,dst);
		fout<<"\tgoto\t"<<For<<endl;
		fout<<Next<<":\n";
		break;
	}
	case 7:					// CONT SEMI
		if (preCont==NULL)
			transError((char*)"CONT Error");
		fout<<"\tgoto\t"<<preCont<<endl;
		break;
	case 8:					// BREAK SEMI
		if (preNext==NULL)
			transError((char*)"BREAK Error");
		fout<<"\tgoto\t"<<preNext<<endl;
	}
}


//////////////////////////////////////
//		MIPS CODE GENERATION		//
//////////////////////////////////////


// Entrance of Code Generation:
void genCode()
{
	fin.open("./output/InterCode");
	if (!fin) {
		cerr<<"Cannot open file \"";
        cerr<<"./output/InterCode\""<<endl;
        exit(2);
    }
	fout.open("./output/MIPSCode.s");
    if (!fout) {
		cerr<<"Cannot open file \"";
        cerr<<"./output/MIPSCode.s\""<<endl;
        exit(3);
    }
	genStart();
	bzero(scp,BLK);	// current scope reset
	// Var Pointer Sentinels Allocation:
	arrHelp[0] = new Var();
	arrHelp[0]->tag = new char[BLK];
	arrHelp[1] = new Var();
	arrHelp[1]->tag = new char[BLK];
	arrHelp[2] = new Var();
	arrHelp[2]->tag = new char[BLK];
	for (int i=0;i<32;i++)
		regfile[i].setIdx(i);
	genCodeHelp();
	// Var Pointer Sentinels Recycling:
	delete arrHelp[0];
	delete arrHelp[1];
	delete arrHelp[2];
	fout.close();
	fin.close();
}

// Start of the MIPS Code:
void genStart()
{
	fout<<"\t.data"<<endl;
	fout<<"GLB_VAR:"<<endl;
	fout<<"\t.space\t"<<(addrLocal+20)<<endl;
	fout<<"endL:"<<endl;
	fout<<"\t.asciiz\t\"\\n\""<<endl;
	fout<<"\t.text"<<endl;
	fout<<"\t.globl main"<<endl;
	fout<<"main:"<<endl;
}

// Scan Three-Address Instructions:
void genCodeHelp()
{
	char buffer[BLK];
	char scptmp[BLK];
	StrStack stack;
	bzero(buffer,BLK);
	char *inst[12];
	while (true) {	// one line per loop
		fin.getline(buffer,BLK);
		if (!strlen(buffer))
			fout<<endl;
		else if (!strcmp(buffer,(char*)"_END_"))
			break;
		else if (!strcmp(buffer,(char*)"main:")) {
			fout<<"_MAIN_STACK_POSITION:"<<endl;			
			fout<<"\tli\t$fp ,\t0x7ffffff8"<<endl;
			char cst[BLK];
			bzero(cst,BLK);
			itoa(cst,tbl.getStackSz((char*)"main"));
			getCstReg(cst);
			fout<<"\tsub\t$sp ,\t$fp ,\t"<<regname[25]<<endl;
			fout<<"_REAL_MAIN:"<<endl;
		} else if (buffer[0]=='#') {
			stack.pop(scp);
			fout<<"\t\t\t\t\t\t#"<<scp<<":\n";
		} else if (buffer[0]=='&') {
			stack.push(scp);
			bzero(scp,BLK);
			strcpy(scp,buffer+1);
			fout<<"\t\t\t\t\t\t#"<<scp<<":\n";
		} else if (!strncmp(buffer,(char*)"Label_",6)){
			descriptorClear(1);
			fout<<buffer<<endl;
		} else if (buffer[0]!='\t') {
			fout<<buffer<<endl;
		} else {
			int pos = 0;
			inst[pos] = strtok(buffer+1,"\t");
			while (inst[pos])
				inst[++pos] = strtok(NULL,"\t");
			genInst(pos,inst);
		}
	}
}

// Generate MIPS Instructions:
void genInst(int argc,char *argv[])
{
	char *tag=NULL,*id=NULL;
	if (!strcmp(argv[0],(char*)"goto")) {
	// Unconditional Jump:
		descriptorClear(1);
		fout<<"\tj\t"<<argv[1]<<endl;
	} else if (!strcmp(argv[0],(char*)"ifFalse")) {
	// Conditional Jump:
		int x = getVarReg(getTerm(argv[1]),0);
		descriptorClear(1);
		getCstReg((char*)"0");
		fout<<"\tbeq\t"<<regname[x]<<" ,\t";
		fout<<regname[25]<<" ,\t"<<argv[3]<<endl;
	} else if (!strcmp(argv[0],(char*)"read")) {
	// Function read(int &x)
		fout<<"\t\t\t#begin read "<<argv[1]<<endl;
		fout<<"\tli\t$v0 ,\t5"<<endl;
		fout<<"\tsyscall"<<endl;
		Var *var = getTerm(argv[1]);
		int z = getVarReg(var,1);
		fout<<"\tmove\t"<<regname[z]<<" ,\t$v0"<<endl;
		regfile[z].dstAct(var);
		fout<<"\t\t\t#end read "<<argv[1]<<endl;
	} else if (!strcmp(argv[0],(char*)"write")) {
	// Function write(int x)
		fout<<"\t\t\t#begin write "<<argv[1]<<endl;
		int x = getVarReg(getTerm(argv[1]),0);
		fout<<"\tmove\t$a0 ,\t"<<regname[x]<<endl;
		fout<<"\tli\t$v0 ,\t1"<<endl;
		fout<<"\tsyscall"<<endl;
		fout<<"\tli\t$v0 ,\t4"<<endl;
		fout<<"\tla\t$a0 ,\tendL"<<endl;
		fout<<"\tsyscall"<<endl;
		fout<<"\t\t\t#end write "<<argv[1]<<endl;
	} else if (!strcmp(argv[0],(char*)"_funct_call_"))
		genFuncCall(argv[1]);
	else if (argc==3&&!strcmp(argv[1],(char*)"="))
		genAssign(argv);
	else if (argc==4&&!strcmp(argv[1],(char*)"="))
		genUniOp(argv);
	else if (argc==5&&!strcmp(argv[1],(char*)"="))
		genBinOp(argv);
	else if (!strcmp(argv[0],(char*)"return")) {
	// Instruction RETURN VAR
		int x = getVarReg(getTerm(argv[1]),0);
		fout<<"\tmove\t$v0 ,\t"<<regname[x]<<endl;
		descriptorClear(1);
		fout<<"\tjr\t$ra"<<endl;
	}
}

// Issue a Function Call:
void genFuncCall(char *id)
{
	fout<<"\t\t\t#begin calling "<<id<<endl;
	// Store the Arguments:
	char inst[BLK];
	int cnt = 0;
	while (true) {
		bzero(inst,BLK);
		fin.getline(inst,BLK);
		if (strncmp(inst,(char*)"\tparam\t",7))
			break;
		else {	// deal with the (cnt)th argument
			int x = getVarReg(getTerm(inst+7),0);
			fout<<"\tsw\t"<<regname[x]<<" ,\t-";
			fout<<(4*(++cnt))<<"($sp)"<<endl;
		}
	}
	descriptorClear(1); 
	// store register $fp and $ra
	fout<<"\tsw\t$fp ,\t0($sp)"<<endl;
	fout<<"\tsw\t$ra ,\t4($sp)"<<endl;
	// move pointers $fp and $sp
	fout<<"\taddi\t$fp ,\t$sp ,\t-4"<<endl;
	int stackSize = tbl.getStackSz(id);
	char cst[BLK];
	bzero(cst,BLK);
	itoa(cst,stackSize);
	getCstReg(cst);
	fout<<"\tsub\t$sp ,\t$sp ,\t"<<regname[25]<<endl;
	// jump and link
	fout<<"\tjal\t"<<id<<endl;
	// restore $sp, $fp and $ra
	fout<<"\taddi\t$sp ,\t$fp ,\t4"<<endl;
	fout<<"\tlw\t$fp ,\t0($sp)"<<endl;
	fout<<"\tlw\t$ra ,\t4($sp)"<<endl;
	// Deal with the Return Value
	char *rev = strtok(inst+1,"\t");
	Var *var = getTerm(rev);
	int y = getVarReg(var,1);
	fout<<"\tmove\t"<<regname[y]<<" ,\t$v0\n";
	regfile[y].dstAct(var);
	fout<<"\t\t\t#end calling "<<id<<endl;
}

// Decode z = x op y:
void genBinOp(char *argv[])
{
	// Allocate Registers:
	int x,y,z;
	Var *a = getTerm(argv[2]);
	if (a!=NULL)
		x = getVarReg(a,0);
	else {
		getCstReg(argv[2]);
		x = 25;
	}
	regUsed |= (1<<x);
	Var *b = getTerm(argv[4]);
	if (b!=NULL)
		y = getVarReg(b,0);
	else {
		getCstReg(argv[4]);
		y = 25;
	}
	regUsed |= (1<<y);
	Var *c = getTerm(argv[0]);
	z = getVarReg(c,1);
	regUsed |= (1<<z);
	// Decode the Operator:
	char *op = argv[3];
	if (!strcmp(op,(char*)"||")
		||	!strcmp(op,(char*)"|"))
		fout<<"\tor\t";
	else if (!strcmp(op,(char*)"&&")
		||	!strcmp(op,(char*)"&"))
		fout<<"\tand\t";
	else if (!strcmp(op,(char*)"<<"))
		fout<<"\tsll\t";
	else if (!strcmp(op,(char*)">>"))
		fout<<"\tsrl\t";
	else if (!strcmp(op,(char*)"^"))
		fout<<"\txor\t";
	else if (!strcmp(op,(char*)"=="))
		fout<<"\tseq\t";
	else if (!strcmp(op,(char*)"!="))
		fout<<"\tsne\t";
	else if (!strcmp(op,(char*)"<"))
		fout<<"\tslt\t";
	else if (!strcmp(op,(char*)">"))
		fout<<"\tsgt\t";
	else if (!strcmp(op,(char*)"<="))
		fout<<"\tsle\t";
	else if (!strcmp(op,(char*)">="))
		fout<<"\tsge\t";
	else if (!strcmp(op,(char*)"+"))
		fout<<"\tadd\t";
	else if (!strcmp(op,(char*)"-"))
		fout<<"\tsub\t";
	else if (!strcmp(op,(char*)"*"))
		fout<<"\tmulo\t";
	else if (!strcmp(op,(char*)"/"))
		fout<<"\tdiv\t";
	else if (!strcmp(op,(char*)"%"))
		fout<<"\trem\t";
	else
		fout<<"\tBIN_OP\t";
	// Issue the Instruction
	fout<<regname[z]<<" ,\t";
	fout<<regname[x]<<" ,\t";
	fout<<regname[y]<<endl;
	regfile[x].clearArrHelp(a);
	regfile[y].clearArrHelp(b);
	regfile[z].dstAct(c);
}

// Decode z = op x:
void genUniOp(char *argv[])
{
	// Allocate Registers:
	int x,z;
	Var *a = getTerm(argv[3]);
	if (a!=NULL)
		x = getVarReg(a,0);
	else {
		getCstReg(argv[3]);
		x = 25;
	}
	regUsed |= (1<<x);
	Var *c = getTerm(argv[0]);
	z = getVarReg(c,1);
	regUsed |= (1<<z);
	// Decode the Operator:
	char *op = argv[2];
	if (!strcmp(op,(char*)"-"))
		fout<<"\tneg\t";
	else if (!strcmp(op,(char*)"~"))
		fout<<"\tnot\t";
	else if (strcmp(op,(char*)"!"))
		fout<<"\tUNI_OP\t";
	else {
		getCstReg((char*)"1");
		fout<<"\tsub\t"<<regname[z]<<" ,\t";
		fout<<regname[25]<<" ,\t"<<regname[x]<<endl;
		regfile[x].clearArrHelp(a);
		regfile[z].dstAct(c);
		return;
	}
	// Issue the Instruction:
	fout<<regname[z]<<" ,\t";
	fout<<regname[x]<<endl;
	regfile[x].clearArrHelp(a);
	regfile[z].dstAct(c);
}


// Decode z = x:
void genAssign(char *argv[])
{
	// Allocate Registers:
	int x,z;
	Var *rval = getTerm(argv[2]);
	if (rval!=NULL)
		x = getVarReg(rval,0);
	else {
		getCstReg(argv[2]);
		x = 25;
	}
	regUsed |= (1<<x);
	Var *lval = getTerm(argv[0]);
	z = getVarReg(lval,1);
	regUsed |= (1<<z);
	// Issue the Instruction:
	fout<<"\tmove\t"<<regname[z]<<" ,\t"<<regname[x]<<endl;
	regfile[x].clearArrHelp(rval);
	regfile[z].dstAct(lval);
}

// Decode an Operand String <tag id>:
Var *getTerm(char *str) {
// return tbl pointer for non-array vars
// return sentinel pointer for array vars
// return NULL for an immediate
	if (str[0]<0||str[0]>'9') {
		char buf[BLK];
		bzero(buf,BLK);
		strcpy(buf,str);
		char *tag = strtok(buf," ");
		char *id = strtok(NULL," ");
		char *arr = strtok(NULL,"]");
		if (arr==NULL)
			return tbl.search(tag,id);
		else {
			Var *base = tbl.search(tag,id);
			arrHelp[arrFlag]->scope = base->scope;
			bzero(arrHelp[arrFlag]->tag,BLK);
			arrHelp[arrFlag]->id = base->id;
			arrHelp[arrFlag]->addr = base->addr;
			if (arr[1]<'0'||arr[1]>'9')
				strcpy(arrHelp[arrFlag]->tag,arr);
			else
				arrHelp[arrFlag]->addr+=4*atoi(arr+1);
			arrHelp[arrFlag]->mem = true;
			arrHelp[arrFlag]->reg = 0;
			return arrHelp[arrFlag++];
		}
	} else
		return NULL;
}

// Get a Register for a Variable:
int getVarReg(Var *var,bool dst)
{
	if (!dst) {		// As a Src Operand:
		// a reg currently storing var
		for (int i=8;i<25;i++) {
			if (regfile[i].search(var))
				return i;
		}
		// get an empty register
		for (int i=8;i<25;i++) {
			if (regfile[i].empty()) {
				regfile[i].load(var);
				return i;
			}
		}
		// a reg that stores other values
		int min = MAX, pos = 0, cost;
		for (int i=8;i<25;i++) {
			if (regUsed&(1<<i))
				continue;
			cost = regfile[i].getCost();
			if (cost==0) {
				regfile[i].load(var);
				return i;
			} else if (cost<min) {
				min = cost;
				pos = i;
			}
		}
		regfile[pos].spill();
		regfile[pos].load(var);
		return pos;
	} else {		// As a Dst Operand:
		// a reg that is empty or only stores var
		for (int i=8;i<25;i++) {
			if (regfile[i].bestDst(var))
				return i;
		}
		// a reg that stores other values
		int min = MAX, pos = 0, cost;
		for (int i=8;i<25;i++) {
			if (regUsed&(1<<i))
				continue;
			cost = regfile[i].getCost();
			if (cost==0)
				return i;
			else if (cost<min) {
				min = cost;
				pos = i;
			}
		}
		regfile[pos].spill();
		return pos;
	} 
}

// Store an Immediate in $t9:
void getCstReg(char *cst)
{
	fout<<"\tli\t"<<regname[25];
	fout<<" ,\t"<<cst<<endl;
}

// Issue a SW or LW Instruction:
void issue(bool store,int idx,Var *var)
{
	if ((var==arrHelp[0]||var==arrHelp[1]
		||var==arrHelp[2])&&strlen(var->tag)) {
		// if address is not in var->addr:
		// 		get address in $t9
		char buf[BLK];
		bzero(buf,BLK);
		strcpy(buf,var->tag);
		char *tag = strtok(buf," ")+1;
		char *id = strtok(NULL," ");
		Var *idxVar = tbl.search(tag,id);
		int x = getVarReg(idxVar,0);
		// addr = 4*index+addrOfBase
		fout<<"\tsll\t"<<regname[25]<<" ,\t";
		fout<<regname[x]<<" ,\t2"<<endl;
		fout<<"\taddi\t"<<regname[25]<<" ,\t";
		fout<<regname[25]<<" ,\t"<<var->addr<<endl;
		if (!strlen(var->scope)) {	// data section
			if (store) 
				fout<<"\tsw\t";
			else
				fout<<"\tlw\t";
			fout<<regname[idx]<<" ,\tGLB_VAR(";
			fout<<regname[25]<<")\n";
		} else {					// stack
			fout<<"\tsub\t"<<regname[25]<<" ,\t$fp";
			fout<<" ,\t"<<regname[25]<<endl;
			if (store) 
				fout<<"\tsw\t";
			else
				fout<<"\tlw\t";
			fout<<regname[idx]<<" ,\t(";
			fout<<regname[25]<<")\n";
		}
	} else if (!strlen(var->scope)) {
		// Data Section Address in var->addr
		char cst[BLK];
		bzero(cst,BLK);
		itoa(cst,var->addr);
		getCstReg(cst);
		if (store) 
			fout<<"\tsw\t";
		else
			fout<<"\tlw\t";
		fout<<regname[idx]<<" ,\tGLB_VAR(";
		fout<<regname[25]<<")\n";
	} else {
		// Stack Address in var->addr
		if (store) 
			fout<<"\tsw\t";
		else
			fout<<"\tlw\t";
		fout<<regname[idx]<<" ,\t-";
		fout<<var->addr<<"($fp)\n";
	}
}

void descriptorClear(bool st)
{
	for (int i=8;i<25;i++)
		regfile[i].clear(st);
}

void descriptorShow()
{
	for (int i=8;i<25;i++) {
		cout<<regname[i]<<":\n";
		regfile[i].showHelp();
	}
}


//////////////////////////////////////////////
//		IMPLEMENTATION of 'header.h'		//
//////////////////////////////////////////////


//////// PARSE TREE NODE ////////


Node::Node(char *str,int p) {
	data = strdup(str);
	left = NULL;
	right = NULL;
	prod = p;
}

Node::~Node() {
	free(data);
	delete left;
	delete right;
}


//////// SYMBOL TABLE ELEMENTS ////////

Size::Size(int sz) {
	data = sz;
	next = NULL;
}

Size::~Size() {
	delete next;
}

Var::Var() {
	scope = NULL;
	tag = NULL;
	id = NULL;
	size = new Size(0);
	next = NULL;
	addr = 0;
	mem = true;
	reg = 0;
}

Var::~Var() {
	free(scope);
	free(tag);
	free(id);
	delete size;
	delete next;
}

bool Var::backUp() const {
	if (!mem)
		return (ham(reg)>1);
	else
		return true;
}

Fld::Fld(char *id) {
	name = strdup(id);
	next = NULL;
}

Fld::~Fld() {
	free(name);
	delete next;
}

Strt::Strt() {
	scope = NULL;
	id = NULL;
	fld = new Fld((char*)"");
	next = NULL;
}

Strt::~Strt() {
	free(scope);
	free(id);
	delete fld;
	delete next;
}

Func::Func() {
	id = NULL;
	argc = 0;
	spc = 0;
	next = NULL;
}

Func::~Func() {
	free(id);
	delete next;
}


//////// HASHING FOR SYMBOL TABLE ////////


// Hashing Function (division method):
int Hash::getIndex(char *id) const {
	int val = 0;
	for (int i=0;i<strlen(id);i++)
		val = (val*128+id[i])%NUM;
	return val;
}

// Insert a Variable If Declared:
void Hash::insVar(char *tag,char *id,Node *var) {
	int pos = getIndex(id);
	Var *itr = &varTbl[pos];
	while (itr->next!=NULL) {
		if (!strcmp(itr->next->scope,scp)
		&&  sameTag(itr->next->tag,tag)
		&&  !strcmp(itr->next->id,id))
			transError((char*)"Variable Redefined");
		itr = itr->next;
	}
	itr->next = new Var();
	itr = itr->next;
	itr->scope = strdup(scp);
	itr->tag = strdup(tag);
	itr->id = strdup(id);
	itr->addr = addrLocal;
	if (var!=NULL)
		getVarSize(itr->size,var);
	int tmp = 4;
	Size *sz = itr->size->next;
	while (sz!=NULL) {
		tmp *= sz->data;
		sz = sz->next;
	}
	addrLocal += tmp;
}

// Traverse VAR and Generate Size List:
void Hash::getVarSize(Size* sz,Node *var) {
	if (var->prod==2) {
		Size *tmp = new Size(getInt(var->left->right->right));
		tmp->next = sz->next;
        sz->next = tmp;
		getVarSize(sz,var->left);
	}
}

// Insert a Structure If Declared:
void Hash::insStrt(char *id,Node *sdefs,Node *vars) {
	int pos = getIndex(id);
	Strt *itr = &strtTbl[pos];
	while (itr->next!=NULL) {
		if (!strcmp(itr->next->scope,scp)
		&&  !strcmp(itr->next->id,id))
			transError((char*)"Structure Redefined");
		itr = itr->next;
	}
	itr->next = new Strt();
	itr = itr->next;
	itr->scope = strdup(scp);
	itr->id = strdup(id);
	getStrtFld(itr->fld,sdefs);
	addStrtVarsHelp(itr->fld,vars);
}

// Traverse SDEFS:
void Hash::getStrtFld(Fld* fld,Node *sdefs) {
	if (sdefs->prod==1) {
		getStrtFldHelp(fld,sdefs->left->right);
		getStrtFld(fld,sdefs->left->right->right->right);
	}
}

// Traverse SDECS and Generate Fld List:
void Hash::getStrtFldHelp(Fld* &fld,Node *sdecs) {
	fld->next = new Fld(getId(sdecs->left));
	fld = fld->next;
	if (sdecs->prod==1)
		getStrtFldHelp(fld,sdecs->left->right->right);
}

// Add Structure Variables:
void Hash::addStrtVars(char *id,Node *vars) {
	int pos = getIndex(id);
	Strt *itr = strtTbl[pos].next;
	while (itr!=NULL) {
		if (sameScp(itr->scope,scp)
		&&  !strcmp(itr->id,id)) {
			addStrtVarsHelp(itr->fld,vars);
			return;
		}
		itr = itr->next;
	}
	transError((char*)"Structure Undefined");
}

// Traverse SEXTVARS or SDECS:
void Hash::addStrtVarsHelp(Fld *fld,Node *vars) {
	if (vars->prod!=3) {
		char *tag = getId(vars);
		Fld *itr = fld->next;
		while (itr!=NULL) {
			insVar(tag,itr->name,NULL);
			itr = itr->next;
		}
		if (vars->prod!=2)
			addStrtVarsHelp(fld,vars->left->right->right);
	}
}

// Insert a Function If Declared:
void Hash::insFunc(char *id,Node *paras) {
	int pos = getIndex(id);
	Func *itr = &funcTbl[pos];
	while (itr->next!=NULL) {
		if (!strcmp(itr->next->id,id))
			transError((char*)"Function Redefined");
		itr = itr->next;
	}
	itr->next = new Func();
	itr = itr->next;
	itr->id = strdup(id);
	itr->argc = 0;
	if (paras!=NULL)
		getFuncParas(itr->argc,paras);
}

// Traverse PARAS and Add Parameters:
void Hash::getFuncParas(int &argc,Node *paras) {
	if (paras->prod!=3) {
		char buf[BLK];
		bzero(buf,BLK);
		buf[0] = '#';
		itoa(buf,argc++);
		insVar(buf,getId(paras->left->right),NULL);
		if (paras->prod!=2)
			getFuncParas(argc,paras->left->right->right->right);
	}
}

// Record Stack Size of a Function:
void Hash::setFuncSpc(char *id) {
	int pos = getIndex(id);
	Func *itr = funcTbl[pos].next;
	while (itr!=NULL) {
		if (!strcmp(itr->id,id)) {
			itr->spc = addrLocal;
			break;
		}
		itr = itr->next;
	}
}

// Idenitify Variables or Struct Fields:
void Hash::srchVar(char *tag,char *id,Node *arrs,char *idx) const {
//	when consulting struct fields or funct paras,
//		arrs==NULL, idx==NULL, no need to test ARRS
//	otherwise
//		test ARRS and append idx with index var/cst
	int pos = getIndex(id);
	Var *itr = varTbl[pos].next;
	while (itr!=NULL) {
		if (sameScp(itr->scope,scp)
		&&  sameTag(itr->tag,tag)
		&&  !strcmp(itr->id,id)) {
			if (arrs==NULL) return;
			else if (arrs->prod==2) {
				if (itr->size->next!=NULL)
					transError((char*)"ARRS Error");
				return;
			} else {
				if (itr->size->next==NULL)
					transError((char*)"ARRS Error");
				char buf[BLK];
                bzero(buf,BLK);
				Size *sz = itr->size->next->next;
				transArrs(sz,arrs,buf);
				strcat(idx,(char*)" [");
				strcat(idx,buf);
				strcat(idx,(char*)"]");
				return;
			}
		}
		itr = itr->next;
	}
	transError((char*)"Variable Undefined");
}

// Traverse and Test ARRS
void Hash::transArrs(Size *sz,Node *arrs,char *rev) const {
    bool cst, cst1;
    int val, val1;
    char rev1[BLK];
    // get EXP_0 as initial idx
    if (arrs->prod==2)
        transError((char*)"ARRS Error");
    Node *exp = arrs->left->right;
    if (exp->prod==2)
        transError((char*)"ARRS Error");
	transExps(exp->left,cst,rev,val);
	if (!cst) {
		char dst[BLK];
		bzero(dst,BLK);
		getDst(dst);
		fout<<'\t'<<dst<<"\t=\t"<<rev<<endl;
		strcpy(rev,dst);
	}
    arrs = exp->right->right;
    // idx = idx*SIZE_k+EXP_k (iterately)
    while (sz!=NULL) { 
        // multiplication: idx *= SIZE_k
        if (cst)
            val = val*(sz->data);
        else {
            fout<<'\t'<<rev<<"\t=\t"<<rev;
            fout<<"\t*\t"<<sz->data<<endl;
        }
        // get EXP_k in rev1 or val1
        if (arrs->prod==2)
            transError((char*)"ARRS Error");
        exp = arrs->left->right;
        if (exp->prod==2)
            transError((char*)"ARRS Error");
        bzero(rev1,BLK);
        transExps(exp->left,cst1,rev1,val1);
        // addition: idx += EXP_k
        if (cst&&cst1)
            val += val1;
        else if (cst){
            cst = false;
            strcpy(rev,rev1);
            fout<<'\t'<<rev<<"\t=\t"<<val;
            fout<<"\t+\t"<<rev1<<endl;
        } else {
            cst = false;
            fout<<'\t'<<rev<<"\t=\t"<<rev;
            if (cst1)
                fout<<"\t+\t"<<val1<<endl;
            else
                fout<<"\t+\t"<<rev1<<endl;
        }
        // for next loop
        arrs = exp->right->right;
        sz = sz->next;
    }
    if (arrs->prod!=2)
        transError((char*)"ARRS Error");
    if (cst)
        itoa(rev,val);
}

// Identify and Translate Function Call:
void Hash::srchFunc(char *id,Node *args,char *dst) const {
	int pos = getIndex(id);
	Func *itr = funcTbl[pos].next;
	while (itr!=NULL) {
		if (!strcmp(itr->id,id)) {
			if (!testArgc(itr->argc,args))
				transError((char*)"ARGS Error");
			else if (strcmp(id,(char*)"main")) {
				calArgs(itr->id,itr->argc,args);
				getDst(dst);
				fout<<'\t'<<dst<<"\t=\tcall\t"<<id;
				fout<<'\t'<<itr->argc<<endl;
			} else if (args->prod!=2||args->left->prod!=2)
				transError((char*)"ARGS Error");
			return;
		}
		itr = itr->next;
	}
	transError((char*)"Function Undefined");
}

// Traverse ARGS to Test Number of Arguments:
bool Hash::testArgc(int argc,Node *args) const {
	if (argc==0)
		return (args->prod==2 && args->left->prod==2);
	for (int i=0;i<argc-1;i++) {
		if (args->prod==2)
			return false;
		args = args->left->right->right;
	}
	return args->prod==2;
}

// Traverse ARGS to Translate Arguments:
void Hash::calArgs(char *id,int argc,Node *args) const {
	char buffer[30][BLK];
	for (int i=0;i<argc;i++) {
		bzero(buffer[i],BLK);
		getDst(buffer[i]);
		transExp(args->left,buffer[i]);
		if (args->prod!=2)
			args = args->left->right->right;
	}
	fout<<"\t_funct_call_\t"<<id<<endl;
	for (int i=0;i<argc;i++)
		fout<<"\tparam\t"<<buffer[i]<<endl;
}

// Test Whether Entrance Exists:
void Hash::callMain() const {
    char buf[BLK];
    bzero(buf,BLK);
    Node *args = new Node((char*)"ARGS",2);
    args->left = new Node((char*)"EXP",2);
    srchFunc((char*)"main",args,buf);
}

// Consult the Stack Size of a Function:
int Hash::getStackSz(char *id) const {
	int pos = getIndex(id);
	Func *itr = funcTbl[pos].next;
	while (itr!=NULL) {
		if (!strcmp(itr->id,id))
			break;
		itr = itr->next;
	}
	return itr->spc;
}

// Search a Variable in Code Generation:
Var *Hash::search(char *tag,char *id) const {
	int pos=getIndex(id),maxLen=-1,len;
	Var *itr=varTbl[pos].next, *rev=NULL;
	while (itr!=NULL) {
		len = strlen(itr->scope);
		if (sameScp(itr->scope,scp)
		&&  sameTag(itr->tag,tag)
		&&  !strcmp(itr->id,id)
		&&	len>maxLen) {
			rev = itr;
			maxLen = strlen(itr->scope);
		}
		itr = itr->next;
	}
	return rev;
}


//////// SCOPE DETERMINATION ////////


StrNode::StrNode() {
	bzero(data,BLK);
	next = NULL;
}

StrNode::~StrNode() {
	delete next;
}


StrStack::StrStack() {
	head = new StrNode();
}

StrStack::~StrStack() {
	delete head;
}

void StrStack::push(char *str) {
	StrNode *tmp = new StrNode();
	strcpy(tmp->data,str);
	tmp->next = head->next;
	head->next = tmp;
}

bool StrStack::pop(char *str) {
	if (head->next==NULL)
		return false;
	bzero(str,BLK);
	StrNode *tmp = head->next;
	strcpy(str,tmp->data);
	head->next = tmp->next;
	tmp->next = NULL;
	delete tmp;
	return true;
}


//////// REGISTER DESCRIPTOR ////////


Ref::Ref(Ref *n) {
	var = NULL;
	next = n;
}

Ref::~Ref() {
	var = NULL;
	delete next;
}

Reg::Reg() {
	ref = new Ref();
}

Reg::~Reg() {
	delete ref;
}

void Reg::setIdx(int i) {
	idx = i;
}

void Reg::insert(Var *var) {
	Ref *r = new Ref(ref->next);
	r->var = var;
	ref->next = r;
}

bool Reg::remove(Var *var) {
	Ref *itr = ref;
	while (itr->next!=NULL) {
		if (itr->next->var==var) {
			Ref *r = itr->next;
			itr->next = r->next;
			r->next = NULL;
			//delete r;
			return true;
		}
		itr = itr->next;
	}
	return false;
}

bool Reg::search(Var *var) const {
	Ref *itr = ref->next;
	while (itr!=NULL) {
		if (itr->var==var)
			return true;
		itr = itr->next;
	}
	return false;
}

// Whether It's Empty:
bool Reg::empty() const {
	if (idx<8||idx>24)
		return false;
	else
		return ref->next==NULL;
}

// Empty or Only Storing DstVar:
bool Reg::bestDst(Var *var) const {
	if (idx<8||idx>24)
		return false;
	else if (ref->next==NULL)
		return true;
	else if (ref->next->next==NULL)
		return ref->next->var==var;
	else
		return false;
}

//
int Reg::getCost() const {
	int cost = 0;
	Ref *itr = ref->next;
	while (itr!=NULL) {
		if (!itr->var->backUp())
			cost++;
		itr = itr->next;
	}
	return cost;
}

// Release src Sentinel Var Pointers:
void Reg::clearArrHelp(Var *var) {
	if (var==arrHelp[0]||var==arrHelp[1]||
		var==arrHelp[2])
		remove(var);
}

// Changes on Chosen as a DstReg:
void Reg::dstAct(Var *var) {
	// Other vars' Address Descriptor:
	Ref *itr = ref->next;
	while (itr!=NULL) {
		itr->var->reg &= (~(1<<idx));
		itr = itr->next;
	}
	// Modify the Register Descriptor:
	delete ref->next;
	ref->next = NULL;
	if (var==arrHelp[0]||var==arrHelp[1]
		||var==arrHelp[2])
		store(var);
	else
		insert(var);
	var->reg = (1<<idx);
	var->mem = false;
	// Modify global marks
	regUsed = 0;
	arrFlag = 0;
}

// Instruction: LW reg[idx], <var_addr>
void Reg::load(Var *var) {
	// Other vars' Address Descriptor:
	Ref *itr = ref->next;
	while (itr!=NULL) {
		itr->var->reg &= (~(1<<idx));
		itr = itr->next;
	}
	// Modify the Register Descriptor:
	delete ref->next;
	ref->next = NULL;
	insert(var);
	// var's Own Address Descritpor:
	var->reg |= (1<<idx);
	issue(0,idx,var);
}

// Instruction: SW reg[idx], <var_addr>
void Reg::store(Var *var) {
	// var's Address Descriptor:
	var->mem = true;
	issue(1,idx,var);
}

// Backup All Vars that It Stores:
void Reg::spill() {
	Ref *itr = ref->next;
	while (itr!=NULL) {
		if (!itr->var->backUp()) 
			store(itr->var);
		itr = itr->next;
	}
}

// Clear the Register Descriptor:
void Reg::clear(bool st) {
// 	write back vars if st==1
	Ref *itr = ref->next;
	while (st&&itr!=NULL) {
		if (!itr->var->mem)
			store(itr->var);
		itr->var->reg &= (~(1<<idx));
		itr = itr->next;
	}
	delete ref->next;
	ref->next = NULL;
}

void Reg::showHelp()
{
	Ref *itr = ref->next;
	while (itr!=NULL) {
		Var *var = itr->var;
		cout<<'\t'<<var->scope<<endl;
		cout<<'\t'<<var->tag<<endl;
		cout<<'\t'<<var->id<<endl;
		itr = itr->next;
	}
}


