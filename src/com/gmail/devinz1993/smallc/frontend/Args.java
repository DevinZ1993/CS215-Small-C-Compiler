package com.gmail.devinz1993.smallc.frontend;

class Args extends ParseNode {

	public Args(Exp exp, Args args) {
		super(exp, args);
	}
	
	public Args(Exp exp) {
		this(exp, null);
	}
	
	public int getArgc() {
		Exp exp = (Exp) child;
		if (null == exp) {
			return 0;
		} else {
			Args next = (Args) exp.sibling;
			if (null == next) {
				return 1;
			} else {
				return 1+next.getArgc();
			}
		}
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		return ((Exp)child).getResult(out);
	}
	
}
