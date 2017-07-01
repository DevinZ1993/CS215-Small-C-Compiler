package com.gmail.devinz1993.smallc.frontend;

import java.util.HashSet;
import java.util.Set;

class FuncSymbol {
	
	public final String name;
	public final int argc;
	
	public FuncSymbol(String name, int argc) {
		this.name = name;
		this.argc = argc;
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof FuncSymbol)) {
			return false;
		} else {
			FuncSymbol other = (FuncSymbol)o;
			return name.equals(other.name) && argc == other.argc;
		}
	}
	
	@Override public int hashCode() {
		return 13*name.hashCode()+argc;
	}
	
	private static Set<FuncSymbol> funcs =
			new HashSet<FuncSymbol>();
	
	static {
		funcs.add(new FuncSymbol("write",1));
		funcs.add(new FuncSymbol("read",1));
	}
	
	public static boolean put(String name, int argc) {
		FuncSymbol symbol = new FuncSymbol(name, argc);
		if (funcs.contains(symbol)) {
			return false;
		} else {
			funcs.add(symbol);
			return true;
		}
	}
	
	public static boolean contains(String name, int argc) {
		return funcs.contains(new FuncSymbol(name, argc));
	}
	
}
