package com.gmail.devinz1993.smallc.frontend;

import java.util.HashMap;
import java.util.Map;

class AssignExps extends OpExps {
	
	public AssignExps(LvalExps left, Assign op, Exps right) {
		super(left, op, right);
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		IRAddr dest = ((LvalExps) child).getResult(out);
		Exps right = (Exps)child.sibling.sibling;
		right.genIRCode(out, dest);
		return dest;
	}
	
}

class OpAssignExps extends AssignExps {
	
	private static Map<String, String> ops = new HashMap<String, String>();
	
	static {
		ops.put("+=", "add");
		ops.put("-=", "sub");
		ops.put("*=", "mul");
		ops.put("/=", "div");
		ops.put("%=", "rem");
		ops.put("&=", "and");
		ops.put("^=", "xor");
		ops.put("|=", "or");
		ops.put("<<=", "sll");
		ops.put(">>=", "srl");
	}
	
	public OpAssignExps(LvalExps left, OpAssign op, Exps right) {
		super(left, op, right);
	}

	@Override
	public IRAddr getResult(IRWriter out) throws TypeError {
		IRAddr dest = ((LvalExps) child).getResult(out);
		String op = ((Assign)child.sibling).text;
		IRAddr tmp = ((Exps)child.sibling.sibling).getResult(out);
		out.writeBinOpExp(ops.get(op), dest, tmp, dest);
		return dest;
	}
	
}
