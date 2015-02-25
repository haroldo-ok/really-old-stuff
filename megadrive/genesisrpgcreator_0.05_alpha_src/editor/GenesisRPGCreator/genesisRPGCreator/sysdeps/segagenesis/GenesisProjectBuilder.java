/*
 * Created on 18/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.sysdeps.segagenesis;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Iterator;

import genesisRPGCreator.Project;
import genesisRPGCreator.gfs.GFS;
import genesisRPGCreator.map.ProjMap;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.sysdeps.ProjectBuilder;
import genesisRPGCreator.tileset.TiledTileSet;
import genesisRPGCreator.util.RDCOutputStream;
import genesisRPGCreator.util.ResourceItem;
import genesisRPGCreator.util.Util;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GenesisProjectBuilder extends ProjectBuilder {

	/**
	 * 
	 */
	public GenesisProjectBuilder() {
		super();
		// TODO Auto-generated constructor stub
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.ProjectBuilder#translateProject(genesisRPGCreator.Project)
	 */
	public void translateProject(Project proj) throws Exception {
		super.translateProject(proj);
		ByteArrayOutputStream bos = new ByteArrayOutputStream();

		// Adds the runtime code
		InputStream stub = getClass().getResourceAsStream("/genesisRPGCreator/sysdeps/segagenesis/resource/stub.bin");
		for(int i = 0; i != 0x10000; i++) {
			bos.write(stub.read());
		}
		
		// Appends the data
		GFS gfs = new GFS();
		gfs.add((new ResourceItem("CHAR1.RDC",    "java:/genesisRPGCreator/sysdeps/segagenesis/resource/CHAR1.RDC"   )).loadFromFile());
		gfs.add((new ResourceItem("TILESET1.RDC", "java:/genesisRPGCreator/sysdeps/segagenesis/resource/TILESET1.RDC")).loadFromFile());
		gfs.add((new ResourceItem("FONT.CHR",     "java:/genesisRPGCreator/sysdeps/segagenesis/resource/FONT.CHR"    )).loadFromFile());
		gfs.add((new ResourceItem("INTERFC.TIL",  "java:/genesisRPGCreator/sysdeps/segagenesis/resource/INTERFC.TIL" )).loadFromFile());
		gfs.add((new ResourceItem("PLAYER.RDC",   "java:/genesisRPGCreator/sysdeps/segagenesis/resource/PLAYER.RDC"  )).loadFromFile());
		gfs.add((new ResourceItem("TEST.ZBC",     "java:/genesisRPGCreator/sysdeps/segagenesis/resource/TEST.ZBC"    )).loadFromFile());
		
		translatePalettes(proj, gfs);
		translateTilesets(proj, gfs);
		translateMaps(proj, gfs);

		bos.write(gfs.getData());
		
		// Dumps the combined binary data
		rawdata = bos.toByteArray();
	}
	
	protected void translatePalettes(Project proj, GFS gfs) {
		Iterator palettes = proj.getPalettes().iterator();
		while(palettes.hasNext()) {
			PrjPalette   pal = (PrjPalette)palettes.next();
			ResourceItem res = new ResourceItem(pal.getID() + ".PAL", "");
			
			res.setData(pal.getBytes());
			gfs.add(res);
		}
	}

	protected void translateTilesets(Project proj, GFS gfs) throws IOException {
		Iterator tilesets = proj.getTilesets().iterator();
		while(tilesets.hasNext()) {
			TiledTileSet tls = (TiledTileSet)tilesets.next();
			ResourceItem res = new ResourceItem(tls.getID() + ".TLC", "");
			
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			RDCOutputStream       rdc = new RDCOutputStream(bos);
			
			rdc.write(tls.getBytes());
			rdc.close();
			res.setData(bos.toByteArray());
			gfs.add(res);
		}
	}
	
	protected void translateMaps(Project proj, GFS gfs) throws Exception {
		Iterator maps = proj.getMaps().iterator();
		while(maps.hasNext()) {
			TiledMap     tlm = (TiledMap)maps.next();
			ResourceItem res = new ResourceItem(tlm.getID() + ".MAP", "");
			
			ByteArrayOutputStream data = new ByteArrayOutputStream();
			writeMapHeader(tlm, data);
			writeMapData(tlm, data);

			res.setData(data.toByteArray());
			gfs.add(res);
		}
	}

	void writeMapHeader(TiledMap map, OutputStream out) throws Exception  {
    	// Header
        out.write("MAP".getBytes());   	
        out.write(0);
        
        // Version
        Util.writeShortReverse(ProjMap.MAP_VERSION, out);
        
        // Map flags
        int flags = ProjMap.MAP_FLAG_COMPRESS_RDC | ProjMap.MAP_FLAG_BORDER_WRAP;
        Util.writeShortReverse(flags, out);

        // Width/Height
        Util.writeShortReverse(map.getWidth(), out);
        Util.writeShortReverse(map.getHeight(), out);
        
        // Palette id #'s
        Util.writeShortReverse(0, out);
        Util.writeShortReverse(0, out);
        Util.writeShortReverse(0, out);
        Util.writeShortReverse(0, out);
        
        // TileSet id #
        Util.writeShortReverse(0, out);
        
        // Object count        
        Util.writeShortReverse(0, out);
    }
	
	void writeMapData(TiledMap map, OutputStream out) throws Exception  {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		RDCOutputStream       rdc = new RDCOutputStream(bos);
	
		map.saveToStreamAsByte(rdc);
        rdc.close();
        
        out.write(bos.toByteArray());
	}
}
