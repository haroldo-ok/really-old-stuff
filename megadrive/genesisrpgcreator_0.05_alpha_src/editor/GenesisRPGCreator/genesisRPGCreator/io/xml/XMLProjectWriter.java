/*
 * Created on 09/02/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.io.xml;

import genesisRPGCreator.Main;
import genesisRPGCreator.Project;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.tileset.RawTileSet;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Iterator;
import java.util.zip.GZIPOutputStream;

import tiled.io.xml.XMLWriter;
import tiled.io.xml.XMLWriterException;
import tiled.util.Base64;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class XMLProjectWriter extends XMLWriter {
	Writer writer = null;
	Project proj  = null;

	/**
	 * @param writer
	 */
	public XMLProjectWriter(Project proj, OutputStream out) {
		super(new OutputStreamWriter(out));
		this.proj = proj;
	}

	public void saveToStream() throws IOException, XMLWriterException {
		startDocument();
		startElement("GenesisRPGProject");
		writeAttribute("Version",  Double.toString(Main.VERSION_NUMBER));
		writeAttribute("System",   proj.getSystemFactory().getDescription());
		writeAttribute("SystemID", proj.getSystemFactory().getID());
		
		writeSysInfo();
		writePalettes();
		writeTileSets();
		writeMaps();
		
		endElement();
		endDocument();
		flush();
	}
	
	protected void writeSysInfo() throws IOException, XMLWriterException {
		startElement("SystemInfo");
		
		writeAttribute("SystemID",         proj.getSystemFactory().getID());
		writeAttribute("SystemClass",      proj.getSystemFactory().getClass().getName());
		writeAttribute("PaletteCount",     Integer.toString(proj.getSystemFactory().getPaletteCount()));
		writeAttribute("SprPaletteCount",  Integer.toString(proj.getSystemFactory().getSprPaletteCount()));
		writeAttribute("ColorsPerPalette", Integer.toString(proj.getSystemFactory().getPaletteSize()));
		writeAttribute("BitsPerPixel",     Integer.toString(proj.getSystemFactory().getColorCodec().getBitsPerPixel()));
		writeAttribute("ColorCodec",       proj.getSystemFactory().getColorCodec().getClass().getName());
		
		endElement();
	}
	
	protected void writePalettes() throws IOException, XMLWriterException {
		Iterator   palettes = proj.getPalettes().iterator();
		PrjPalette palette  = null;
		
		if (!palettes.hasNext()) {
			return;
		}
		
		startElement("Palettes");			
		while (palettes.hasNext()) {
			palette = (PrjPalette)palettes.next();
			
			startElement("Palette");
			writeAttribute("ID",          palette.getID());
			writeAttribute("Description", palette.getDescription());
			writeAttribute("Size",        Integer.toString(palette.getSize()));
			
			for (int i = 0; i != palette.getSize(); i++) {
				startElement("Color");				
				writeAttribute("Index", Integer.toString(i));
				writeAttribute("RGB",   Integer.toHexString(palette.getEntryRGB(i)));
				endElement();			
			}
			
			endElement();			
		}
		endElement();			
	}
	
	protected void writeTileSets() throws IOException, XMLWriterException {
		Iterator   tilesets = proj.getTilesets().iterator();
		RawTileSet tileset  = null;
		
		if (!tilesets.hasNext()) {
			return;
		}
		
		startElement("TileSets");			
		while (tilesets.hasNext()) {
			tileset = (RawTileSet)tilesets.next();
			
			startElement("TileSet");
			writeAttribute("ID",          tileset.getID());
			writeAttribute("Description", tileset.getDescription());
			writeAttribute("TileCount",   Integer.toString(tileset.getTileCount()));
			writeAttribute("CharWidth",   Integer.toString(tileset.getCharWidth()));
			writeAttribute("CharHeight",  Integer.toString(tileset.getCharHeight()));
			writeAttribute("TileWidth",   Integer.toString(tileset.getTileCharWidth()));
			writeAttribute("TileHeight",  Integer.toString(tileset.getTileCharHeight()));
			
			startElement("Data");
            writeAttribute("encoding",    "base64");
            writeAttribute("compression", "gzip");
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            OutputStream          out  = new GZIPOutputStream(baos);
            
            out.write(tileset.getBytes());
            ((GZIPOutputStream)out).finish();
            
            writeCDATA(new String(Base64.encode(baos.toByteArray())));

            endElement(); // Data			
			endElement(); // TileSet			
		}
		endElement();			
	}

	protected void writeMaps() throws IOException, XMLWriterException {
		Iterator   maps = proj.getMaps().iterator();
		TiledMap   map  = null;
		
		if (!maps.hasNext()) {
			return;
		}
		
		startElement("Maps");			
		while (maps.hasNext()) {
			map = (TiledMap)maps.next();
			
			startElement("Map");
			writeAttribute("ID",          map.getID());
			writeAttribute("Description", map.getDescription());
			writeAttribute("Width",       Integer.toString(map.getWidth()));
			writeAttribute("Height",      Integer.toString(map.getHeight()));
			
			startElement("Data");
            writeAttribute("encoding",    "base64");
            writeAttribute("compression", "gzip");
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            OutputStream          out  = new GZIPOutputStream(baos);
            
            map.saveToStream(out);
            ((GZIPOutputStream)out).finish();
            
            writeCDATA(new String(Base64.encode(baos.toByteArray())));

			endElement(); // Data
			endElement(); // Map			
		}
		endElement();			
	}
}
