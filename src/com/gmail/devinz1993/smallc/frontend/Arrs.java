package com.gmail.devinz1993.smallc.frontend;

class Arrs extends ParseNode {

	public Arrs(Exp exp, Arrs arrs) {
		super(exp, arrs);
	}
	
	public IRAddr getResult(IRWriter out, int[] dims, int idx) 
			throws TypeError {
		
		IRAddr exp = ((Exp)child).getResult(out);
		if (null != child.sibling) {
			IRAddr dest = IRAddr.getVar(new VarSymbol());
			out.writeBinOpExp("mul", exp, IRAddr.getCst(dims[idx]), dest);
			IRAddr suffix = ((Arrs)child.sibling).getResult(out, dims, idx+1);
			out.writeBinOpExp("add", dest, suffix, dest);
			return dest;
		} else {
			return exp;
		}
		
	}
	
	public static boolean typecheck(Arrs arrs, int num) {
		if (null == arrs) {
			return 0 == num;
		} else {
			return typecheck((Arrs)arrs.child.sibling, num-1);
		}
	}
	
}
