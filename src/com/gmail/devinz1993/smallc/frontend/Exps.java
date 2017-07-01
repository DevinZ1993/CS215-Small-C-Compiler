package com.gmail.devinz1993.smallc.frontend;

abstract class Exps extends ParseNode implements AbsExp {

	public Exps(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
}

class IntExps extends Exps {
	
	public IntExps(CstNode cst) {
		super(cst);
	}

	public IRAddr getResult(IRWriter out) throws TypeError {
		return IRAddr.getCst(((CstNode)child).value);
	}

	public void genIRCode(IRWriter out, IRAddr dest) throws TypeError {
		if (null != dest) {
			out.writeAssign(getResult(out), dest);
		}
	}
	
}

abstract class OpExps extends Exps {
	
	public OpExps(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
	public void genIRCode(IRWriter out, IRAddr dest) throws TypeError {
		if (null != dest) {
			out.writeAssign(getResult(out), dest);
		}
	}
	
	protected static IRAddr intToBool(IRWriter out, IRAddr intVal) {
		IRAddr bool = intVal.CST ? IRAddr.getCst((intVal.value!=0)? 1:0) 
				: IRAddr.getVar(new VarSymbol());
		if (!intVal.CST) {
			out.writeBinOpExp("sne", intVal, IRAddr.getCst(0), bool);
		}
		return bool;
	}
	
}
