package com.gmail.devinz1993.smallc.frontend;

class SExtVars extends ParseNode {

	public SExtVars(IDNode id, SExtVars sExtVars) {
		super(id, sExtVars);
	}
	
	public SExtVars(IDNode id) {
		this(id, null);
	}
	
	public void addStructFields(IRWriter out, StructSymbol symbol) throws TypeError {
		IDNode id = (IDNode) child;
		if (!VarSymbol.putName(id.text)) {
			throw new TypeError("name "+id.text+" redefined", id.line, id.col);
		}
		symbol.addVars(id.text, id.line, id.col);
		if (null != child.sibling) {
			((SExtVars)child.sibling).addStructFields(out, symbol);
		}
	}
	
}
