package com.gmail.devinz1993.smallc.frontend;

import java.io.Closeable;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.StringTokenizer;


public class IRWriter implements Closeable {
	
	public static String getIRPath(String filename) {
		return "out/"+(new StringTokenizer(filename, ".")).nextToken()+".ir";
	}
	
	private PrintWriter out;
	
	public IRWriter(String filename) throws IOException {
		out = new PrintWriter(new FileOutputStream(getIRPath(filename)));
	}
	
	public void close() {
		out.close();
	}
	
	/**
	 * mov <src> <dest>
	 */
	public synchronized void writeAssign(IRAddr src, IRAddr dest) {
		if (!dest.equals(src)) {
			out.println("\tmov\t"+src+"\t"+dest);
		}
	}
	
	/**
	 * <binop> <src1> <src2> <dest>
	 */
	public synchronized void writeBinOpExp(String binop, IRAddr src1, IRAddr src2, IRAddr dest) {
		if (src1.CST) {
			out.println("\t"+binop+"\t"+src2+"\t"+src1+"\t"+dest);
		} else {
			out.println("\t"+binop+"\t"+src1+"\t"+src2+"\t"+dest);
		}
	}
	
	/**
	 * <uniop> <src> <dest> 
	 */
	public synchronized void writeUniOpExp(String uniop, IRAddr src, IRAddr dest) {
		out.println("\t"+uniop+"\t"+src+"\t"+dest);
	}
	
	/**
	 * jmp <label> 
	 */
	public synchronized void writeJump(String label) {
		out.println("\tjmp\t"+label);
	}
	
	/**
	 * beq <src1> <src2> <label>
	 */
	public synchronized void writeBeq(IRAddr src1, IRAddr src2, String label) {
		if (src1.CST && src2.CST) {
			if (src1.value == src2.value) {
				writeJump(label);
			}
		} else {
			out.println("\tbeq\t"+src1+"\t"+src2+"\t"+label);
		}
	}
	
	/**
	 * call <func_name> <argc>
	 */
	public synchronized void writeCall(String func, int argc) {
		out.println("\tcall\t"+func+"\t"+argc);
	}
	
	/**
	 * argv <var> 
	 */
	public synchronized void writeArgv(IRAddr argv) {
		out.println("\targv\t"+argv);
	}
	
	/**
	 * retv <var>
	 */
	public synchronized void writeRetv(IRAddr retv) {
		out.println("\tretv\t"+retv);
	}
	
	/**
	 * define <func_name>:
	 */
	public synchronized void enterFunc(String funcName) {
		out.println("\ndefine "+funcName+":");
	}
	
	/**
	 * return <var>
	 */
	public synchronized void writeRet(IRAddr val) {
		out.println("\treturn\t"+val);
	}
	
	/**
	 * <func_name>
	 */
	public synchronized void leaveFunc(String funcName) {
		out.println("end "+funcName);
	}
	
	/**
	 * <label_str>:
	 */
	public synchronized void setLabel(String label) {
		out.println(label+":");
	}
	
	public synchronized void writeInput(IRAddr x) {
		out.println("\tread\t"+x);
	}
	
	public synchronized void writeOutput(IRAddr x) {
		out.println("\twrite\t"+x);
	}
	
	public synchronized void writeSpace(String tag, int size) {
		out.println("#"+tag+":\t"+size+"\n");
	}
	
}
