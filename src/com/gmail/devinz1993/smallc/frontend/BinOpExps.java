package com.gmail.devinz1993.smallc.frontend;

import java.util.HashMap;
import java.util.Map;

class BinOpExps extends OpExps {
	
	public BinOpExps(Exps exps1, BinOp op, Exps exps2) {
		super(exps1, op, exps2);
	}
	
	public IRAddr getResult(IRWriter out) throws TypeError {
		IRAddr src1 = ((Exps) child).getResult(out);
		String op = ((BinOp)child.sibling).text;
		IRAddr src2 = ((Exps)child.sibling.sibling).getResult(out);
		if (src1.CST && src2.CST) {
			if (op.equals("||")) {
				return IRAddr.getCst((src1.value!=0)||(src2.value!=0) ? 1:0);
			} else if (op.equals("&&")) {
				return IRAddr.getCst((src1.value!=0)&&(src2.value!=0) ? 1:0);
			} else {
				return IRAddr.getCst(cstOps.get(op).operate(src1.value, src2.value));
			}
		} else {
			IRAddr dest = IRAddr.getVar(new VarSymbol());
			if (op.equals("||")) {
				out.writeBinOpExp("or", intToBool(out, src1), intToBool(out, src2), dest);
			} else if (op.equals("&&")) {
				out.writeBinOpExp("and", intToBool(out, src1), intToBool(out, src2), dest);
			} else {
				out.writeBinOpExp(varOps.get(op), src1, src2, dest);
			}
			return dest;
		}
	}
	
	private static interface CstOp {
		int operate(int src1, int src2);
	}
	
	private static Map<String, String> varOps = new HashMap<String, String>();
	private static Map<String, CstOp> cstOps = new HashMap<String, CstOp>();
	
	static {
		varOps.put("+", "add");
		cstOps.put("+", new CstOp(){
			public int operate(int x, int y) {
				return x+y;
			}
		});
		varOps.put("-", "sub");
		cstOps.put("-", new CstOp(){
			public int operate(int x, int y) {
				return x-y;
			}
		});
		varOps.put("*", "mul");
		cstOps.put("*", new CstOp(){
			public int operate(int x, int y) {
				return x*y;
			}
		});
		varOps.put("/", "div");
		cstOps.put("/", new CstOp(){
			public int operate(int x, int y) {
				return x/y;
			}
		});
		varOps.put("%", "rem");
		cstOps.put("%", new CstOp(){
			public int operate(int x, int y) {
				return x%y;
			}
		});
		varOps.put("&", "and");
		cstOps.put("&", new CstOp(){
			public int operate(int x, int y) {
				return x&y;
			}
		});
		varOps.put("^", "xor");
		cstOps.put("^", new CstOp(){
			public int operate(int x, int y) {
				return x^y;
			}
		});
		varOps.put("|", "or");
		cstOps.put("|", new CstOp(){
			public int operate(int x, int y) {
				return x|y;
			}
		});
		varOps.put("<<", "sll");
		cstOps.put("<<", new CstOp(){
			public int operate(int x, int y) {
				return x<<y;
			}
		});
		varOps.put(">>", "srl");
		cstOps.put(">>", new CstOp(){
			public int operate(int x, int y) {
				return x>>y;
			}
		});
		varOps.put("!=", "sne");
		cstOps.put("!=", new CstOp(){
			public int operate(int x, int y) {
				return (x!=y)? 1:0;
			}
		});
		varOps.put("==", "seq");
		cstOps.put("==", new CstOp(){
			public int operate(int x, int y) {
				return (x==y)? 1:0;
			}
		});
		varOps.put("<", "slt");
		cstOps.put("<", new CstOp(){
			public int operate(int x, int y) {
				return (x<y)? 1:0;
			}
		});
		varOps.put(">", "sgt");
		cstOps.put(">", new CstOp(){
			public int operate(int x, int y) {
				return (x>y)? 1:0;
			}
		});
		varOps.put("<=", "sle");
		cstOps.put("<=", new CstOp(){
			public int operate(int x, int y) {
				return (x<=y)? 1:0;
			}
		});
		varOps.put(">=", "sge");
		cstOps.put(">=", new CstOp(){
			public int operate(int x, int y) {
				return (x>=y)? 1:0;
			}
		});
	}
	
}
