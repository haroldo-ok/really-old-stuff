package genesisRPGCreator.io;


import genesisRPGCreator.map.GenesisMap;

import java.io.*;
import java.util.LinkedList;
import java.util.Stack;

import tiled.core.Map;
import tiled.core.Tile;
import tiled.core.TileLayer;
import tiled.core.TileSet;
import tiled.io.MapWriter;

public class GenesisMapWriter implements MapWriter
{
    private LinkedList chunks;

    public GenesisMapWriter() {
        chunks = new LinkedList();
    }

    /**
     * Loads a map from a file.
     *
     * @param filename the filename of the map file
     */
    public void writeMap(Map map, String filename) throws Exception {
        writeMap(map, new FileOutputStream(filename));
    }
                                                                                
    public void writeMap(Map map, OutputStream out) throws Exception {
    	writeHeader(map, out);
    }
    
    void writeHeader(Map map, OutputStream out) throws Exception  {
    	GenesisMap gmap = null;
    	if (map instanceof GenesisMap) {
    		gmap = (GenesisMap)map;
    	}

    	// Header
        out.write("MAP".getBytes());   	
        out.write(0);
        
        // Version
        out.write(GenesisMap.MAP_VERSION >> 8);   	
        out.write(GenesisMap.MAP_VERSION & 0xFF);
        
        // Map flags
        int flags = 0;
        if (gmap != null){
        	flags = gmap.getMapFlags();
        }       
        out.write(flags >> 8);   	
        out.write(flags & 0xFF);

        // Width/Height
        int width  = map.getWidth();
        int height = map.getHeight();
        out.write(width >> 8);   	
        out.write(width & 0xFF);
        out.write(height >> 8);   	
        out.write(height & 0xFF);
        
        // Object count        
        out.write(0);
        out.write(0); 
        
        // Reserved        
        out.write(0xFF);
        out.write(0xFF);
        
        // Writes the map
        out.write(packMap(map));
    }
    
    byte[] packMap(Map map) {
    	byte[]    b     = new byte[map.getWidth()*map.getHeight()];
    	int       pos   = 0;
    	TileLayer layer = (TileLayer)map.getLayer(0);

    	for (int i = 0; i != map.getHeight(); i++) {
        	for (int j = 0; j != map.getWidth(); j++) {
        		Tile t = layer.getTileAt(j, i);
        		if (t != null) {
        			b[pos] = (byte)t.getGid();
        		} else {
        			b[pos] = 0;        			
        		}
        	}    		
    	}
    	
    	return b;
    }
    
    /**
     * @see tiled.io.MapReader#getFilter()
     */
    public String getFilter() throws Exception {
        return "*.map";
    }
                                                                                
    public String getDescription() {
        return "Genesis RPG Creator map writer";
    }
                                                                                
    public String getPluginPackage() {
        return "Genesis RPG Creator";
    }

    public String getName() {
        return "Genesis RPG Creator map writer";
    }
                                                                                
    public boolean accept(File pathname) {
        try {
            String path = pathname.getCanonicalPath().toLowerCase();
            if (path.endsWith(".map")) {
                return true;
            }
        } catch (IOException e) {}
        return false;
    }

    public void setErrorStack(Stack es) {
        // TODO: implement setErrorStack
    }

	/* (non-Javadoc)
	 * @see tiled.io.MapWriter#writeTileset(tiled.core.TileSet, java.lang.String)
	 */
	public void writeTileset(TileSet set, String filename) throws Exception {
		throw new Exception("writeTileset not implemented."); 		
	}

	/* (non-Javadoc)
	 * @see tiled.io.MapWriter#writeTileset(tiled.core.TileSet, java.io.OutputStream)
	 */
	public void writeTileset(TileSet set, OutputStream out) throws Exception {
		// TODO Auto-generated method stub
		throw new Exception("writeTileset not implemented.");	
	}    
}
