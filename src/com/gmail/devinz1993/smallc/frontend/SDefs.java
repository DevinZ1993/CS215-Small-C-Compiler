package com.gmail.devinz1993.smallc.frontend;

class SDefs extends ParseNode {

	public SDefs(SDecs sDecs, SDefs sDefs) {
		super(sDecs, sDefs);
	}
	
	public void buildStructSymbol(StructSymbol symbol) throws TypeError {
		((SDecs)child).buildStructSymbol(symbol);
		if (null != child.sibling) {
			((SDefs)child.sibling).buildStructSymbol(symbol);
		}
	}
	
}
