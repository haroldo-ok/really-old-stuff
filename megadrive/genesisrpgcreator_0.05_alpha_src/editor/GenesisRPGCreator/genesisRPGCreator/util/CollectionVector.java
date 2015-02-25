/*
 *  Genesis RPG Creator World Designer, (c) 2005
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */
package genesisRPGCreator.util;

import java.util.Collection;
import java.util.TreeSet;
import java.util.Vector;

/**
 * @author Haroldo de Oliveira Pinheiro
 *
 * CollectionItem-aware vector
 * 
 */
public class CollectionVector extends Vector {

	/**
	 * 
	 */
	public CollectionVector() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param initialCapacity
	 */
	public CollectionVector(int initialCapacity) {
		super(initialCapacity);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param initialCapacity
	 * @param capacityIncrement
	 */
	public CollectionVector(int initialCapacity, int capacityIncrement) {
		super(initialCapacity, capacityIncrement);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param c
	 */
	public CollectionVector(Collection c) {
		super(c);
		// TODO Auto-generated constructor stub
	}

	public String getID(int i) {
		Object o = get(i);
		if (o instanceof CollectionItem) {
			return ((CollectionItem)o).getID();
		} else {
			return "ID" + i;
		}
	}
	
	public String getDescription(int i) {
		Object o = get(i);
		if (o instanceof CollectionItem) {
			return ((CollectionItem)o).getDescription();
		} else {
			return "";
		}	
	}
	
	public int findID(String s) {
		for (int i = 0; i != size(); i++) {
			if (s.equals(getID(i))) {
				return i;
			}
		}
		
		return -1;
	}
	
	public Object getByID(String s) {
		int i = findID(s);
		if (i != -1) {
			return get(i);
		} else {
			return null;
		}
	}

	public void sort() {
		TreeSet set = new TreeSet(this);
		clear();
		addAll(set);
	}
}
