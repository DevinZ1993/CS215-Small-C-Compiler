package com.gmail.devinz1993.smallc.frontend;

class ExtDefs extends ParseNode {

	public ExtDefs(ExtDef extDef, ExtDefs extDefs) {
		super(extDef, extDefs);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((ExtDef)child).genIRCode(out);
		if (null != child.sibling) {
			((ExtDefs)child.sibling).genIRCode(out);
		}
	}
	
}
