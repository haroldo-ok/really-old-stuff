/*
 *  Genesis RPG Creator World Designer, (c) 2005
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */
package genesisRPGCreator.tileset;

import java.awt.Image;
import java.awt.image.BufferedImage;

import tileMolester.core.TMPalette;
import tileMolester.tilecodecs.TileCodec;
import tiled.core.Tile;
import tiled.core.TileSet;

/**
 * @author Haroldo O. Pinheiro
 *
 * Interfaces RawTileSet with Tiled's Tile and TileSet classes,
 * through the use of TileMolester's API.
 */
public class TiledTileSet extends RawTileSet {
	protected TMPalette[] palettes = null;
	protected TileCodec   codec    = null;
	
	public TiledTileSet(String id, TMPalette palette, TileCodec codec) {
		this(id, new TMPalette[] {palette}, codec);
	}

	public TiledTileSet(String id, TMPalette[] palettes, TileCodec codec) {
		super(id);
		this.palettes = palettes;
		this.codec    = codec;
	}

	/**
	 * @return Number of characters in the tileset.
	 */
	public int getCharCount() {
		if (rawdata != null) {
			return rawdata.length / codec.getTileSize();
		}
		
		return 0;
	}	

	/**
	 * @param num Number of the character to decode
	 * @return The decoded char data
	 */
	public int[] getDecodedChar(int num) {
		return codec.decode(rawdata, num*codec.getTileSize(), 0);
	}

	/**
	 * Returns the palette according to the specified index.
	 * Note that the index wraps around: If you specified 5 as an index, 
	 * with only four available palettes, it will return palette 1.
	 * 
	 * @param idx
	 * @return The specified palette
	 */
	public TMPalette getPalette(int idx) {
		if ((palettes == null) || (palettes.length == 0)) {
			return null;
		}
		return palettes[idx % palettes.length];
	}
	
	/**
	 * Returns the pallet number of the specified tile.
	 * 
	 * @param idx The index of the tile
	 * @return The index of the corresponding palette
	 */
	public int getTilePal(int idx) {
		return 0;
	}
	
	/**
     * @param num The tile number
	 * @return An Image object corresponding to the tile
	 */
	public Image getTileImage(int num) {
		BufferedImage img = new BufferedImage(getTileWidth(), getTileHeight(), BufferedImage.TYPE_3BYTE_BGR);

        int[] decodedTile = getDecodedTile(num);
        int   pos         = 0;
        
		for (int tX = 0; tX != getTileCharWidth(); tX++) {
			for (int tY = 0; tY != getTileCharHeight(); tY++) {                
                if ((codec.getBitsPerPixel() <= 8) && (palettes != null)) {
                    // map palette indices to RGB values
                    for (int p=0; p<8; p++) {
                        for (int q=0; q<8; q++) {
                        	int tileidx = decodedTile[pos++];
                        	img.setRGB(tX*8+q, tY*8+p, getPalette(getTilePal(tileidx)).getEntryRGB(tileidx));
                        }
                    }
                }
                else {    
                    // non-palettized: color is actual 32-bit ARGB value
                    for (int p=0; p<8; p++) {
                        for (int q=0; q<8; q++) {
                        	img.setRGB(tX*8+q, tY*8+p, decodedTile[pos++]);
                        }
                    }
                }
			}
		}

		return img;
	}

	/**
	 * @param num The tile number
	 * @return A Tiled-compatible Tile object.
	 */
	public Tile getTile(int num) {
		Tile tile  = new Tile();
		tile.setImage(getTileImage(num));

		return tile;
	}
	
	public TileSet getTileSet() {
		TileSet tileset = new TileSet();
		tileset.setFirstGid(0);
		
		for (int i = 0; i != getTileCount(); i++) {
			Tile tile = getTile(i);
			tile.setId(i);
			tileset.addTile(tile);
		}
		
		return tileset;
	}
}
