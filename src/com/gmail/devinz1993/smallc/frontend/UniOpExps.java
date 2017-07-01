package com.gmail.devinz1993.smallc.frontend;

class UniOpExps extends OpExps {
	
	public UniOpExps(UniOp op, Exps exps) throws ParseError {
		super(op, exps);
		if ((op.equals("++") || op.equals("--")) && !(exps instanceof LvalExps)) {
			throw new ParseError("invalid operator: "+op.text, op.line, op.col);
		}
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		String op = ((UniOp)child).text;
		IRAddr src = ((Exps)child.sibling).getResult(out);
		if (src.CST) {
			if (op.equals("!")) {
				return IRAddr.getCst(~intToBool(out, src).value);
			} else if (op.equals("~")) {
				return IRAddr.getCst(~src.value);
			} else if (op.equals("-")) {
				return IRAddr.getCst(-src.value);
			}
			return null;
		} else {
			IRAddr dest = IRAddr.getVar(new VarSymbol());
			if (op.equals("!")) {
				out.writeBinOpExp("seq", src, IRAddr.getCst(0), dest);
			} else if (op.equals("~")) {
				out.writeUniOpExp("not", src, dest);
			} else if (op.equals("-")) {
				out.writeUniOpExp("neg", src, dest);
			} else if (op.equals("++")) {
				out.writeBinOpExp("add", src, IRAddr.getCst(1), src);
			} else if (op.equals("--")) {
				out.writeBinOpExp("sub", src, IRAddr.getCst(1), src);
			}
			return dest;
		}
	}
	
}

