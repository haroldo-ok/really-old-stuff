/*
 * Created on 23/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.gfs;

import genesisRPGCreator.util.Util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GFSDirEntry {
	protected String filename = "";
	protected int    size     = 0; 
	protected int    offs     = 0; 

	/**
	 * 
	 */
	public GFSDirEntry() {
		super();
		// TODO Auto-generated constructor stub
	}

	public GFSDirEntry(String filename) {
		this();
		setFileName(filename);
	}

	public GFSDirEntry(String filename, int size, int offs) {
		this(filename);
		setSize(size);
		setOffs(offs);
	}
	
	public byte[] getBytes() throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		
		bos.write(getGFSFileName());
		bos.write(0x00);
		bos.write(0x00); // 2 bytes filler
		Util.writeLongReverse(getOffs(), bos);
		Util.writeLongReverse(getSize(), bos);
		
		return bos.toByteArray();
	}
	
	static public int getEntrySize() {
		return 22;
	}

	/**
	 * @return Returns the filename.
	 */
	public String getFileName() {
		return filename;
	}

	/**
	 * @param filename The filename to set.
	 */
	public void setFileName(String filename) {
		String name = filename.trim().toUpperCase();
		String ext  = "";
		
		int dotidx = name.lastIndexOf('.');
		if(dotidx != -1) {
			ext  = name.substring(dotidx);
			name = name.substring(0, dotidx);
			if(ext.length() > 4) {
				ext = ext.substring(0, 4);				
			}
			if(name.length() > 8) {
				name = name.substring(0, 8);				
			}
			
			filename = name + ext;
		} else {
			if(name.length() > 8) {
				name = name.substring(0, 8);				
			}
			filename = name;
		}
		
		this.filename = filename;
	}

	/**
	 * @return Returns the filename.
	 */
	public byte[] getGFSFileName() {
		byte[] fname = new byte[12];
		String name = getFileName();
		String ext  = "";

		int dotidx = name.lastIndexOf('.');
		if(dotidx != -1) {
			ext  = name.substring(dotidx);
			name = name.substring(0, dotidx);
		}
		if(ext.length() > 4) {
			ext = ext.substring(0, 4);				
		}
		if(name.length() > 8) {
			name = name.substring(0, 8);				
		}

		for(int i = 0; i != fname.length; i++) {
			fname[i] = ' ';
		}
		for(int i = 0; i != name.length(); i++) {
			fname[i] = (byte)name.charAt(i);
		}
		for(int i = 0; i != ext.length(); i++) {
			fname[i+8] = (byte)ext.charAt(i);
		}
		
		return fname;
	}

	/**
	 * @return Returns the offs.
	 */
	public int getOffs() {
		return offs;
	}

	/**
	 * @param offs The offs to set.
	 */
	public void setOffs(int offs) {
		this.offs = offs;
	}

	/**
	 * @return Returns the size.
	 */
	public int getSize() {
		return size;
	}

	/**
	 * @param size The size to set.
	 */
	public void setSize(int size) {
		this.size = size;
	}
}
