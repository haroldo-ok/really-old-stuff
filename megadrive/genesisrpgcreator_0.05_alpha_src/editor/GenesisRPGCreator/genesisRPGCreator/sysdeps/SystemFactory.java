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
package genesisRPGCreator.sysdeps;

import tileMolester.colorcodecs.ColorCodec;
import genesisRPGCreator.Project;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.tileset.TiledTileSet;
import genesisRPGCreator.util.CollectionItem;

/**
 * @author Haroldo de Oliveira Pinheiro
 *
 * Base interface for handling system-dependant routines
 */
public interface SystemFactory extends CollectionItem {
	/**
	 * @return A new project, properly configured for the target system
	 */
	Project createProject();
	
	/**
	 * @return The number of simultaneous palettes the system can display
	 */
	int getPaletteCount();

	/**
	 * @return The number of simultaneous palettes for the sprites (0 if it shares palletes with the bkg)
	 */
	int getSprPaletteCount();

	/**
	 * @return The number of colors per palette
	 */
	int getPaletteSize();
	
	/**
	 * @return A color codec object, apropriate for the target system
	 */
	ColorCodec getColorCodec();

	/**
	 * @return A palette object, apropriate for the target system
	 */
	PrjPalette createPalette(String id);

	/**
	 * @return A tileset object, apropriate for the target system
	 */
	TiledTileSet createTileSet(String id);

	/**
	 * @return A map object, apropriate for the target system
	 */
	TiledMap createMap(String id, Project proj);
}
