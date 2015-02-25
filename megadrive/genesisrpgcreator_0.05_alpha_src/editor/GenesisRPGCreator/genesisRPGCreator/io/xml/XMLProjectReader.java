/*
 * Created on 10/02/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.io.xml;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Vector;
import java.util.zip.GZIPInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import genesisRPGCreator.Main;
import genesisRPGCreator.Project;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.sysdeps.segagenesis.GenesisFactory;
import genesisRPGCreator.tileset.TiledTileSet;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import tiled.util.Base64;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class XMLProjectReader {
	Document doc  = null;
	Project  proj = null;

	/**
	 * 
	 */
	public XMLProjectReader() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Project loadFromStream(InputStream in) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            doc = builder.parse(in);
        } catch (SAXException e) {
            e.printStackTrace();
            throw new Exception("Error while parsing project file: "+e.toString());
        }
        
        proj = buildProject();
        return proj;
	}
	
	public Project buildProject() throws Exception {
		Node root = doc.getDocumentElement();
		proj      = new Project();
		
		proj.setSystemFactory(new GenesisFactory());

		if (!root.getNodeName().equals("GenesisRPGProject")) {
			throw new Exception("This isn't a valid Genesis RPG Creator Project!");
		}
		
		NodeList nodes = root.getChildNodes();
		for (int i = 0; i != nodes.getLength(); i++) {
			Node item = nodes.item(i);
			if (item.getNodeName().equals("Palettes")) {
				buildPalettes(proj.getPalettes(), item);
			}
			if (item.getNodeName().equals("TileSets")) {
				buildTileSets(proj.getTilesets(), item);
			}
			if (item.getNodeName().equals("Maps")) {
				buildMaps(proj, item);
			}
		}

        return proj;
	}

	/**
	 * @param palettes
	 * @param item
	 */
	private void buildPalettes(Vector palettes, Node item) {
		NodeList nodes = item.getChildNodes();
		for (int i = 0; i != nodes.getLength(); i++) {
			Node child = nodes.item(i);
			if (child.getNodeName().equals("Palette")) {
				String id_str   = getAttributeValue(child, "ID");
				String desc_str = getAttributeValue(child, "Description");
				int    colorcnt = Integer.parseInt(getAttributeValue(child, "Size"));

				PrjPalette tmpal = Main.project.getSystemFactory().createPalette(id_str);
				tmpal.setDescription(desc_str);

				NodeList entries = child.getChildNodes();
				for (int j = 0; j != entries.getLength(); j++) {
					Node entry = entries.item(j);
					if (entry.getNodeName().equals("Color")) {
						int index = Integer.parseInt(getAttributeValue(entry, "Index"));
						int rgb   = Integer.parseInt(getAttributeValue(entry, "RGB"), 16);
						tmpal.setEntryRGB(index, rgb);
					}
				}
				
				palettes.add(tmpal);
			}
		}
	}

	/**
	 * @param tilesets
	 * @param item
	 * @throws IOException
	 */
	private void buildTileSets(Vector tilesets, Node item) throws IOException {
		NodeList nodes = item.getChildNodes();
		for (int i = 0; i != nodes.getLength(); i++) {
			Node child = nodes.item(i);
			if (child.getNodeName().equals("TileSet")) {
				String id_str   = getAttributeValue(child, "ID");
				String desc_str = getAttributeValue(child, "Description");
				
				TiledTileSet tileset = Main.project.getSystemFactory().createTileSet(id_str);
				tileset.setDescription(desc_str);
			
				NodeList entries = child.getChildNodes();
				for (int j = 0; j != entries.getLength(); j++) {
					Node entry = entries.item(j);
					if (entry.getNodeName().equals("Data")) {
		                String encoding = getAttributeValue(entry, "encoding");

		                if (encoding != null && encoding.equalsIgnoreCase("base64")) {
		                    Node cdata = entry.getChildNodes().item(0);
		                	if(cdata != null) {
		                        char[] enc = cdata.getNodeValue().trim().toCharArray();
		                        byte[] dec = Base64.decode(enc);
		                        ByteArrayInputStream bais = new ByteArrayInputStream(dec);
		                        InputStream is;	                		

		                        String comp = getAttributeValue(entry, "compression");

		                        if (comp != null && comp.equalsIgnoreCase("gzip")) {
		                            is = new GZIPInputStream(bais);
		                        } else {
		                            is = bais;
		                        }
		                        
		                        tileset.loadFromStream(is);
		                	}
		                }
					}
				}

				tilesets.add(tileset);
			}
		}
	}

	/**
	 * @param maps
	 * @param item
	 * @throws IOException
	 */
	private void buildMaps(Project proj, Node item) throws IOException {
		NodeList nodes = item.getChildNodes();
		for (int i = 0; i != nodes.getLength(); i++) {
			Node child = nodes.item(i);
			if (child.getNodeName().equals("Map")) {
				String id_str   = getAttributeValue(child, "ID");
				String desc_str = getAttributeValue(child, "Description");
				int    width    = Integer.parseInt(getAttributeValue(child, "Width"));
				int    height   = Integer.parseInt(getAttributeValue(child, "Height"));
				
				TiledMap map = proj.getSystemFactory().createMap(id_str, proj);
				map.setDescription(desc_str);
				map.setSize(width, height);
			
				NodeList entries = child.getChildNodes();
				for (int j = 0; j != entries.getLength(); j++) {
					Node entry = entries.item(j);
					if (entry.getNodeName().equals("Data")) {
		                String encoding = getAttributeValue(entry, "encoding");

		                if (encoding != null && encoding.equalsIgnoreCase("base64")) {
		                    Node cdata = entry.getChildNodes().item(0);
		                	if(cdata != null) {
		                        char[] enc = cdata.getNodeValue().trim().toCharArray();
		                        byte[] dec = Base64.decode(enc);
		                        ByteArrayInputStream bais = new ByteArrayInputStream(dec);
		                        InputStream is;	                		

		                        String comp = getAttributeValue(entry, "compression");

		                        if (comp != null && comp.equalsIgnoreCase("gzip")) {
		                            is = new GZIPInputStream(bais);
		                        } else {
		                            is = bais;
		                        }
		                        
		                        map.loadFromStream(is);
		                	}
		                }
					}
				}

				proj.getMaps().add(map);
			}
		}
	}

	private String getAttributeValue(Node node, String attribname) {
        NamedNodeMap attributes = node.getAttributes();
        String att = null;
        if (attributes != null) {
            Node attribute = attributes.getNamedItem(attribname);
            if (attribute != null) {
                att = attribute.getNodeValue();
            }
        }
        return att;
    }
}
