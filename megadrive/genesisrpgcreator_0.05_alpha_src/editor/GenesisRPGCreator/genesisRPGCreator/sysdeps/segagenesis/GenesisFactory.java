/*
 *  Genesis RPG Creator World Designer, (c) 2004
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */
package genesisRPGCreator.sysdeps.segagenesis;

import tileMolester.colorcodecs.ColorCodec;
import tileMolester.tilecodecs.LinearTileCodec;
import genesisRPGCreator.Main;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.sysdeps.SystemFactoryAdapter;
import genesisRPGCreator.tileset.TiledTileSet;

/**
 * @author Haroldo de Oliveira Pinheiro
 *
 * System-dependant routines for the Sega Genesis
 */
public class GenesisFactory extends SystemFactoryAdapter {

	public GenesisFactory() {
		super();
		colorcodec = new GenesisColorCodec();
	}
	
	/**
	 * @see genesisRPGCreator.util.CollectionItem#getDescription()
	 */
	public String getDescription() {
		return "Sega Genesis / Mega Drive";
	}
	
	/**
	 * @see genesisRPGCreator.util.CollectionItem#getID()
	 */
	public String getID() {
		return "GENESIS";
	}
	
	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getPaletteCount()
	 */
	public int getPaletteCount() {
		return 4;
	}
	
	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getPaletteSize()
	 */
	public int getPaletteSize() {
		return 16;
	}
	
	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getSprPaletteCount()
	 */
	public int getSprPaletteCount() {
		return 0; // The sprite palette is shared with the bkg palette.
	}
	
	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#createTileSet(java.lang.String)
	 */
	public TiledTileSet createTileSet(String id) {
		return new TiledTileSet(id,(PrjPalette)Main.project.getPalettes().get(0), 
                                new LinearTileCodec("Sega Genesis", 4, ColorCodec.LITTLE_ENDIAN, "Sega Genesis"));
	}
}
