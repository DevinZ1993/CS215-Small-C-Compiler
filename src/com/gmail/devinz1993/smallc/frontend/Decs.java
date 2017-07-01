package com.gmail.devinz1993.smallc.frontend;

class Decs extends ParseNode {

	public Decs(VarDef varDef, Decs decs) {
		super(varDef, decs);
	}
	
	public Decs(VarDef varDef) {
		this(varDef, null);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((VarDef)child).genIRCode(out);
		if (null != child.sibling) {
			((Decs)child.sibling).genIRCode(out);
		}
	}
	
}
