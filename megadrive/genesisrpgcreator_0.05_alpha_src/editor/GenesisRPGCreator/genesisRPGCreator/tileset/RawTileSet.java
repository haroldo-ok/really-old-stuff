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

import genesisRPGCreator.util.CollectionItem;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * @author Haroldo O. Pinheiro
 * 
 * Base tileset
 */
public class RawTileSet implements CollectionItem {
	protected byte   rawdata[] = null;
	protected String id_string = null;
	protected String desc_str  = "";

	/**
	 * 
	 */
	public RawTileSet(String id) {
		super();
		id_string = id;
	}
	
	public String getID() {
		return id_string;
	}
	
	public void setID(String id) {
		id_string = id;
	}
	
	public String getDescription() {
		return desc_str;
	}
	
	public void setDescription(String desc) {
		desc_str = desc;
	}
	
	/**
	 * Reads the raw tileset data from a stream. Any previous data is lost.
	 * 
	 * @param is The input stream from where the data will be read
	 * @throws IOException
	 */
	public void loadFromStream(InputStream is) throws IOException {
		/* This routine works around the limitations of certain InputStreams */
		BufferedInputStream bis = new BufferedInputStream(is);
		bis.mark(0xFFFFFF);
		while(bis.available() != 0) {
			bis.read();
		}
		bis.reset();
		
		/* That's where the reading is actually done. */
		rawdata = new byte[bis.available()];
		bis.read(rawdata);
	}

	/**
	 * Writes the raw tileset data to a stream.
	 * 
	 * @param os Where the data will be written to
	 * @throws IOException
	 */
	public void loadFromStream(OutputStream os) throws IOException {
		os.write(rawdata);
	}
	
	/**
	 * @return The raw tileset data
	 */
	public byte[] getBytes() {
		return rawdata;
	}
	
	/**
	 * Replaces current raw tileset data with a new one.
	 * 
	 * @param bt The new raw tileset data
	 */
	public void setBytes(byte[] bt) {
		rawdata = bt;
	}
	
	public int getCharWidth() {
		return 8;
	}
	
	public int getCharHeight() {
		return 8;
	}
	
	public int getCharPixelCount() {
		return getCharWidth()*getCharHeight();
	}
	
	public int getTileCharWidth() {
		return 2;
	}
	
	public int getTileCharHeight() {
		return 2;
	}
	
	public int getTileWidth() {
		return getTileCharWidth()*getCharWidth();
	}
	
	public int getTileHeight() {
		return getTileCharHeight()*getCharHeight();
	}
	
	public int getTileCharCount() {
		return getTileCharWidth()*getTileCharHeight();
	}
	
	public int getTilePixelCount() {
		return getTileCharCount()*getCharPixelCount();
	}
	
	/**
	 * Dummy proc. Should be properly implemented by descendant classes.
	 * 
	 * @return Number of characters in the tileset.
	 */
	public int getCharCount() {
		return 0;
	}	
	
	/** 
	 * @return The tilecount.
	 */
	public int getTileCount() {
		return getCharCount() / getTileCharCount();
	}

	/**
	 * Dummy proc. Should be properly implemented by descendant classes.
	 * 
	 * @param num Number of the character to decode
	 * @return The decoded char data
	 */
	public int[] getDecodedChar(int num) {
		return null;
	}

	/**
	 * @param num Number of the character to decode
	 * @return The decoded tile data
	 */
	public int[] getDecodedTile(int num) {
		int tile[] = new int[getTilePixelCount()];
		
		for (int i = getTileCharCount(), pos = 0, tileid = num*getTileCharCount(); i != 0; i--, tileid++) {
			int buf[] = getDecodedChar(tileid);
			System.arraycopy(buf, 0, tile, pos, buf.length);
			pos += buf.length;
		}
		
		return tile;
	}

	/**
	 * Dummy proc. Should be properly implemented by descendant classes.
	 * 
	 * @return The whole decoded data
	 */
	public int[] getDecodedData() {
		int data[] = new int[getCharCount()*getCharPixelCount()];
		
		for (int i = getCharCount(), pos = 0, tileid = 0; i != 0; i--, tileid++) {
			int buf[] = getDecodedChar(tileid);
			System.arraycopy(buf, 0, data, pos, buf.length);
			pos += buf.length;
		}
		
		return data;
	}
}
