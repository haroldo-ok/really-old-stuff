/*
 * Created on 23/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.io;

import genesisRPGCreator.sysdeps.segagenesis.GenesisColorCodec;
import genesisRPGCreator.tileset.TiledTileSet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Stack;

import tileMolester.colorcodecs.ColorCodec;
import tileMolester.core.TMPalette;
import tileMolester.tilecodecs.LinearTileCodec;
import tiled.core.Map;
import tiled.core.TileSet;
import tiled.io.MapReader;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GenesisMapReader implements MapReader {

	/**
	 * 
	 */
	public GenesisMapReader() {
		super();
		// TODO Auto-generated constructor stub
	}

	/* (non-Javadoc)
	 * @see tiled.io.MapReader#readMap(java.lang.String)
	 */
	public Map readMap(String filename) throws Exception {
		// TODO Auto-generated method stub
		throw new Exception("readMap not implemented."); 		
	}

	/* (non-Javadoc)
	 * @see tiled.io.MapReader#readTileset(java.lang.String)
	 */
	public TileSet readTileset(String filename) throws Exception {
        return readTileset(new FileInputStream(filename));
	}

	/* (non-Javadoc)
	 * @see tiled.io.MapReader#readMap(java.io.InputStream)
	 */
	public Map readMap(InputStream in) throws Exception {
		// TODO Auto-generated method stub
		throw new Exception("readMap not implemented."); 		
	}

	/* (non-Javadoc)
	 * @see tiled.io.MapReader#readTileset(java.io.InputStream)
	 */
	public TileSet readTileset(InputStream in) throws Exception {
		ColorCodec codec = new GenesisColorCodec();
		TMPalette  tmpal = new TMPalette("", 16, codec, 0);
		
		tmpal.setEntryRGB( 0, 0x000000);
		tmpal.setEntryRGB( 1, 0x000080);
		tmpal.setEntryRGB( 2, 0x008000);
		tmpal.setEntryRGB( 3, 0x008080);
		tmpal.setEntryRGB( 4, 0x800000);
		tmpal.setEntryRGB( 5, 0x800080);
		tmpal.setEntryRGB( 6, 0x808000);
		tmpal.setEntryRGB( 7, 0x808080);
		tmpal.setEntryRGB( 8, 0x606060);
		tmpal.setEntryRGB( 9, 0x6060FF);
		tmpal.setEntryRGB(10, 0x60FF60);
		tmpal.setEntryRGB(11, 0x60FFFF);
		tmpal.setEntryRGB(12, 0xFF6060);
		tmpal.setEntryRGB(13, 0xFF60FF);
		tmpal.setEntryRGB(14, 0xFFFF60);
		tmpal.setEntryRGB(15, 0xFFFFFF);

		TiledTileSet tiles = new TiledTileSet("", tmpal, new LinearTileCodec("Sega Genesis", 4, ColorCodec.LITTLE_ENDIAN, "Sega Genesis"));
		tiles.loadFromStream(in);
		
		return tiles.getTileSet();
	}

	/* (non-Javadoc)
	 * @see tiled.io.PluggableMapIO#getFilter()
	 */
	public String getFilter() throws Exception {
		// TODO Auto-generated method stub
		return ".til";
	}

	/* (non-Javadoc)
	 * @see tiled.io.PluggableMapIO#getName()
	 */
	public String getName() {
		// TODO Auto-generated method stub
		return "Genesis RPG Creator map/tileset reader";
	}

	/* (non-Javadoc)
	 * @see tiled.io.PluggableMapIO#getDescription()
	 */
	public String getDescription() {
		// TODO Auto-generated method stub
		return "Genesis RPG Creator map/tileset reader";
	}

	/* (non-Javadoc)
	 * @see tiled.io.PluggableMapIO#getPluginPackage()
	 */
	public String getPluginPackage() {
		// TODO Auto-generated method stub
        return "Genesis RPG Creator";
    }

	/* (non-Javadoc)
	 * @see tiled.io.PluggableMapIO#setErrorStack(java.util.Stack)
	 */
	public void setErrorStack(Stack es) {
		// TODO Auto-generated method stub

	}

	/* (non-Javadoc)
	 * @see java.io.FileFilter#accept(java.io.File)
	 */
	public boolean accept(File pathname) {
        try {
            String path = pathname.getCanonicalPath().toLowerCase();
            if (path.endsWith(".til")) {
                return true;
            }
        } catch (IOException e) {}
        return false;
	}

}
