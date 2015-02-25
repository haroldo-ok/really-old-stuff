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
package genesisRPGCreator.map;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import genesisRPGCreator.util.CollectionItem;
import genesisRPGCreator.util.Util;

/**
 * @author Haroldo O. Pinheiro
 *
 * The basic map data.
 */
public class RawMap implements CollectionItem {
	protected String id_string = null;
	protected String desc_str  = null;
	
	protected int width  = 64;    
	protected int height = 64;
	
	protected int[] mapdata = null;

	/**
	 * 
	 */
	public RawMap(String id_string, int width, int height) {
		super();
		this.id_string = id_string;
		setSize(width, height);
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getID()
	 */
	public String getID() {
		return id_string;
	}

	public void setID(String id) {
		id_string = id;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getDescription()
	 */
	public String getDescription() {
		return desc_str;
	}

	public void setDescription(String desc) {
		desc_str = desc;
	}
	
	/**
	 * @return The map width
	 */
	public int getWidth() {
		return width;
	}

	/**
	 * @return The map height
	 */
	public int getHeight() {
		return height;
	}

	/**
	 * Resizes the map.
	 * WARNING: Previous map data will be lost!
	 * 
	 * @param width
	 * @param height
	 */
	public void setSize(int width, int height) {
		this.width     = width;
		this.height    = height;
		mapdata = new int[width*height];
	}
	
	/**
	 * Returns the index of the tile at the specified x and y coordinates.
	 * If x or y are out of range, returns -1.
	 * 
	 * @param x
	 * @param y
	 * @return The index of the tile at (x,y) 
	 */
	public int getTileAt(int x, int y) {
		if ((x < 0) || (x >= getWidth()) || 
			(y < 0) || (y >= getHeight())) {
			return -1;
		}
		return mapdata[(y*getWidth()) + x];
	}
	
	/**
	 * Sets the index of the map tile at the specified (x,y) coordinates.
	 * If x or y are out of range, this routine has no effect.
	 * 
	 * @param x
	 * @param y
	 * @param tile
	 */
	public void setTileAt(int x, int y, int tile) {
		if ((x < 0) || (x >= getWidth()) || 
			(y < 0) || (y >= getHeight())) {
			return;
		}
		mapdata[(y*getWidth()) + x] = tile;		
	}

	/**
	 * @return The raw map data
	 */
	public int[] getRawMapData() {
		return mapdata;
	}

	/**
	 * Tries to load the tile data from a stream.
	 * Remember: set the size first, or else!
	 * 
	 * @param in The InputStream
	 * @throws IOException
	 */
	public void loadFromStream(InputStream in) throws IOException {
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				int idx = (int)Util.readLongReverse(in);
				if (idx == -1) {
					return;
				}
				
				setTileAt(x, y, idx);
			}			
		}
	}

	/**
	 * Same as loadFromStream(), but considers each byte on the input as a single tile.
	 * 
	 * @see RawMap#loadFromStream(InputStream in)
	 * @param in The InputStream
	 * @throws IOException
	 */
	public void loadFromStreamAsByte(InputStream in) throws IOException {
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				int idx = in.read();
				if (idx == -1) {
					return;
				}
				
				setTileAt(x, y, idx);
			}			
		}
	}

	/**
	 * Writes the map data to an OutputStream.
	 * 
	 * @param os The stream to write to
	 * @throws IOException
	 */
	public void saveToStream(OutputStream os) throws IOException {
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				int idx = getTileAt(x, y);
				Util.writeLongReverse(idx, os);
			}			
		}
	}

	/**
	 * Same as saveToStream(), but writes each single tile as a byte.
	 * 
	 * @see RawMap#saveToStream(OutputStream os) 
	 * @param os The stream to write to
	 * @throws IOException
	 */
	public void saveToStreamAsByte(OutputStream os) throws IOException {
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				int idx = getTileAt(x, y);
				os.write((byte)idx);
			}			
		}
	}
}
