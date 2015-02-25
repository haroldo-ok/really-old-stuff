/*
 * Created on 27/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.map;

import genesisRPGCreator.tileset.TiledTileSet;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class ProjMap extends TiledMap {
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

	protected int mapflags = MAP_FLAG_COMPRESS_RDC | MAP_FLAG_BORDER_WRAP;

	/**
	 * @param id_string
	 * @param width
	 * @param height
	 * @param tileset
	 */
	public ProjMap(String id_string, int width, int height, TiledTileSet tileset) {
		super(id_string, width, height, tileset);
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
