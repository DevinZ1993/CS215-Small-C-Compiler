package com.gmail.devinz1993.smallc.frontend;

class IRAddr {
	
	public final boolean CST;
	public final int value;
	public final IRAddr offset;
	
	private IRAddr(boolean CST, int value, IRAddr offset) {
		this.CST = CST;
		this.value = value;
		this.offset = offset;
	}
	
	@Override public String toString() {
		if (CST) {
			return Integer.valueOf(value).toString();
		} else if (null != offset) {
			return "@"+value+":"+offset;
		} else {
			return "@"+value;
		}
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof IRAddr)) {
			return false;
		} else {
			IRAddr other = (IRAddr) o;
			if (CST) {
				return other.CST && value == other.value;
			} else if (other.CST || value != other.value) {
				return false;
			} else if (null == offset) {
				return null == other.offset;
			} else {
				return offset.equals(other.offset);
			}
		}
	}
	
	public static IRAddr getVar(VarSymbol base) {
		return new IRAddr(false, base.ID, null);
	}
	
	public static IRAddr getVar(VarSymbol base, IRAddr offset) {
		return new IRAddr(false, base.ID, offset);
	}
	
	private static final IRAddr ZERO = new IRAddr(true, 0, null);
	private static final IRAddr ONE = new IRAddr(true, 1, null);
	
	public static IRAddr getCst(int value) {
		if (0 == value) {
			return ZERO;
		} else if (1 == value) {
			return ONE;
		} else {
			return new IRAddr(true, value, null);
		}
	}
	
}
