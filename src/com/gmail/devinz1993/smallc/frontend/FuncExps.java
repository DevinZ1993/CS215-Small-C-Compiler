package com.gmail.devinz1993.smallc.frontend;

class FuncExps extends Exps {
	
	public FuncExps(IDNode id, Args args) {
		super(id, args);
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		IRAddr dest = IRAddr.getVar(new VarSymbol());
		genIRCode(out, dest);
		return dest;
	}
	
	public void genIRCode(IRWriter out, IRAddr dest) throws TypeError {
		IDNode id = (IDNode) child;
		Args args = (Args) child.sibling;
		int argc = args.getArgc();
		if (!FuncSymbol.contains(id.text, argc)) {
			throw new TypeError("undefined function: "+funcSign(id.text, argc), 
					id.line, id.col);
		} else if (id.text.equals("read") && 1 == argc) {
			if (args.child.child instanceof LvalExps) {
				out.writeInput(args.getResult(out));
			} else {
				throw new TypeError("non-lval cannot take an input", id.line, id.col);
			}
		} else if (id.text.equals("write") && 1 == argc) {
			out.writeOutput(args.getResult(out));
		} else {
			IRAddr[] exps = new IRAddr[argc];
			for (int i=0; i<argc; i++) {
				exps[i] = args.getResult(out);
				args = (Args)args.child.sibling;
			}
			out.writeCall(id.text, argc);
			for (int i=0; i<argc; i++) {
				out.writeArgv(exps[i]);
			}
			if (null != dest) {
				out.writeRetv(dest);
			}
		}
	}
	
	private static String funcSign(String funcName, int argc) {
		if (0 == argc) {
			return funcName+"()";
		} else {
			StringBuffer sb = new StringBuffer(funcName+"(int");
			for (int i=1; i<argc; i++) {
				sb.append(",int");
			}
			sb.append(")");
			return sb.toString();
		}
	}
	
}
