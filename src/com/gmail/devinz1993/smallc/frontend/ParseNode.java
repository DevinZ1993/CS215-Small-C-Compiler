package com.gmail.devinz1993.smallc.frontend;


class ParseNode implements Cloneable {
	
    protected ParseNode sibling, child;

    public ParseNode(ParseNode... children) {
        if (children.length > 0 && null!=children[0]) {
        	child = children[0];
        	for (int i=0; i+1<children.length && null!=children[i]; i++) {
        		children[i].sibling = children[i+1];
        	}
        }
    }
    
}
