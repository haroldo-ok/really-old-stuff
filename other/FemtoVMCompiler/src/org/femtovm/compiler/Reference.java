package org.femtovm.compiler;

public class Reference {
	private String label;
	private int address;
	
	public Reference(String label, int address) {
		super();
		this.label = label;
		this.address = address;
	}

	public int getAddress() {
		return address;
	}

	public void setAddress(int address) {
		this.address = address;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}
}
