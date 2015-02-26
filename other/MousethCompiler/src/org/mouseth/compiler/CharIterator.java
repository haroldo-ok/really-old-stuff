package org.mouseth.compiler;

public class CharIterator {
	private char[] source;
	private int pos;
	private int line;
	private int column;

	public CharIterator(char[] source) {
		super();
		this.source = source;
		this.pos = 0;
		this.line = 1;
		this.column = 1;
	}
	
	public char getChar() {
		return source[this.pos];
	}
	
	public boolean hasNext() {
		return this.pos < this.getSource().length - 1;
	}
	
	public boolean pastEnd() {
		return this.pos >= this.getSource().length;
	}
	
	public char next() {
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

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		StringBuffer sb = new StringBuffer();
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
