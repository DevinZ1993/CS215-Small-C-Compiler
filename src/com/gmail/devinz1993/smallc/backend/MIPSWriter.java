package com.gmail.devinz1993.smallc.backend;

import java.io.Closeable;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.StringTokenizer;

public class MIPSWriter implements Closeable {

	private final String filename;
	private final PrintWriter out;
	
	public MIPSWriter(String filename) throws IOException {
		this.filename = filename;
		out = new PrintWriter("out/"+(new StringTokenizer(filename, ".")).nextToken()+".s");
	}
	
	public void close() {
		out.close();
	}
	
	public void write() throws IOException {
		IRReader reader = new IRReader(filename);
		try {
			writeHead(reader);
			IRLine line = reader.readLine();
			while (null != line) {
				if (line instanceof FuncHead) {
					((FuncHead)line).setSpace(reader.readSpace());
					line.write(out);
					writeFunc(reader);
				}
				line = reader.readLine();
			}
		} finally {
			reader.close();
		}
	}
	
	private void writeFunc(IRReader reader) throws IOException {
		IRLine line = reader.readLine();
		while (!(line instanceof FuncTail)) {
			if (line instanceof CallLine) {
				
				CallLine call = (CallLine) line;
				int argc = call.getArgc();
				
				for (int i=0; i<argc; i++) {
					
					ArgvLine argv = (ArgvLine) reader.readLine();
					argv.setNum(i);
					argv.write(out);
				}
				Register.writeBack(out);
				Register.clear(out);
				call.write(out);
				
			} else {
				line.write(out);
			}
			line = reader.readLine();
		}
		line.write(out);
		Register.clear(out);
	}
	
	private void writeHead(IRReader reader) throws IOException {
		out.println("\t\t.data");
		out.println("GLB_VAR:");
		out.println("\t.space\t"+reader.readSpace());
		out.println("endL:");
		out.println("\t.asciiz\t\"\\n\"");
		out.println("\t\t.text");
		out.println("\t.globl\tmain\n");
	}
		
}
