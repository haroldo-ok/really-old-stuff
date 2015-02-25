/*
 * Created on 26/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.sysdeps.segagenesis;

import tileMolester.colorcodecs.IndexedColorCodec;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GenesisColorCodec extends IndexedColorCodec {

	/**
	 * @param id
	 * @param bitsPerPixel
	 * @param colorTable
	 * @param description
	 */
	public GenesisColorCodec() {
		super("GENESIS", 9, getGenesisColorTable(), "Sega Genesis Color Codec");
		// TODO Auto-generated constructor stub
	}

	public static int[] getGenesisColorTable() {
		int pal[] = new int[512];
		for(int i = 0; i != 512; i++){
			int r = (i >> 6) & 0x07;
			int g = (i >> 3) & 0x07;
			int b = (i >> 0) & 0x07;
			
			pal[i] = (r << 21) | (g << 13) | (b << 5);
		}

		return pal;
	}
}
