package com.gmail.devinz1993.smallc.frontend;

abstract class Defs extends ParseNode {

	public Defs(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
	public abstract void genIRCode(IRWriter out) throws TypeError;
	
}

class VarDefs extends Defs {
	
	public VarDefs(Decs decs, Defs defs) {
		super(decs, defs);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((Decs)child).genIRCode(out);
		if (null != child.sibling) {
			((Defs)child.sibling).genIRCode(out);
		}
	}
	
}

class StructDefs extends Defs {
	
	public StructDefs(StSpec stSpec, SDecs sDecs, Defs defs) {
		super(stSpec, sDecs, defs);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		StructSymbol symbol = ((StSpec)child).genIRCode(out);
		((SDecs)child.sibling).addStructFields(out, symbol);
		if (null != child.sibling.sibling) {
			((Defs)child.sibling.sibling).genIRCode(out);
		}
	}
}
