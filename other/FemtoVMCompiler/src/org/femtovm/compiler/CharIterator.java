package org.femtovm.compiler;

public class CharIterator {
	private char[] source;
	private String name;
	private int pos;
	private int line;
	private int column;
	private CharIterator include;

	public CharIterator(char[] source) {
		super();
		this.source = source;
		this.name = null;
		this.pos = 0;
		this.line = 1;
		this.column = 1;
		this.include = null;
	}
	
	public CharIterator(char[] source, String name) {
		super();
		this.source = source;
		this.name = name;
		this.pos = 0;
		this.line = 1;
		this.column = 1;
		this.include = null;
	}
	
	public char getChar() {
		if (this.getInclude() != null) {
			return this.getInclude().getChar();
		}
		return this.source[this.pos];
	}
	
	public boolean hasNext() {
		if (this.getInclude() != null && this.getInclude().hasNext()) {
			return true;
		}
		return this.pos < this.getSource().length - 1;
	}
	
	public boolean pastEnd() {
		if (this.getInclude() != null) {
			return false;
		}
		return this.pos >= this.getSource().length;
	}
	
	public char next() {
		if (this.getInclude() != null) {
			return this.getInclude().next();
		}
		
		this.pos++;
		this.column++;
		
		if (this.pastEnd()) {
			return 0;
		}
		
		char ch = this.getChar();
		if (ch == '\n') {
			this.line++;
			this.column = 1;
		}
		return ch;
	}

	/**
	 * @return Returns the charnum.
	 */
	public int getPos() {
		return pos;
	}

	/**
	 * @return Returns the column.
	 */
	public int getColumn() {
		return column;
	}

	/**
	 * @return Returns the line.
	 */
	public int getLine() {
		return line;
	}

	/**
	 * @return Returns the source.
	 */
	public char[] getSource() {
		return source;
	}
	
	public CharIterator getInclude() {
		if (this.include != null) {
			if (this.include.pastEnd()) {
				this.include = null;
			}
		}
		return this.include;
	}

	public void setInclude(CharIterator include) {
		this.include = include;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		if (this.getInclude() != null) {
			return this.getInclude().toString();
		}
		
		StringBuffer sb = new StringBuffer();
		if (this.name != null) {
			sb.append("(").append(this.line).append(") ");			
		}
		sb.append("Line ").append(this.line);
		sb.append(", ");
		sb.append("Column ").append(this.column);
		sb.append("\n");

		int startPos = this.pos - this.column + 2;
		if (startPos < 0) {
			startPos = 0;
		}
		
		for (int i = startPos; i < this.source.length
				&& this.source[i] != '\n'; i++) {
			sb.append(this.source[i]);
		}
		sb.append('\n');

		for (int i = startPos; i < this.source.length && i < this.pos; i++) {
			if (this.source[i] == '\n') {
				sb.append('\t');
			} else {
				sb.append(' ');					
			}
		}
		sb.append('^');
		
		return sb.toString();
	}
}
