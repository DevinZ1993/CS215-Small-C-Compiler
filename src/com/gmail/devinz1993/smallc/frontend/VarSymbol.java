package com.gmail.devinz1993.smallc.frontend;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

class VarSymbol {

	private static boolean local = false;
	
	public final int[] dims;
	
	public final int ID;
	
	/** For temp vars: */
	public VarSymbol() {
		dims = new int[0];
		ID = local? nextLocal-- : nextGlobal++;
	}
	
	/** For arrays: */
	public VarSymbol(List<Integer> dimList) {
		int size = 1;
		dims = new int[dimList.size()];
		for (int i=dims.length-1, tmp=1; i>=0; i--) {
			dims[i] = tmp;
			tmp = dimList.get(i);
			size *= tmp;
		}
		if (local) {
			ID = nextLocal;
			nextLocal -= size;
		} else {
			ID = nextGlobal;
			nextGlobal += size;
		}
	}
	
	/** For struct instance: */
	private VarSymbol(boolean flag) {
		dims = null;
		ID = 0;
	}
	
	@Override public String toString() {
		return "@"+ID;
	}
	
	private static int nextGlobal = 0, nextLocal;
	
	private static List<Map<String, VarSymbol>> vars = 
			new LinkedList<Map<String, VarSymbol>>();
	
	static {
		vars.add(new HashMap<String, VarSymbol>());
	}
	
	public static boolean put(String key, List<Integer> dimLst) {
		if (vars.get(vars.size()-1).containsKey(key)) {
			return false;
		} else {
			vars.get(vars.size()-1).put(key, new VarSymbol(dimLst));
			return true;
		}
	}
	
	public static boolean put(String key) {
		if (vars.get(vars.size()-1).containsKey(key)) {
			return false;
		} else {
			vars.get(vars.size()-1).put(key, new VarSymbol());
			return true;
		}
	}
	
	public static boolean putName(String key) {
		if (vars.get(vars.size()-1).containsKey(key)) {
			return false;
		} else {
			vars.get(vars.size()-1).put(key, new VarSymbol(false));
			return true;
		}
	}
	
	public static VarSymbol get(String key) {
		for (int i=vars.size()-1; i>=0; i--) {
			if (vars.get(i).containsKey(key)) {
				VarSymbol v = vars.get(i).get(key);
				if (null != v.dims) {
					return v;
				}
			}
		}
		System.out.println(vars);
		return null;
	}
	
	public static void enterBlock() {
		vars.add(new HashMap<String, VarSymbol>());
	}
	
	public static void leaveBlock() {
		vars.remove(vars.size()-1);
	}
	
	public static void enterFunc() {
		local = true;
		nextLocal = -2;
		enterBlock();
	}
	
	public static void leaveFunc() {
		leaveBlock();
		local = false;
	}
	
	public static int getStackSpace() {
		return -nextLocal;
	}
	
	public static int getGlobalSize() {
		return nextGlobal;
	}
	
}
