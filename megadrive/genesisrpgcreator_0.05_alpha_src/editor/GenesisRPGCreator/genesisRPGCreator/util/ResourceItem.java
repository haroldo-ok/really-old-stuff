/*
 * Created on 19/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.util;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class ResourceItem implements CollectionItem, Comparable {
	protected String id_str      = "";
	protected String description = "";
	protected String origin      = "";
	protected byte[] data        = null;
	protected int    offs        = 0;

	/**
	 * 
	 */
	public ResourceItem() {
		super();
		// TODO Auto-generated constructor stub
	}

	public ResourceItem(String id, String origin) {
		this();
		setID(id);
		setOrigin(origin);
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getID()
	 */
	public String getID() {
		return id_str;
	}

	/**
	 * @param id_str The ID to set.
	 */
	public void setID(String id_str) {
		this.id_str = id_str;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getDescription()
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @param description The description to set.
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/* (non-Javadoc)
	 * @see java.lang.Comparable#compareTo(java.lang.Object)
	 */
	public int compareTo(Object o) {
		return getID().compareTo(((CollectionItem)o).getID());
	}

    private String makeUrl(String filename) throws MalformedURLException {
        String url = "";
        if(filename.indexOf("://") > 0 || filename.startsWith("file:")) {
            url = filename;
        } else {
            url = (new File(filename)).toURL().toString();
        }
        return url;
    }
    
	/**
	 * @return Returns the origin of the resource.
	 */
	public String getOrigin() {
		return origin;
	}
	
	/**
	 * @param origin The origin to set.
	 */
	public void setOrigin(String origin) {
		this.origin = origin;
	}
	
	/**
	 * @return Returns the data.
	 */
	public byte[] getData() {
		return data;
	}
	
	/**
	 * @param data The data to set.
	 */
	public void setData(byte[] data) {
		this.data = data;
	}
	
	public void loadFromStream(InputStream is) throws IOException {
		/* This routine works around the limitations of certain InputStreams */
		BufferedInputStream bis = new BufferedInputStream(is);
		bis.mark(0xFFFFFF);
		while(bis.available() != 0) {
			bis.read();
		}
		bis.reset();
		
		/* That's where the reading is actually done. */
		data = new byte[bis.available()];
		bis.read(data);
	}
	
	public void saveToStream(OutputStream os) throws IOException {
		os.write(data);
	}

	public void loadFromFile(String filename) throws FileNotFoundException, IOException {
		String origin = makeUrl(filename); 
		setOrigin(origin);
		
		InputStream is     = null;
		String      prefix = "java:";
		if(filename.startsWith(prefix)) {
			is = getClass().getResourceAsStream(filename.substring(prefix.length()));
			if (is == null) {
				throw new IOException("Resource " + filename.substring(prefix.length()) + " not found");
			}
		} else {
			is = new URL(origin).openStream();
		}
		loadFromStream(is);
	}
	
	public ResourceItem loadFromFile() throws FileNotFoundException, IOException {
		loadFromFile(getOrigin());
		return this;
	}
	
	/**
	 * @return Returns the offset of the data inside the resource file.
	 */
	public int getOffs() {
		return offs;
	}
	/**
	 * @param offs The new offset of the data inside the resource file.
	 */
	public void setOffs(int offs) {
		this.offs = offs;
	}
	
	public int getSize() {
		return data.length;
	}
}
