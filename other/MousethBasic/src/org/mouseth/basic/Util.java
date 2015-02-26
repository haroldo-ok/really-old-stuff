package org.mouseth.basic;

import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

public class Util {
	int sequence = 0;
	
	public List<Object> flatten(Object[] array) {
		List<Object> list = this.flatten(Arrays.asList(array));
		return list;
	}

	public List<Object> flatten(Collection col) {
		List<Object> list = new LinkedList<Object>();
		for (Object o : col) {			
			if (o.getClass().isArray()) {
				List<Object> flatten = this.flatten(Arrays.asList((Object[])o));
				list.addAll(flatten);
			} else if (o instanceof Collection) {
				list.addAll(this.flatten((Collection)o));
			} else {
				list.add(o);
			}
		}
		return list;
	}
	
	public String dump(Object[] array, int startIndex) {
		Object[] tmp = this.flatten(array).toArray();
		StringBuffer sb = new StringBuffer();
		for (int i = startIndex; i != tmp.length; i++) {
			sb.append(tmp[i]);
		}
		return sb.toString();
	}
	
	public int getSequence() {
		return this.sequence++;
	}
}
