package com.gmail.devinz1993.smallc.backend;

import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

class Register {
	
	private final String NAME;

	private Variable var;
	private boolean dirty, busy;

	public Register(String name) {
		NAME = name;
	}

	public void load(Variable var, PrintWriter out) {
		if (null != var) {
			this.var = var;
			out.println("\tlw\t"+this+",\t"+var);
			dirty = false;
		}
	}
	
	public void store(PrintWriter out) {
		if (null != var) {
			out.println("\tsw\t"+this+",\t"+var);
			dirty = false;
		}
	}
	
	@Override public String toString() {
		return NAME;
	}
	
	/** Static Section: */
	
	private static Register[] regs = new Register[16];
	
	public static final Register PTR = new Register("$t8");
	public static final Register CST = new Register("$t9");
	
	private static Map<Variable, Register> vars = new HashMap<Variable, Register>();
	
	static {
		for (int i=0; i<8; i++) {
			regs[i] = new Register("$s"+i);
			regs[i+8] = new Register("$t"+i);
		}
	}
	
	public static Register[] getSrc(PrintWriter out, String src1, String src2) {
		Register[] regs = new Register[2];
		regs[1] = getFirstSrcReg(out, src2);
		regs[1].busy = true;
		regs[0] = getSecondSrcReg(out, src1);
		regs[1].busy = false;
		return regs;
	}
	
	public static Register getSrc(PrintWriter out, String src) {
		return getFirstSrcReg(out, src);
	}
	
	public static Register getDest(PrintWriter out, String dest) {
		if (dest.indexOf(':') < 0) {
			Register reg = getRegToWrite(out, new Variable(dest));
			reg.dirty = true;
			return reg;
		} else {
			writeBack(out);
			return PTR;
		}
	}
	
	public static void write(PrintWriter out, String dest, Register reg) {
		if (reg == PTR) {
			int mid = dest.indexOf(':');
			Register reg1 = getPtr(out, new Variable(dest.substring(0, mid)));
			String offset = dest.substring(mid+1);
			if (offset.charAt(0) != '@') {
				if (dest.charAt(1) != '-') {
					out.println("\tsw\t"+reg+",\t"+4*Integer.valueOf(offset)+"("+reg1+")");
				} else {
					out.println("\tsw\t"+reg+",\t"+(-4)*Integer.valueOf(offset)+"("+reg1+")");
				}
			} else {
				reg1.busy = true;
				Register reg2 = getFirstSrcReg(out, offset);
				Register reg3 = getVacant(out);
				out.println("\tsll\t"+reg3+",\t"+reg2+",\t2");
				reg1.busy = false;
				if (dest.charAt(1) != '-') {
					out.println("\tadd\t"+CST+",\t"+reg1+",\t"+reg3);
				} else {
					out.println("\tsub\t"+CST+",\t"+reg1+",\t"+reg3);
				}
				out.println("\tsw\t"+reg+",\t0("+CST+")");
			}
			clear(out);
		}
	}
	
	private static Register getFirstSrcReg(PrintWriter out, String src) {
		if (src.charAt(0) != '@') {
			return CST;
		} else {
			int mid = src.indexOf(':');
			if (mid < 0) {
				return getRegToRead(out, new Variable(src));
			} else {
				writeBack(out);
				Register reg1 = getPtr(out, new Variable(src.substring(0, mid)));
				String offset = src.substring(mid+1);
				if (offset.charAt(0) != '@') {
					if (src.charAt(1) != '-') {
						out.println("\tlw\t"+CST+",\t"+4*Integer.valueOf(offset)+"("+reg1+")");
					} else {
						out.println("\tlw\t"+CST+",\t"+(-4)*Integer.valueOf(offset)+"("+reg1+")");
					}
				} else {
					reg1.busy = true;
					Register reg2 = getRegToRead(out, new Variable(offset));
					Register reg3 = getVacant(out);
					out.println("\tsll\t"+reg3+",\t"+reg2+",\t2");
					reg1.busy = false;
					if (src.charAt(1) != '-') {
						out.println("\tadd\t"+CST+",\t"+reg1+",\t"+reg3);
					} else {
						out.println("\tsub\t"+CST+",\t"+reg1+",\t"+reg3);
					}
					out.println("\tlw\t"+CST+",\t0("+CST+")");
				}
				return CST;
			}
		}
	}
	
	private static Register getSecondSrcReg(PrintWriter out, String src) {
		int mid = src.indexOf(':');
		if (mid < 0) {
			return getRegToRead(out, new Variable(src));
		} else {
			writeBack(out);
			Register reg1 = getPtr(out, new Variable(src.substring(0, mid)));
			String offset = src.substring(mid+1);
			if (offset.charAt(0) != '@') {
				if (src.charAt(1) != '-') {
					out.println("\tlw\t"+PTR+",\t"+4*Integer.valueOf(offset)+"("+reg1+")");
				} else {
					out.println("\tlw\t"+PTR+",\t"+(-4)*Integer.valueOf(offset)+"("+reg1+")");
				}
			} else {
				reg1.busy = true;
				Register reg2 = getRegToRead(out, new Variable(offset));
				Register reg3 = getVacant(out);
				out.println("\tsll\t"+reg3+",\t"+reg2+",\t2");
				reg1.busy = false;
				if (src.charAt(1) != '-') {
					out.println("\tadd\t"+PTR+",\t"+reg1+",\t"+reg3);
				} else {
					out.println("\tsub\t"+PTR+",\t"+reg1+",\t"+reg3);
				}
				out.println("\tlw\t"+PTR+",\t0("+PTR+")");
			}
			return PTR;
		}
	}
	
	private static Register getPtr(PrintWriter out, Variable base) {
		Register dest = getVacant(out);
		if (base.vma < 0) {
			out.println("\taddi\t"+dest+",\t$fp,\t"+(base.vma<<2));
		} else {
			out.println("\taddi\t"+dest+",\t$gp,\t"+(base.vma<<2));
		}
		return dest;
	}
	
	private static Register getRegToRead(PrintWriter out, Variable var) {
		if (!vars.containsKey(var)) {
			Register reg = getVacant(out);
			reg.load(var, out);
			vars.put(var, reg);
		}
		return vars.get(var);
	}
	
	private static Register getRegToWrite(PrintWriter out, Variable var) {
		if (!vars.containsKey(var)) {
			Register reg = getVacant(out);
			reg.var = var;
			vars.put(var, reg);
		}
		return vars.get(var);
	}
	
	/** Select an available register at random: */
	private static Register getVacant(PrintWriter out) {
		for (int i=0; i<16; i++) {
			if (null == regs[i].var && !regs[i].busy) {
				return regs[i];
			}
		}
		for (int i=0; i<16; i++) {
			if (!regs[i].dirty) {
				vars.remove(regs[i].var);
				return regs[i];
			}
		}
		Random rand = new Random();
		int idx = rand.nextInt(16);
		while (regs[idx].busy) {
			idx = rand.nextInt(16);
		}
		vars.remove(regs[idx].var);
		regs[idx].store(out);
		return regs[idx];
	}
	
	/** Write back all dirty registers: */
	public static void writeBack(PrintWriter out) {
		//out.println("# writeBack:");
		for (int i=0; i<16; i++) {
			if (null != regs[i].var && regs[i].dirty) {
				regs[i].store(out);
			}
		}
		//out.println("# writeBack");
	}
	
	/** Clear all register descriptors without writing back: */
	public static void clear(PrintWriter out) {
		//out.println("# clear()");
		for (int i=0; i<16; i++) {
			regs[i].var = null;
			regs[i].dirty = false;
		}
		vars.clear();
	}
	
}
