package org.femtovm.compiler;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

public class Compiler {
	
/*	public static final int FEV_INS_NOP = 0;
	public static final int FEV_INS_ENDPROGRAM = 1;
	public static final int FEV_INS_CALL = 2;
	public static final int FEV_INS_RETURN = 3;
	public static final int FEV_INS_BRANCHZ = 4;
	public static final int FEV_INS_NOT = 5;
	public static final int FEV_INS_OR = 6;
	public static final int FEV_INS_AND = 7;
	public static final int FEV_INS_LOADB = 8;
	public static final int FEV_INS_STOREB = 9;
	public static final int FEV_INS_LOADW = 10;
	public static final int FEV_INS_STOREW = 11;
	public static final int FEV_INS_ADD = 12;
	public static final int FEV_INS_SUB = 13;
	public static final int FEV_INS_SHIFTL = 14;
	public static final int FEV_INS_SHIFTR = 15;
	public static final int FEV_INS_LESS = 16;
	public static final int FEV_INS_GREATER = 17;
	public static final int FEV_INS_EQUALS = 18;
	public static final int FEV_INS_CHANNEL = 19;
	public static final int FEV_INS_INPUT = 20;
	public static final int FEV_INS_OUTPUT = 21;*/

	public static final int FEV_INS_MASK = 0x8000;
	public static final int FEV_INS_UNMASK = 0x7FFF;

	public static final int FEV_PROGRAM_DEFAULT_START_ADDRESS = 0;
	public static final int FEV_MEM_DEFAULT_START_VAR_ADDRESS = 30 * 1024;

	private char[] source;
	private CharIterator it;
	private ByteArrayOutputStream bos;
	private Map<String, byte[]> commands;
	private Map<String, Integer> labels;
	private List<Reference> references;
	private Map<String, Integer> vars;
	private int startAddress;
	private int nextVar;
	
	public Compiler(char[] source) {
		super();
		this.source = source;
		this.startAddress = FEV_PROGRAM_DEFAULT_START_ADDRESS;
		this.nextVar = FEV_MEM_DEFAULT_START_VAR_ADDRESS;
	}
	
	public Compiler(String source) {
		this(source.toCharArray());
	}
	
	public Compiler(Reader source) throws IOException {
		this(processReader(source));
	}
	
	private static String processReader(Reader reader) throws IOException {
		StringBuffer sb = new StringBuffer();
		BufferedReader br = new BufferedReader(reader);
		try {
			String s = null;
			while ((s = br.readLine()) != null) {
				sb.append(s).append('\n');
			}
		} finally {
			br.close();
		}
		return sb.toString();
	}
	
	public byte[] compile() {
		this.it = new CharIterator(this.source);
		try {
			bos = new ByteArrayOutputStream();
			labels = new HashMap<String, Integer>();
			references = new ArrayList<Reference>();
			vars = new HashMap<String, Integer>();
			
			while (!it.pastEnd()) {
				String token = this.getToken(it);
				if (token != null && !"".equals(token.trim())) {
					switch (token.charAt(0)) {
					case ';': // Comment; do nothing
						break;
						
					case '#': // Compiler directive
						this.processDirective(token);
						break;
						
					case '@': // Code label
						this.processLabel(token);
						break;
						
					case '$': // Var declaration/reference
						this.processVar(token);
						break;
						
					case '\"': // String literal
						this.processString(token);
						break;
						
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9': // Numeric constant
						this.processNumber(token);
						break;
						
					default: // Identifier/Symbol
						this.processIdentifier(token);
					}
				}
			}
			bos.close();
			byte[] bin = bos.toByteArray();
			this.resolveReferences(bin);
			return bin;
		} catch (IOException e) {
			throw new RuntimeException(e); 
		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append(e.getMessage()).append('\n');
			sb.append(it);
			throw new RuntimeException(sb.toString(), e);
		}
	}
	
	protected void processIdentifier(String token) {
		this.addReference(token);
	}

	protected void processNumber(String token) {
		try {
			bos.write(this.encodeNumber(token));
		} catch (IOException e) {
			throw new RuntimeException("Error encoding number " + token, e);
		}
	}

	protected void processString(String token) {
		token = token.substring(1, token.length()-1);
		char[] ca = token.toCharArray();
		for (int i = 0; i < ca.length; i++) {
			char ch = ca[i];
			if (ch == '\\') {
				i++;
				ch = ca[i];
				switch (ch) {
				case 't':
					this.bos.write('\t');
					break;
					
				case 'b':
					this.bos.write('\b');
					break;
					
				case 'r':
					this.bos.write(13);
					break;
					
				case 'n':
					this.bos.write(10);
					break;
				default:
					this.bos.write(ch);					
				}
			} else {
				this.bos.write(ch);									
			}
		}
		this.bos.write(0);
		if (this.bos.size() % 2 != 0) {
			this.bos.write(0);			
		}
	}

	protected void processVar(String token) {
		String name = token.substring(1);
		this.autoVar(name);
	}

	protected void processLabel(String token) {
		String label = token.substring(1);
		this.addLabel(label);		
	}

	protected void processDirective(String token) {
		String directive = token.substring(1);
		
		StringTokenizer st = new StringTokenizer(directive);
		List<String> tokens = new ArrayList<String>();
		while (st.hasMoreElements()) {
			tokens.add(st.nextToken());
		}
		
		String[] tk = tokens.toArray(new String[tokens.size()]);
		if ("defword".equals(tk[0])) {
			this.labels.put(tk[1], Integer.parseInt(tk[2]));			
			this.vars.put(tk[1], Integer.parseInt(tk[2]));			
		} else if ("defvar".equals(tk[0])) {
			this.vars.put(tk[1], Integer.parseInt(tk[2]));			
		} else if ("include".equals(tk[0])) {
//			
//			this.it.setInclude(include)
		}
	}

