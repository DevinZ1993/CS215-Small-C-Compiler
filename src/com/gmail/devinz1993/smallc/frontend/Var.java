package com.gmail.devinz1993.smallc.frontend;

import java.util.ArrayList;
import java.util.List;

class Var extends ParseNode {

	public Var(Var var, CstNode cst) {
		super(var, cst);
	}
	
	public Var(IDNode id) {
		super(id);
	}
	
	@Override public String toString() {
		if (child instanceof IDNode) {
			return ((IDNode)child).text;
		} else {
			return ((Var)child).toString();
		}
	}
	
	public int getLine() {
		if (child instanceof IDNode) {
			return ((IDNode)child).line;
		} else {
			return ((Var)child).getLine();
		}
	}
	
	public int getCol() {
		if (child instanceof IDNode) {
			return ((IDNode)child).col;
		} else {
			return ((Var)child).getCol();
		}
	}
	
	public List<Integer> getDimList() {
		if (child instanceof IDNode) {
			return new ArrayList<Integer>(2);
		} else {
			List<Integer> lst = ((Var)child).getDimList();
			lst.add(((CstNode)child.sibling).value);
			return lst;
		}
	}
	
}
