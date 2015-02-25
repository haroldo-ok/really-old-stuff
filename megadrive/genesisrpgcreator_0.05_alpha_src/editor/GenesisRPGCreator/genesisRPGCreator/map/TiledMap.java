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

import tiled.core.Map;
import tiled.core.Tile;
import tiled.core.TileLayer;
import tiled.core.TileSet;
import genesisRPGCreator.tileset.TiledTileSet;


/**
 * @author Haroldo O. Pinheiro
 *
 * Interfaces RawTileSet with Tiled's Map/TileLayer classes.
 */
public class TiledMap extends RawMap {
	TiledTileSet tileset = null;

	/**
	 * 
	 * @param id_string
	 * @param width
	 * @param height
	 * @param tileset
	 */
	public TiledMap(String id_string, int width, int height, TiledTileSet tileset) {
		super(id_string, width, height);
		this.tileset = tileset;
	}

	
	/**
	 * Builds a Tiled TileLayer object from the current map data and current tileset.
	 * 
	 * @return A Tiled-compatible TileLayer object.
	 */
	public TileLayer getTileLayer() {
		return getTileLayer(tileset.getTileSet());
	}
	
	/**
	 * Builds a Tiled TileLayer object from the current map data and the specified TileSet object.
	 * 
	 * @return A Tiled-compatible TileLayer object.
	 */
	public TileLayer getTileLayer(TileSet t) {
		TileLayer layer = new TileLayer(getWidth(), getHeight());
		
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				Tile tile = t.getTile(getTileAt(x, y));
				layer.setTileAt(x, y, tile);
			}			
		}
		
		return layer;
	}
	
	/**
	 * Builds a Tiled Map object from the current map data and current tileset. 
	 * 
	 * @return A Tiled-compatible Map object.
	 */
	public Map getTiledMap() {
		Map map    = new Map(getWidth(), getHeight());
		TileSet ts = tileset.getTileSet();

		map.setTileWidth(tileset.getTileWidth());
		map.setTileHeight(tileset.getTileHeight());
		map.addTileset(ts);
		map.addLayer(getTileLayer(ts));
		
		return map;
	}

	/**
	 * Imports a Tiled-compatible Map object.
	 * 
	 * @param map
	 */
	public void importTiledMap(Map map) {
		TileLayer layer = (TileLayer)map.getLayer(0);
		
		setSize(map.getWidth(), map.getHeight());
		for (int y = 0; y != getHeight(); y++) {
			for (int x = 0; x != getWidth(); x++) {
				Tile tile = layer.getTileAt(x, y);
				if (tile != null) {
					setTileAt(x, y, tile.getGid());
				}
			}			
		}
	}
}