	protected String getToken(CharIterator it) {
		StringBuilder sb = new StringBuilder();
		
		while (!it.pastEnd() && Character.isWhitespace(it.getChar())) {
			it.next();
		}
		
		if (it.pastEnd()) {
			return null;
		}
		
		switch (it.getChar()) {
		case '@':
		case '$':
			sb.append(it.getChar());			
			it.next();
			
			if (!Character.isLetter(it.getChar()) && it.getChar() != '_') {
				throw new RuntimeException("Invalid token '" + it.getChar() + "'. Expected identifier start.");
			}
			sb.append(it.getChar());
			it.next();
			
			while (!it.pastEnd() && (Character.isLetterOrDigit(it.getChar()) || it.getChar() == '_')) {
				sb.append(it.getChar());
				it.next();
			}
			break;
			
		case '\"':
			sb.append('\"');
			it.next();
			while (it.getChar() != '\"') {
				if (it.getChar() == '\\') {
					sb.append(it.getChar());
					it.next();
				}
				sb.append(it.getChar());
				it.next();
			}
			sb.append('\"');
			it.next();
			break;
			
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			while (it.getChar() >= '0' && it.getChar() <= '9') {
				sb.append(it.getChar());
				it.next();
			}
			break;

		case '#':
		case ';':
			while (!it.pastEnd() && it.getChar() != '\n') {
				sb.append(it.getChar());
				it.next();
			}
			break;

		default:
			sb.append(it.getChar());			
			it.next();
			
			while (!it.pastEnd() && (Character.isLetterOrDigit(it.getChar()) || it.getChar() == '_')) {
				sb.append(it.getChar());
				it.next();
			}
			break;
		}

		return sb.toString();
	}
	
	protected void resolveReferences(byte[] bin) {
		for (Reference ref : this.references) {
			Integer value = this.labels.get(ref.getLabel());
			if (value == null) {
				throw new RuntimeException("Label not found for \"" + ref.getLabel() + "\"");
			}
			
			byte[] code = this.encodeCall(value);
			for (int i = 0; i != code.length; i++) {
				bin[ref.getAddress() + i] = code[i];
			}
		}
	}
	
	protected String convertString(String s) {
		if (!s.startsWith("\"")) {
			return s;
		}
		
		StringBuilder sb = new StringBuilder();

		s = s.substring(1, s.length()-1);
		char[] ca = s.toCharArray();
		for (int i = 0; i < ca.length; i++) {
			char ch = ca[i];
			if (ch == '\\') {
				i++;
				ch = ca[i];
				switch (ch) {
				case 't':
					sb.append('\t');
					break;
					
				case 'b':
					sb.append('\b');
					break;
					
				case 'r':
					sb.append(13);
					break;
					
				case 'n':
					sb.append(10);
					break;
				default:
					sb.append(ch);					
				}
			} else {
				sb.append(ch);									
			}
		}
		
		return sb.toString();
	}
	
	protected byte[] encodeNumber(String s) {
		int n = Integer.parseInt(s);
		return encodeNumber(n);
	}

	protected byte[] encodeNumber(int n) {
		byte[] bytes = new byte[] {(byte)(n & 0xFF), (byte)((n >> 8) & 0xFF)};
		return bytes;
	}
	
	protected byte[] encodeCall(int n) {
		byte[] bytes = this.encodeNumber(n | FEV_INS_MASK);
		return bytes;
	}

	protected void addLabel(String ref) {
		int address = bos.size() + this.startAddress;
		this.labels.put(ref, address);
		this.defineVar(ref, address);
	}

	protected void addReference(String ref) {
		references.add(new Reference(ref, bos.size()));
		bos.write(0);			
		bos.write(0);
	}

	protected void defineVar(String ref, Integer var) {
		this.vars.put(ref, var);
	}

	protected Integer autoVar(String ref) {
		Integer var = this.vars.get(ref);
		if (var != null) {
			return var;
		}
		
		Collection<Integer> usedVars = this.vars.values();
		while (usedVars.contains(this.nextVar)) {
			this.nextVar++;
		}
		
		var = this.nextVar;
		this.vars.put(ref, var);
		this.nextVar++;
		
		return var;
	}

	protected Map<String, byte[]> getCommands() {
		if (this.commands == null) {
			this.commands = new HashMap<String, byte[]>();
		}
		return this.commands;
	}

	public int getStartAddress() {
		return startAddress;
	}
	public void setStartAddress(int startAddress) {
		this.startAddress = startAddress;
	}
	
	public static void main(String[] args) {
		try {
			String inFile = null;
			String outFile = null;
			int startAddress = FEV_PROGRAM_DEFAULT_START_ADDRESS;
			int i = 0;
			for (i = 0; i < args.length; i++) {
				String arg = args[i];
				if (!"".equals(arg)) {
					if (arg.startsWith("-")) {
						if ("-a".equals(arg)) {
							i++;
							startAddress = Integer.parseInt(args[i]);
						}
					} else {
						if (inFile == null) {
							inFile = arg;
						} else if (outFile == null) {
							outFile = arg;
						}
					}
				}
			}
			
			Reader rd = new FileReader(inFile);
			OutputStream out = new FileOutputStream(outFile);
			Compiler compiler = new Compiler(rd);
			compiler.setStartAddress(startAddress);
			byte[] prog = compiler.compile();
			out.write(prog);
			out.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
