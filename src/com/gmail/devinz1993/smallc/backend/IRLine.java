package com.gmail.devinz1993.smallc.backend;

import java.io.PrintWriter;

abstract class IRLine {
	
	protected final String[] vals;
	
	public final long ID;
	
	public IRLine(String[] vals, long ID) {
		this.vals = vals;
		this.ID = ID;
	}
	
	public abstract void write(PrintWriter out);
	
	public static final IRLine NULL = new IRLine(null, 0L) {
		public void write(PrintWriter out) {}
	};
	
}

class Label extends IRLine {
	
	public Label(String[] vals, long ID) {
		super(vals, ID);
	}
	
	@Override public String toString() {
		return vals[0].substring(0, vals[0].length()-1);
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof Label)) {
			return false;
		} else {
			return ((Label)o).vals[0].equals(vals[0]);
		}
	}
	
	public void write(PrintWriter out) {
		Register.writeBack(out);
		out.println(vals[0]);
		Register.clear(out);
	}
	
}

class ReadLine extends IRLine {
	
	public ReadLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		out.println("\tli\t$v0,\t5");
		out.println("\tsyscall");
		Register dest = Register.getDest(out, vals[1]);
		out.println("\tmove\t"+dest+",\t$v0");
		Register.write(out, vals[1], dest);
	}
	
}

class WriteLine extends IRLine {
	
	public WriteLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register src = Register.getSrc(out, vals[1]);
		if (vals[1].charAt(0) != '@') {
			out.println("\tli\t$a0,\t"+vals[1]);
		} else {
			out.println("\tmove\t$a0,\t"+src);
		}
		out.println("\tli\t$v0,\t1");
		out.println("\tsyscall");
		out.println("\tli\t$v0,\t4");
		out.println("\tla\t$a0,\tendL");
		out.println("\tsyscall");
	}
	
}

class CallLine extends IRLine {
	
	public CallLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public int getArgc() {
		return Integer.valueOf(vals[2]);
	}
	
	public void write(PrintWriter out) {
		Register.writeBack(out);
		out.println("\tjal\t"+vals[1]);
	}
	
}

class ReturnLine extends IRLine {
	
	
	public ReturnLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register.writeBack(out);
		Register src = Register.getSrc(out, vals[1]);
		if (vals[1].charAt(0) != '@') {
			out.println("\tli\t$v0,\t"+vals[1]);
		} else {
			out.println("\tmove\t$v0,\t"+src);
		}
		out.println("\tmove\t$sp,\t$fp");
		out.println("\tlw\t$fp,\t-4($sp)");
		out.println("\tlw\t$ra,\t0($sp)");
		out.println("\tjr\t$ra");
		Register.clear(out);
	}
	
}

class ArgvLine extends IRLine {
	
	private int num;
	
	public ArgvLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void setNum(int num) {
		this.num = num;
	}
	
	public void write(PrintWriter out) {
		Register src = Register.getSrc(out, vals[1]);
		if (vals[1].charAt(0) != '@') {
			out.println("\tli\t"+src+"\t"+vals[1]);
			out.println("\tsw\t"+src+",\t"+(-4*num-8)+"($sp)");
		} else {
			out.println("\tsw\t"+src+",\t"+(-4*num-8)+"($sp)");
		}
	}
	
}

class RetvLine extends IRLine {

	public RetvLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		out.println("\tsw\t$v0,\t"+(new Variable(vals[1])));
	}
	
}

class UniOpLine extends IRLine {
	
	public UniOpLine(String[] vals, long ID) {
		super(vals, ID);
	}
	

	public void write(PrintWriter out) {
		Register src = Register.getSrc(out, vals[1]);
		Register dest = Register.getDest(out, vals[2]);
		if (vals[1].charAt(0) != '@') {
			if (vals[0].equals("mov")) {
				out.println("\tli\t"+dest+",\t"+vals[1]);
			} else {
				out.println("\tli\t"+src+",\t"+vals[1]);
				out.println("\tmove\t"+dest+",\t"+src);
			}
		} else {
			if (vals[0].equals("mov")) {
				out.println("\tmove\t"+dest+",\t"+src);
			} else {
				out.println("\t"+vals[0]+"\t"+dest+",\t"+src);
			}
		}
		Register.write(out, vals[2], dest);
	}
	
}

class BinOpLine extends IRLine {
	
	public BinOpLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register[] srcs = Register.getSrc(out, vals[1], vals[2]);
		Register dest = Register.getDest(out, vals[3]);
		if (vals[2].charAt(0) != '@') {
			int cst = Integer.valueOf(vals[2]);
			if (cst >= -32768 && cst <= 32767) {
				if (vals[0].equals("add")) {
					out.println("\taddi\t"+dest+",\t"+srcs[0]+",\t"+vals[2]);
				} else if (vals[0].equals("and")) {
					out.println("\tandi\t"+dest+",\t"+srcs[0]+",\t"+vals[2]);
				} else if (vals[0].equals("or")) {
					out.println("\tori\t"+dest+",\t"+srcs[0]+",\t"+vals[2]);
				} else if (vals[0].equals("xor")) {
					out.println("\txori\t"+dest+",\t"+srcs[0]+",\t"+vals[2]);
				} else {
					out.println("\tli\t$t9,\t"+vals[2]);
					out.println("\t"+vals[0]+"\t"+dest+",\t"+srcs[0]+",\t"+srcs[1]);
				}
			} else {
				out.println("\tli\t$t9,\t"+vals[2]);
				out.println("\t"+vals[0]+"\t"+dest+",\t"+srcs[0]+",\t"+srcs[1]);
			}
		} else {
			out.println("\t"+vals[0]+"\t"+dest+",\t"+srcs[0]+",\t"+srcs[1]);
		}
		Register.write(out, vals[3], dest);
	}
	
}

class JmpLine extends IRLine {
	
	public JmpLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register.writeBack(out);
		out.println("\tj\t"+vals[1]);
		Register.clear(out);
	}
	
}

class BeqLine extends IRLine {
	
	public BeqLine(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register.writeBack(out);
		if (vals[2].equals("0")) {
			out.println("\tbeqz\t"+Register.getSrc(out, vals[1])+",\t"+vals[3]);
		} else {
			Register[] srcs = Register.getSrc(out, vals[1], vals[2]);
			if (vals[2].charAt(0) != '@') {
				out.println("\tli\t$t9,\t"+vals[2]);
				out.println("\tbeq\t"+srcs[0]+",\t$t9,\t"+vals[3]);
			} else {
				out.println("\tbeq\t"+srcs[0]+",\t"+srcs[1]+",\t"+vals[3]);
			}
		}
		Register.clear(out);
	}
	
}

class FuncHead extends IRLine {
	
	private int space;
	
	public FuncHead(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void setSpace(int space) {
		this.space = space;
	}
	
	public void write(PrintWriter out) {
		out.println(vals[1]);
		out.println("\tsw\t$ra,\t0($sp)");
		out.println("\tsw\t$fp,\t-4($sp)");
		out.println("\taddi\t$fp,\t$sp,\t0");
		if (space >= -32768 && space <= 32767) {
			out.println("\taddi\t$sp,\t$sp,\t"+(-space));
		} else {
			out.println("\tli\t$t9,\t"+space);
			out.println("\tsub\t$sp,\t$sp,\t$t9");
		}
	}
	
}

class FuncTail extends IRLine {
	
	public FuncTail(String[] vals, long ID) {
		super(vals, ID);
	}
	
	public void write(PrintWriter out) {
		Register.clear(out);
		out.println();
	}
	
}


