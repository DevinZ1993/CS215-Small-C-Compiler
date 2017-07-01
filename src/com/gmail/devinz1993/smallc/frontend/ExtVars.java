package com.gmail.devinz1993.smallc.frontend;

public class ExtVars extends ParseNode {

	public ExtVars(VarDef varDef, ExtVars extVars) {
		super(varDef, extVars);
	}
	
	public ExtVars(VarDef varDef) {
		this(varDef, null);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((VarDef)child).genIRCode(out);
		if (null != child.sibling) {
			((ExtVars)child.sibling).genIRCode(out);
		}
	}
	
}

