package com.gmail.devinz1993.smallc.frontend;

abstract class LvalExps extends Exps {
	
	public LvalExps(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
	public void genIRCode(IRWriter out, IRAddr dest) throws TypeError {
		if (null != dest) {
			out.writeAssign(getResult(out), dest);
		}
	}
	
}

class ArrExps extends LvalExps {
	
	public ArrExps(IDNode id, Arrs arrs) {
		super(id, arrs);
	}

	public IRAddr getResult(IRWriter out) throws TypeError {
		IDNode id = (IDNode) child;
		VarSymbol symbol = VarSymbol.get(id.text);
		if (null == symbol) {
			throw new TypeError("undefined variable: "+id.text, id.line, id.col);
		} else if (!Arrs.typecheck((Arrs)child.sibling, symbol.dims.length)) {
			throw new TypeError("array shape mismatched: "+id.text, id.line, id.col);
		} else if (null == child.sibling) {
			return IRAddr.getVar(symbol);
		} else {
			IRAddr offset = ((Arrs)child.sibling).getResult(out, symbol.dims, 0);
			return IRAddr.getVar(symbol, offset);
		}
	}
	
}

class DotExps extends LvalExps {
	
	public DotExps(IDNode strt, IDNode field) {
		super(strt, field);
	}

	public IRAddr getResult(IRWriter out) throws TypeError {
		IDNode field = (IDNode) child.sibling;
		VarSymbol symbol = VarSymbol.get(toString());
		if (null == symbol) {
			throw new TypeError("undefined field: "+this, field.line, field.col);
		} else {
			return IRAddr.getVar(symbol);
		}
	}
	
	@Override public String toString() {
		return ((IDNode)child).text+"."+((IDNode)child.sibling).text;
	}
	
}
