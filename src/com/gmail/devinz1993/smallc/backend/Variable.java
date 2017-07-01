package com.gmail.devinz1993.smallc.backend;

class Variable {
	
	public final int vma;
	
	public Variable(String iraddr) {
		vma = Integer.valueOf(iraddr.substring(1));
	}
	
	@Override public String toString() {
		if (vma >= 0) {
			return (vma<<2)+"($gp)";
		} else {
			return (vma<<2)+"($fp)";
		}
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof Variable)) {
			return false;
		} else {
			return vma == ((Variable)o).vma;
		}
	}
	
	@Override public int hashCode() {
		return Integer.valueOf(vma).hashCode();
	}
	
}
