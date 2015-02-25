/*
 * Created on 20/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.map;

import tiled.core.Map;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GenesisMap extends Map {
	public static final int MAP_VERSION = 0x0001;
	
	public static final int MAP_FLAG_UNCOMPRESSED = 0x0000;
	/* RDC Compressed map. It will be uncompressed into RAM
	   and then treated as an uncompressed map */
	public static final int MAP_FLAG_COMPRESS_RDC = 0x0001;
	/* RLE Compressed map. It will be uncompressed "on the fly" */
	public static final int MAP_FLAG_COMPRESS_RLE = 0x0002;

	public static final int MAP_FLAG_BORDER_STOP = 0x0000;
	public static final int MAP_FLAG_BORDER_WRAP = 0x0010;
	public static final int MAP_FLAG_BORDER_WARP = 0x0020;

	protected int mapflags = MAP_FLAG_COMPRESS_RDC | MAP_FLAG_COMPRESS_RLE;

	/**
	 * @param width  The map width, in tiles.
	 * @param height Tha map height, in tiles.
	 */
	public GenesisMap(int width, int height) {
		super(width, height);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return Returns the map flags.
	 */
	public int getMapFlags() {
		return mapflags;
	}
	/**
	 * @param mapflags The map flags to set.
	 */
	public void setMapFlags(int mapflags) {
		this.mapflags = mapflags;
	}
}
