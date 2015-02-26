package org.mouseth.compiler;

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

public class Compiler {
	
	public static final int MTH_INS_INVALID = 0;
	public static final int MTH_INS_NOP = 1;
	public static final int MTH_INS_ENDPROGRAM = 2;
	public static final int MTH_INS_CALL = 3;
	public static final int MTH_INS_RETURN = 4;
	public static final int MTH_INS_BRANCHZ = 5;
	public static final int MTH_INS_LOAD = 6;
	public static final int MTH_INS_STORE = 7;
	public static final int MTH_INS_ADD = 8;
	public static final int MTH_INS_SUB = 9;
	public static final int MTH_INS_SHIFTL = 10;
	public static final int MTH_INS_SHIFTR = 11;
	public static final int MTH_INS_OR = 12;
	public static final int MTH_INS_AND = 13;
	public static final int MTH_INS_NOT = 14;
	public static final int MTH_INS_EQUALS = 15;
	public static final int MTH_INS_LESS = 16;
	public static final int MTH_INS_GREATER = 17;
	public static final int MTH_INS_SYSCALL = 18;

	public static final int MTH_INS_NUMBER_MASK = 0x80;
	public static final int MTH_INS_NUMBER_UNMASK = 0x7F;

	public static final int MTH_MEM_EXITCODE = 0;
	public static final int MTH_MEM_MEMSIZE = 1;
	public static final int MTH_MEM_PC = 2;
	public static final int MTH_MEM_CURRENTCODE = 3;
	public static final int MTH_MEM_APC = 4;
	public static final int MTH_MEM_AUXCODE = 5;
	public static final int MTH_MEM_CODESP = 6;
	public static final int MTH_MEM_CODESP_BASE = 7;
	public static final int MTH_MEM_DATASP = 8;
	public static final int MTH_MEM_DATASP_BASE = 9;

	public static final int MTH_MEM_IO = 16;
	public static final int MTH_MEM_IO1 = 17;
	public static final int MTH_MEM_IO2 = 18;
	public static final int MTH_MEM_IO3 = 19;
	public static final int MTH_MEM_IO4 = 20;
	public static final int MTH_MEM_IO5 = 21;
	public static final int MTH_MEM_IO6 = 22;
	public static final int MTH_MEM_IO7 = 23;

	public static final int MTH_MEM_SYS = 24;
	public static final int MTH_MEM_SYS1 = 25;
	public static final int MTH_MEM_SYS2 = 26;
	public static final int MTH_MEM_SYS3 = 27;
	public static final int MTH_MEM_SYS4 = 28;
	public static final int MTH_MEM_SYS5 = 29;
	public static final int MTH_MEM_SYS6 = 30;
	public static final int MTH_MEM_SYS7 = 31;

	public static final int MTH_PROGRAM_DEFAULT_START_ADDRESS = 1024;
	public static final int MTH_MEM_DEFAULT_START_VAR = 128;

