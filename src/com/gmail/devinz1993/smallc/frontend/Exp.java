package com.gmail.devinz1993.smallc.frontend;

class Exp extends ParseNode implements AbsExp {

	public Exp(Exps exps) {
		super(exps);
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		return ((Exps)child).getResult(out);
	}
	
	public void genIRCode(IRWriter out, IRAddr dest) throws TypeError {
		if (null != dest) {
			out.writeAssign(getResult(out), dest);
		}
	}
	
}

interface AbsExp {
	
	void genIRCode(IRWriter out, IRAddr dest) throws TypeError;
	
	IRAddr getResult(IRWriter out) throws TypeError;
	
}
