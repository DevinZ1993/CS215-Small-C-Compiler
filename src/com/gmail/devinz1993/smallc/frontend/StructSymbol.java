package com.gmail.devinz1993.smallc.frontend;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

class StructSymbol {
	
	private Set<String> fields = new HashSet<String>();
	
	public boolean add(String fieldName) {
		if (fields.contains(fieldName)) {
			return false;
		} else {
			fields.add(fieldName);
			return true;
		}
	}
	
	public void addVars(String entity, int line, int col) throws TypeError {
		for (String field : fields) {
			if (!VarSymbol.put(entity+"."+field)) {
				throw new TypeError("struct var "+entity+" redefined", line, col);
			}
		}
	}
	
	private static List<Map<String, StructSymbol>> structs =
			new LinkedList<Map<String, StructSymbol>>();
	
	static {
		structs.add(new HashMap<String, StructSymbol>());
	}
	
	public static boolean put(String structName) {
		Map<String, StructSymbol> map = structs.get(structs.size()-1);
		if (map.containsKey(structName)) {
			return false;
		} else {
			map.put(structName, new StructSymbol());
			return true;
		}
	}
	
	public static StructSymbol get(String structName) {
		for (int i=structs.size()-1; i>=0; i--) {
			if (structs.get(i).containsKey(structName)) {
				return structs.get(i).get(structName);
			}
		}
		return null;
	}
	
	public static void enterBlock() {
		structs.add(new HashMap<String, StructSymbol>());
	}
	
	public static void leaveBlock() {
		structs.remove(structs.size()-1);
	}
	
}
