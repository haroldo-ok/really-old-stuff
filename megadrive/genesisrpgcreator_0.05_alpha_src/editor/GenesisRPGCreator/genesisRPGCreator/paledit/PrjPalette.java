/*
 * Created on 30/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.paledit;

import genesisRPGCreator.util.CollectionItem;
import tileMolester.colorcodecs.ColorCodec;
import tileMolester.core.TMPalette;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class PrjPalette extends TMPalette implements CollectionItem {
	protected String description = "";

	/**
	 * @param id
	 * @param size
	 * @param codec
	 * @param endianness
	 */
	public PrjPalette(String id, int size, ColorCodec codec, int endianness) {
		super(id, size, codec, endianness);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param id
	 * @param entries
	 * @param codec
	 * @param endianness
	 * @param direct
	 */
	public PrjPalette(String id, int[] entries, ColorCodec codec,
			int endianness, boolean direct) {
		super(id, entries, codec, endianness, direct);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param id
	 * @param bytes
	 * @param offset
	 * @param size
	 * @param codec
	 * @param endianness
	 * @param direct
	 */
	public PrjPalette(String id, byte[] bytes, int offset, int size,
			ColorCodec codec, int endianness, boolean direct) {
		super(id, bytes, offset, size, codec, endianness, direct);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param palette
	 */
	public PrjPalette(TMPalette palette) {
		super(palette);
		// TODO Auto-generated constructor stub
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getDescription()
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @param description The description to set.
	 */
	public void setDescription(String description) {
		this.description = description;
	}
	
	public byte[] getBytes() {
		byte[] data = new byte[2*getSize()];
		
		for(int i = 0; i != data.length; i++) {
			data[i] = 0;
		}
		
		for(int i = 0, j = 0; i != getSize(); i++, j += 2) {
			int entry = getEntryRGB(i);
			data[j  ] = (byte)((entry & 0x0000E0) >> 4);
			data[j+1] = (byte)(((entry & 0x00E000) >> 8) | ((entry & 0xE0E000) >> 20));
		}
		
		return data;	
	}
}
