package com.gmail.devinz1993.smallc.frontend;

class StSpec extends ParseNode {

	private static final IDNode ANOMNY = new IDNode("@", -1, -1);
	
	public StSpec(IDNode id, SDefs sDefs) {
		super(id, sDefs);
	}
	
	public StSpec(IDNode id) {
		this(id, null);
	}
	
	public StSpec(SDefs sDefs) {
		this(ANOMNY, sDefs);
	}
	
	public StructSymbol genIRCode(IRWriter out) throws TypeError {
		IDNode id = (IDNode) child;
		if (ANOMNY == id) {
			StructSymbol symbol = new StructSymbol();
			((SDefs)child.sibling).buildStructSymbol(symbol);
			return symbol;
		} else if (null != child.sibling) {
			if (!StructSymbol.put(id.text)) {
				throw new TypeError("struct "+id.text+" redefined", id.line, id.col);
			} else {
				StructSymbol symbol = StructSymbol.get(id.text);
				((SDefs)child.sibling).buildStructSymbol(symbol);
				return symbol;
			}
		} else {
			StructSymbol symbol = StructSymbol.get(id.text);
			if (null == symbol) {
				throw new TypeError("struct "+id.text+" undefined", id.line, id.col);
			} else {
				return symbol;
			}
		}
	}
	
}
