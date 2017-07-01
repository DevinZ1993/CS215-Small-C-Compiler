package com.gmail.devinz1993.smallc.frontend;

import java.util.ArrayList;
import java.util.List;

class Init extends ParseNode {

	public Init(ParseNode... parseNodes) {
		super(parseNodes);
	}
	
}

class ExpInit extends Init {
	
	public ExpInit(Exp exp) {
		super(exp);
	}
	
}

class ArgInit extends Init {
	
	public ArgInit(Args args) {
		super(args);
	}
	
	public int getArgc() {
		return ((Args)child).getArgc();
	}
	
	public List<Args> getArgs() {
		List<Args> lst = new ArrayList<Args>();
		Args args = (Args)child;
		while (null != args) {
			lst.add(args);
			args = (Args)args.child.sibling;
		}
		return lst;
	}
	
}