	private char[] source;
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
		this.startAddress = MTH_PROGRAM_DEFAULT_START_ADDRESS;
		this.nextVar = MTH_MEM_DEFAULT_START_VAR;
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
		CharIterator it = new CharIterator(this.source);
		try {
			bos = new ByteArrayOutputStream();
			labels = new HashMap<String, Integer>();
			references = new ArrayList<Reference>();
			vars = new HashMap<String, Integer>();
			
			while (!it.pastEnd()) {
				switch (it.getChar()) {
				case '(':
					StringBuffer cmd = new StringBuffer();
					it.next();
					while (it.getChar() != ')') {
						cmd.append(it.getChar());
						it.next();
					}
					it.next();
					this.processCommand(cmd.toString());
					break;
					
				case '\"':
					StringBuffer str = new StringBuffer();
					str.append('\"');
					it.next();
					while (it.getChar() != '\"') {
						if (it.getChar() == '\\') {
							str.append(it.getChar());
							it.next();
						}
						str.append(it.getChar());
						it.next();
					}
					str.append('\"');
					it.next();
					bos.write(str.toString().getBytes());
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
					StringBuffer num = new StringBuffer();
					while (it.getChar() >= '0' && it.getChar() <= '9') {
						num.append(it.getChar());
						it.next();
					}
					this.processNumber(num);
					break;
	
				case ' ':
				case '\t':
				case '\n':
				case '\r':
					it.next();
					break;
					
				case '~':
					while (!it.pastEnd() && it.getChar() != '\n') {
						it.next();
					}
					break;

				default:
					bos.write(it.getChar());
					it.next();
					break;
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
	
	protected void resolveReferences(byte[] bin) {
		for (Reference ref : this.references) {
			Integer value = this.labels.get(ref.getLabel());
			if (value == null) {
				throw new RuntimeException("Label not found for \"" + ref.getLabel() + "\"");
			}
			
			byte[] code = this.encodeNumber(value);
			for (int i = 0; i != code.length; i++) {
				bin[ref.getAddress() + i] = code[i];
			}
		}
	}

	protected void processNumber(StringBuffer num) throws IOException {
		String s = num.toString();
		byte[] bytes = this.encodeNumber(s);
		bos.write(bytes);
	}

	protected byte[] encodeNumber(String s) {
		int n = Integer.parseInt(s);
		return encodeNumber(n);
	}

	protected byte[] encodeNumber(int n) {
		byte[] bytes = new byte[] {(byte)((n >> 8) & 0xFF | 0x80), (byte)(n & 0xFF)};
		return bytes;
	}
	
	protected void processCommand(String cmd) throws IOException {
		if ("".equals(cmd)) {
			bos.write('(');
		} else if (cmd.length() == 1) {
			byte[] bytes = this.encodeNumber(cmd.charAt(0));
			bos.write(bytes);
		} else if (cmd.length() != 0 && cmd.charAt(0) >= '0' && cmd.charAt(0) <= '9') {
			bos.write(Integer.parseInt(cmd));
		} else if (cmd.charAt(0) == '.') {
			String ref = cmd.substring(1);
			addLabel(ref);			
		} else if (cmd.charAt(0) == ':') {
			String ref = cmd.substring(1);
			this.addReference(ref);			
		} else if (cmd.charAt(0) == '_') {
			String ref = cmd.substring(1);
			Integer var = autoVar(ref);
			bos.write(this.encodeNumber(var));
		} else if (cmd.charAt(0) == '=') {
			String[] parms = cmd.substring(1).trim().split(" ");
			defineVar(parms[0], Integer.parseInt(parms[1]));
		} else {
			byte[] bytes = this.getCommands().get(cmd.trim());
			if (bytes == null) {
				throw new RuntimeException("Invalid command: \"" + cmd + "\"");
			}
			bos.write(bytes);
		}
	}

	protected void addLabel(String ref) {
		labels.put(ref, bos.size() + this.startAddress);
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

			this.commands.put("invalid", new byte[] {MTH_INS_INVALID});
			this.commands.put("nop", new byte[] {MTH_INS_NOP});
			this.commands.put("end", new byte[] {MTH_INS_ENDPROGRAM});
			this.commands.put("call", new byte[] {MTH_INS_CALL});
			this.commands.put("ret", new byte[] {MTH_INS_RETURN});
			this.commands.put("brz", new byte[] {MTH_INS_BRANCHZ});
			this.commands.put("ld", new byte[] {MTH_INS_LOAD});
			this.commands.put("sto", new byte[] {MTH_INS_STORE});
			this.commands.put("add", new byte[] {MTH_INS_ADD});
			this.commands.put("sub", new byte[] {MTH_INS_SUB});
			this.commands.put("shl", new byte[] {MTH_INS_SHIFTL});
			this.commands.put("shr", new byte[] {MTH_INS_SHIFTR});
			this.commands.put("or", new byte[] {MTH_INS_OR});
			this.commands.put("and", new byte[] {MTH_INS_AND});
			this.commands.put("not", new byte[] {MTH_INS_NOT});
			this.commands.put("eq", new byte[] {MTH_INS_EQUALS});
			this.commands.put("lt", new byte[] {MTH_INS_LESS});
			this.commands.put("gt", new byte[] {MTH_INS_GREATER});
			this.commands.put("sys", new byte[] {MTH_INS_SYSCALL});

			this.commands.put("EXITCODE", encodeNumber(MTH_MEM_EXITCODE));
			this.commands.put("MEMSIZE", encodeNumber(MTH_MEM_MEMSIZE));
			this.commands.put("PC", encodeNumber(MTH_MEM_PC));
			this.commands.put("CURRENTCODE", encodeNumber(MTH_MEM_CURRENTCODE));
			this.commands.put("APC", encodeNumber(MTH_MEM_APC));
			this.commands.put("AUXCODE", encodeNumber(MTH_MEM_AUXCODE));
			this.commands.put("CODESP", encodeNumber(MTH_MEM_CODESP));
			this.commands.put("CODESP_BASE", encodeNumber(MTH_MEM_CODESP_BASE));
			this.commands.put("DATASP", encodeNumber(MTH_MEM_DATASP));
			this.commands.put("DATASP_BASE", encodeNumber(MTH_MEM_DATASP_BASE));

			this.commands.put("IO", encodeNumber(MTH_MEM_IO));
			this.commands.put("IO1", encodeNumber(MTH_MEM_IO1));
			this.commands.put("IO2", encodeNumber(MTH_MEM_IO2));
			this.commands.put("IO3", encodeNumber(MTH_MEM_IO3));
			this.commands.put("IO4", encodeNumber(MTH_MEM_IO4));
			this.commands.put("IO5", encodeNumber(MTH_MEM_IO5));
			this.commands.put("IO6", encodeNumber(MTH_MEM_IO6));
			this.commands.put("IO7", encodeNumber(MTH_MEM_IO7));

			this.commands.put("SYS", encodeNumber(MTH_MEM_SYS));
			this.commands.put("SYS1", encodeNumber(MTH_MEM_SYS1));
			this.commands.put("SYS2", encodeNumber(MTH_MEM_SYS2));
			this.commands.put("SYS3", encodeNumber(MTH_MEM_SYS3));
			this.commands.put("SYS4", encodeNumber(MTH_MEM_SYS4));
			this.commands.put("SYS5", encodeNumber(MTH_MEM_SYS5));
			this.commands.put("SYS6", encodeNumber(MTH_MEM_SYS6));
			this.commands.put("SYS7", encodeNumber(MTH_MEM_SYS7));
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
			int startAddress = MTH_PROGRAM_DEFAULT_START_ADDRESS;
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
