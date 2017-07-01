package com.gmail.devinz1993.smallc.frontend;

class Func extends ParseNode {

	public Func(IDNode id, Paras paras) {
		super(id, paras);
	}
	
	@Override public String toString() {
		return ((IDNode)child).text;
	}
	
	public int getArgc() {
		Paras para = (Paras)child.sibling;
		int cnt = 0;
		while (null != para) {
			cnt ++;
			para = (Paras) para.child.sibling;
		}
		return cnt;
	}
	
}
