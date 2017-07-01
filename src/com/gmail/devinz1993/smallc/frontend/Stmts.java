package com.gmail.devinz1993.smallc.frontend;

class Stmts extends ParseNode {

	public Stmts(Stmt stmt, Stmts stmts) {
		super(stmt, stmts);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((Stmt)child).genIRCode(out);
		if (null != child.sibling) {
			((Stmts)child.sibling).genIRCode(out);
		}
	}
	
}
