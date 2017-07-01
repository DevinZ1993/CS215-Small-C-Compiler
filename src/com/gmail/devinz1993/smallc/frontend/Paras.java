package com.gmail.devinz1993.smallc.frontend;

public class Paras extends ParseNode {

	public Paras(IDNode id, Paras paras) {
		super(id, paras);
	}
	
	public Paras(IDNode id) {
		this(id, null);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		IDNode id = (IDNode)child;
		if (!VarSymbol.put(id.text)) {
			throw new TypeError("argument "+id.text+" redefined", id.line, id.col);
		}
		if (null != child.sibling) {
			((Paras)child.sibling).genIRCode(out);
		}
	}
	
}