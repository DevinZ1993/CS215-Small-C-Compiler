package com.gmail.devinz1993.smallc.frontend;

class SDecs extends ParseNode {

	public SDecs(IDNode id, SDecs sDecs) {
		super(id, sDecs);
	}
	
	public SDecs(IDNode id) {
		this(id, null);
	}
	
	@Override public String toString() {
		return ((IDNode)child).text;
	}
	
	public void buildStructSymbol(StructSymbol symbol) throws TypeError {
		if (!symbol.add(toString())) {
			IDNode id = (IDNode)child;
			throw new TypeError("field "+this+" redefined", id.line, id.col);
		}
		if (null != child.sibling) {
			((SDecs)child.sibling).buildStructSymbol(symbol);
		}
	}
	
	public void addStructFields(IRWriter out, StructSymbol symbol) throws TypeError {
		IDNode id = (IDNode) child;
		symbol.addVars(id.text, id.line, id.col);
		if (null != child.sibling) {
			((SDecs)child.sibling).addStructFields(out, symbol);
		}
	}
	
}
