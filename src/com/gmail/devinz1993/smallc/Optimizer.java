package com.gmail.devinz1993.smallc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import com.gmail.devinz1993.smallc.frontend.IRWriter;

class Optimizer {

	private static final String GLOBAL_MARK = "$";
	
	protected final String PATH;
	
	public Optimizer(String filename) throws IOException {
		PATH = IRWriter.getIRPath(filename);
		allocSpaces();
		initGlbVars();
	}
	
	private void initGlbVars() throws IOException {
		BufferedReader in = new BufferedReader(new FileReader(PATH));
		try {
			PrintWriter out = new PrintWriter(PATH+"$");
			out.println(in.readLine());	// GLOBAL <num_of_var>
			try {
				List<String> inits = new LinkedList<String>();
				boolean inFunc = false;
				String line = in.readLine();
				while (null != line) {
					if (inFunc) {
						out.println(line);
						if (line.startsWith("end ")) {
							inFunc = false;
						}
					} else if (line.startsWith("define ")) {
						out.println(line);
						inFunc = true;
						if (line.equals("define main:")) {
							out.println(in.readLine());	// LOCAL <num_of_var>
							for (String init : inits) {
								out.println(init);
							}
						}
					} else if (0 < line.length()) {
						inits.add(line);
					} else {
						out.println(line);
					}
					line = in.readLine();
				}
			} finally {
				out.close();
			}
		} finally {
			in.close();
		}
		(new File(PATH+"$")).renameTo(new File(PATH));
	}
	
	private void allocSpaces() throws IOException {
		Map<String, Integer> spaces = getSpaces();
		BufferedReader in = new BufferedReader(new FileReader(PATH));
		try {
			PrintWriter out = new PrintWriter(PATH+"$");
			try {
				out.println("\tGLOBAL\t"+spaces.get(GLOBAL_MARK)+"\n");
				String line = in.readLine();
				while (!line.startsWith("#GLB_VAR:\t")) {
					if (!line.startsWith("#STACK:\t")) {
						out.println(line);
					}
					if (line.startsWith("define ")) {
						String func = line.substring(7, line.length()-1);
						if (!spaces.containsKey(func)) {
							throw new RuntimeException("Invalid IR Code File.");
						} else {
							out.println("\tLOCAL\t"+spaces.get(func));
						}
					}
					line = in.readLine();
				}
			} finally {
				out.close();
			}
		} finally {
			in.close();
		}
		(new File(PATH+"$")).renameTo(new File(PATH));
	}
	
	private Map<String,Integer> getSpaces() throws IOException {
		Map<String, Integer> map = new HashMap<String, Integer>();
		BufferedReader fin = new BufferedReader(new FileReader(PATH));
		try {
			String line = fin.readLine();
			while (null != line) {
				if (line.startsWith("#GLB_VAR:\t")) {
					StringTokenizer toks = new StringTokenizer(line);
					if (toks.countTokens() != 2) {
						break;
					} else if (!toks.nextToken().equals("#GLB_VAR:")) {
						break;
					} else {
						map.put(GLOBAL_MARK, Integer.valueOf(toks.nextToken()));
						return map;
					}
				} else if (line.startsWith("end ")) {
					String funcName = line.substring(4);
					StringTokenizer toks = new StringTokenizer(fin.readLine());
					if (toks.countTokens() != 2) {
						break;
					} else if (!toks.nextToken().equals("#STACK:")) {
						break;
					} else {
						map.put(funcName, Integer.valueOf(toks.nextToken()));
					}
				}
				line = fin.readLine();
			}
			throw new RuntimeException("Invalid IR Code File.");
		} finally {
			fin.close();
		}
	}
	
	public void optimize() {
		// do nothing
	}
	
}
