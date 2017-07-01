package com.gmail.devinz1993.smallc.frontend;

public class Program extends ParseNode {
	
	public Program(ExtDefs extDefs) {
		super(extDefs);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((ExtDefs)child).genIRCode(out);
		if (!FuncSymbol.contains("main", 0)) {
			throw new TypeError("no program entrance", -1, -1);
		} else {
			out.writeSpace("GLB_VAR", VarSymbol.getGlobalSize());
		}
	}
	
}
