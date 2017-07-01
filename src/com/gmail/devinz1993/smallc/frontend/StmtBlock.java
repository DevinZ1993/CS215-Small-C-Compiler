package com.gmail.devinz1993.smallc.frontend;

class StmtBlock extends ParseNode {

	private static ParseNode genEmptyDefs() {
		return new ParseNode();
	}
	
	public StmtBlock(Defs defs, Stmts stmts) {
		super(null==defs? genEmptyDefs():defs, stmts);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		VarSymbol.enterBlock();
		StructSymbol.enterBlock();
		if (child instanceof Defs) {
			((Defs)child).genIRCode(out);
		}
		if (null != child.sibling) {
			((Stmts)child.sibling).genIRCode(out);
		}
		StructSymbol.leaveBlock();
		VarSymbol.leaveBlock();
	}
	
	public void genIRCodeInFunc(IRWriter out) throws TypeError {
		StructSymbol.enterBlock();
		if (child instanceof Defs) {
			((Defs)child).genIRCode(out);
		}
		if (null != child.sibling) {
			((Stmts)child.sibling).genIRCode(out);
		}
		StructSymbol.leaveBlock();
	}
	
}
