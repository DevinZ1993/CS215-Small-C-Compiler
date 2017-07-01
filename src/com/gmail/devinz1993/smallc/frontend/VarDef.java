package com.gmail.devinz1993.smallc.frontend;

import java.util.List;

class VarDef extends ParseNode {
	
	public VarDef(Var var, Init init) {
		super(var, init);
	}
	
	public VarDef(Var var) {
		this(var, null);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		Var var = (Var) child;
		Init init = (Init) child.sibling;
		List<Integer> dimList = var.getDimList();
		if (!VarSymbol.put(var.toString(), dimList)) {
			throw new TypeError("name redefined: "+var, var.getLine(), var.getCol());
		} else if (null != init) {
			if (0 == dimList.size()) {
				if (!(init instanceof ExpInit)) {
					throw new TypeError(var+" is not an array", var.getLine(), var.getCol());
				} else {
					VarSymbol symbol = VarSymbol.get(var.toString());
					IRAddr src = ((Exp)init.child).getResult(out);
					out.writeAssign(src, IRAddr.getVar(symbol));
				}
			} else if (1 == dimList.size()) {
				if (!(init instanceof ArgInit)) {
					throw new TypeError(var+" is not an int", var.getLine(), var.getCol());
				} else {
					int argc = ((ArgInit)init).getArgc();
					if (dimList.get(0) < argc) {
						throw new TypeError("too many arguments for array initialization",
								var.getLine(), var.getCol());
					} else {
						VarSymbol symbol = VarSymbol.get(var.toString());
						List<Args> argLst = ((ArgInit)init).getArgs();
						for (int i=0; i<argLst.size(); i++) {
							IRAddr src = ((Exp)argLst.get(i).child).getResult(out);
							out.writeAssign(src, IRAddr.getVar(symbol, IRAddr.getCst(i)));
						}
					}
				}
			} else {
				if (init instanceof ExpInit) {
					throw new TypeError(var+" is not an int", var.getLine(), var.getCol());
				} else {
					throw new TypeError(var+" is not one-dimensional", 
							var.getLine(), var.getCol());
				}
			}
		}
	}
	
}
