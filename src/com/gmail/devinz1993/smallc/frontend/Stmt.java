package com.gmail.devinz1993.smallc.frontend;

import java.util.Stack;

abstract class Stmt extends ParseNode {

	protected static int loopCnt = 0;
	
	protected static Stack<Integer> loopIDs = new Stack<Integer>();
	
	public static Stmt newBreak(final IDNode id) {
		return new Stmt(id) {
			public void genIRCode(IRWriter out) throws TypeError {
				if (loopIDs.empty()) {
					IDNode id = (IDNode) child;
					throw new TypeError("no loop to break", id.line, id.col);
				} else {
					out.writeJump("exit"+loopIDs.peek());
				}
			}
		};
	}
	
	public static Stmt newCont(final IDNode id) {
		return new Stmt(id) {
			public void genIRCode(IRWriter out) throws TypeError {
				if (loopIDs.empty()) {
					IDNode id = (IDNode) child;
					throw new TypeError("no loop to continue", id.line, id.col);
				} else {
					out.writeJump("cont"+loopIDs.peek());
				}
			}
		};
	}
	
	public Stmt(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
	public abstract void genIRCode(IRWriter out) throws TypeError;
	
}

class ExpStmt extends Stmt {
	
	public ExpStmt(Exp exp) {
		super(exp);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		if (null != child) {
			if (child.child instanceof FuncExps) {
				((FuncExps)child.child).genIRCode(out, null);
			} else {
				((Exp)child).getResult(out);
			}
		}
	}
	
}

class BlockStmt extends Stmt {
	
	public BlockStmt(StmtBlock stmtBlock) {
		super(stmtBlock);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		((StmtBlock)child).genIRCode(out);
	}
	
}

class RetStmt extends Stmt {
	
	public RetStmt(Exp exp) {
		super(exp);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		out.writeRet(((Exp)child).getResult(out));
	}
	
}

class IfStmt extends Stmt {
	
	private static int cnt = 0;
	
	public IfStmt(IDNode id, Exp exp, Stmt then) throws ParseError {
		this(id, exp, then, null);
	}
	
	public IfStmt(IDNode id, Exp exp, Stmt then, Stmt elseStmt) throws ParseError {
		super(exp, then, elseStmt);
		if (null == exp) {
			throw new ParseError("IF condition cannot be empty", id.line, id.col);
		}
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		int id = cnt++;
		String ifLabel = "if"+id, elseLabel = "else"+id;
		IRAddr test = ((Exp)child).getResult(out);
		out.writeBeq(test, IRAddr.getCst(0), ifLabel);
		((Stmt)child.sibling).genIRCode(out);	// then
		if (null != child.sibling.sibling) {
			out.writeJump(elseLabel);
		}
		out.setLabel(ifLabel);
		if (null != child.sibling.sibling) {
			((Stmt)child.sibling.sibling).genIRCode(out);	// else
			out.setLabel(elseLabel);
		}
	}
	
}

class ForStmt extends Stmt {
	
	private static final Exp genTrueExp() {
		return new Exp(null) {
			public IRAddr getResult(IRWriter out) throws TypeError {
				return IRAddr.getCst(1);
			}
		};
	}
		
	public ForStmt(Exp init, Exp test, Exp update, Stmt body) {
		super(
				null==init? genTrueExp():init, 
				null==test? genTrueExp():test,
				null==update? genTrueExp():update, 
				body
				);
	}
	
	public void genIRCode(IRWriter out) throws TypeError {
		int id = loopCnt++;
		String loopLabel = "loop"+id, exitLabel = "exit"+id;
		((Exp)child).getResult(out);	// init
		IRAddr test = ((Exp)child.sibling).getResult(out);	// test
		out.writeBeq(test, IRAddr.getCst(0), exitLabel);
		out.setLabel(loopLabel);
		loopIDs.push(id);
		((Stmt)child.sibling.sibling.sibling).genIRCode(out);	// body
		loopIDs.pop();
		((Exp)child.sibling.sibling).getResult(out);	// update
		test = ((Exp)child.sibling).getResult(out);	// test
		out.writeBeq(test, IRAddr.getCst(0), exitLabel);
		out.writeJump(loopLabel);
		out.setLabel("cont"+id);
		((Exp)child.sibling.sibling).getResult(out);	// update
		out.writeJump(loopLabel);
		out.setLabel(exitLabel);
	}

}
