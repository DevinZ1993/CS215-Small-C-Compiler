package com.gmail.devinz1993.smallc.frontend;

abstract class ExtDef extends ParseNode {

	public ExtDef(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
	public abstract void genIRCode(IRWriter out) throws TypeError;
	
}

class VarExtDef extends ExtDef {
	
	public VarExtDef(ExtVars extVars) {
		super(extVars);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((ExtVars)child).genIRCode(out);
	}
	
}

class StructExtDef extends ExtDef {
	
	public StructExtDef(StSpec stSpec, SExtVars sExtVars) {
		super(stSpec, sExtVars);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		StructSymbol symbol = ((StSpec)child).genIRCode(out);
		if (null != child.sibling) {
			((SExtVars)child.sibling).addStructFields(out, symbol);
		}
	}
	
}

class FuncExtDef extends ExtDef {
	
	public FuncExtDef(Func func, StmtBlock body) {
		super(func, body);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		Func func = (Func) child;
		if (!FuncSymbol.put(func.toString(), func.getArgc())) {
			IDNode id = (IDNode)func.child;
			throw new TypeError("function "+func+" redefined", id.line, id.col);
		} else {
			VarSymbol.enterFunc();
			out.enterFunc(func.toString());
			if (null != func.child.sibling) {
				((Paras)func.child.sibling).genIRCode(out);
			}
			((StmtBlock)child.sibling).genIRCodeInFunc(out);
			out.leaveFunc(func.toString());
			VarSymbol.leaveFunc();
			out.writeSpace("STACK", VarSymbol.getStackSpace());
		}
	}
	
}
