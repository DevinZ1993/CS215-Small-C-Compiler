package com.gmail.devinz1993.smallc.frontend;

class Term extends ParseNode {

	public final String text;
	
	public final int line, col;
	
	public Term(String text, int line, int col) {
		this.text = text;
		this.line = line;
		this.col = col;
	}
	
}

class IDNode extends Term {
	
	public IDNode(String text, int line, int col) {
		super(text, line, col);
	}
	
}

class CstNode extends Term {
	
	public final int value;
	
	public CstNode(int value, int line, int col) {
		super(Integer.valueOf(value).toString(), line, col);
		this.value = value;
	}
	
}

class BinOp extends Term {
	
	public BinOp(String text, int line, int col) {
		super(text, line, col);
	}
	
}

class Assign extends Term {
	
	public Assign(String op, int line, int col) {
		super(op, line, col);
	}
	
}

class OpAssign extends Assign {
	
	public OpAssign(String text, int line, int col) {
		super(text, line, col);
	}
	
}

class UniOp extends Term {
	
	public UniOp(String text, int line, int col) {
		super(text, line, col);
	}
	
}
