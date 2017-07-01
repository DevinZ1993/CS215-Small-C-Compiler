package com.gmail.devinz1993.smallc.frontend;

public abstract class AbsError extends Exception {

	private static final long serialVersionUID = -7580740662116022749L;
	
	public final String info;
	
	public final int line, col;
	
	public AbsError(String info, int line, int col) {
		this.info = info;
		this.line = line;
		this.col = col;
	}
		
	@Override public String toString() {
		return "["+(line+1)+", "+(col+1)+"]\t"+info+".";	
	}
	
}

class ParseError extends AbsError {
	
	private static final long serialVersionUID = 2327439940798538171L;

	public ParseError(String info, int line, int col) {
		super(info, line, col);
	}

	@Override public String toString() {
		return "Syntax Error @"+super.toString();
	}
	
}

class TypeError extends AbsError {
	
	private static final long serialVersionUID = -5587864811326713511L;

	public TypeError(String info, int line, int col) {
		super(info, line, col);
	}

	@Override public String toString() {
		return "Type Error @"+super.toString();
	}
	
}
