package com.gmail.devinz1993.smallc;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import com.gmail.devinz1993.smallc.backend.MIPSWriter;
import com.gmail.devinz1993.smallc.frontend.AbsError;
import com.gmail.devinz1993.smallc.frontend.IRWriter;
import com.gmail.devinz1993.smallc.frontend.Parser;
import com.gmail.devinz1993.smallc.frontend.Program;


public class Compiler {
	
	public boolean translate(String filename) {
    	try (InputStream in = new FileInputStream("in/"+filename)) {
    		Parser parser = new Parser(in);
    		java_cup.runtime.Symbol parseTree = parser.parse();
    		System.out.println("Step 1: Parsing Completed.");
    		Program root = (Program) parseTree.value;
    		IRWriter irwriter = new IRWriter(filename);
    		try {
    			root.genIRCode(irwriter);
    		} finally {
    			irwriter.close();
    		}
    		System.out.println("Step 2: IR Code Generated.");
    		return true;
    	} catch (AbsError e) {
    		System.out.println("Translation Aborted.");
    		System.out.println("\t"+e);
    	} catch (Exception e) {
    		System.err.println("Unexpected Exception:");
			e.printStackTrace();
    	}
    	return false;
    }
	
	public void optimize(String filename) {
		try {
			(new Optimizer(filename)).optimize();
			System.out.println("Step 3: IR Code Optimized.");
		} catch (Exception e) {
			System.out.println("Optimization Aborted.");
    		System.out.println("\t"+e);
		}
	}
    
    public void generate(String filename) {
    	try {
    		MIPSWriter writer = new MIPSWriter(filename);
			try {
				writer.write();
			} finally {
				writer.close();
			}
			System.out.println("Step 4: MIPS Code Generated.");
    	} catch (IOException e) {
    		e.printStackTrace();
    	} catch (Exception e) {
    		System.out.println("Generation Aborted.");
    		System.out.println("\t"+e);
    	}
    }
    
    public void compile(String filename) {
		if (translate(filename)) {
			optimize(filename);
			generate(filename);
		}
	}
	
    private Compiler() {}
    
    private static Compiler instance;
    
    public static Compiler getInstance() {
    	if (null == instance) {
    		synchronized (Compiler.class) {
    			if (null == instance) {
    				instance = new Compiler();
    			}
    		}
    	}
    	return instance;
    }
    
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("No input path. Are you kidding me?");
        } else {
            Compiler.getInstance().compile(args[0]);
        }
    }
    
}
