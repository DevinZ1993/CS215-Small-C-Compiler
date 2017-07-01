package com.gmail.devinz1993.smallc.backend;

import java.io.BufferedReader;
import java.io.Closeable;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.StringTokenizer;

import com.gmail.devinz1993.smallc.frontend.IRWriter;

class IRReader implements Closeable {
	
	private final String PATH;
	
	private BufferedReader in;
	private long lineNum = 0L;
	
	public IRReader(String filename) throws FileNotFoundException {
		PATH = IRWriter.getIRPath(filename);
		in = new BufferedReader(new FileReader(PATH));
	}
	
	public void close() throws IOException {
		in.close();
	}
	
	public int readSpace() throws IOException {
		StringTokenizer toks = new StringTokenizer(in.readLine());
		if (toks.countTokens() != 2) {
			throw new RuntimeException("Invalid IR Code File.");
		} else {
			String tag = toks.nextToken();
			if (!tag.equals("GLOBAL") && !tag.equals("LOCAL")) {
				throw new RuntimeException("Invalid IR Code File.");
			} else {
				return 4*Integer.valueOf(toks.nextToken());
			}
		}
	}
	
	public IRLine readLine() throws IOException {
		String line = in.readLine();
		while (null != line) {
			if (0 < line.length()) {
				StringTokenizer toks = new StringTokenizer(line);
				String[] arr = new String[toks.countTokens()];
				for (int i=0; i<arr.length; i++) {
					arr[i] = toks.nextToken();
				}
				return valueOf(arr);
			} else {
				line = in.readLine();
			}
		}
		return null;
	}
	
	public IRLine valueOf(String[] vals) {
		if (1 == vals.length) {
			if (vals[0].charAt(vals[0].length()-1) == ':') {
				return new Label(vals, lineNum++);
			}
		} else if (2 == vals.length) {
			if (vals[0].equals("read")) {
				return new ReadLine(vals, lineNum++);
			} else if (vals[0].equals("write")) {
				return new WriteLine(vals, lineNum++);
			} else if (vals[0].equals("return")) {
				return new ReturnLine(vals, lineNum++);
			} else if (vals[0].equals("argv")) {
				return new ArgvLine(vals, lineNum++);
			} else if (vals[0].equals("retv")) {
				return new RetvLine(vals, lineNum++);
			} else if (vals[0].equals("define")) {
				return new FuncHead(vals, lineNum++);
			} else if (vals[0].equals("end")) {
				return new FuncTail(vals, lineNum++);
			} else if (vals[0].equals("jmp")) {
				return new JmpLine(vals, lineNum++);
			}
		} else if (3 == vals.length) {
			if (vals[0].equals("call")) {
				return new CallLine(vals, lineNum++);
			} else {
				return new UniOpLine(vals, lineNum++);
			}
		} else if (4 == vals.length) {
			if (vals[0].equals("beq")) {
				return new BeqLine(vals, lineNum++);
			} else {
				return new BinOpLine(vals, lineNum++);
			}
		}
		return IRLine.NULL;
	}
	
	public long getPosition() {
		return lineNum;
	}
	
}
