/*
 * Created on 30/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator;

import genesisRPGCreator.sysdeps.SystemFactory;
import genesisRPGCreator.util.CollectionVector;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class Project {
	protected CollectionVector palettes = new CollectionVector();
	protected CollectionVector maps     = new CollectionVector();
	protected CollectionVector tilesets = new CollectionVector();
	protected CollectionVector sprites  = new CollectionVector();
	protected CollectionVector scripts  = new CollectionVector();
	
	protected SystemFactory sysfactory = null;
	
	/**
	 * 
	 */
	public Project() {
		super();
	}

	/**
	 * @return Returns the palettes.
	 */
	public CollectionVector getPalettes() {
		return palettes;
	}
	/**
	 * @return Returns the maps.
	 */
	public CollectionVector getMaps() {
		return maps;
	}
	
	/**
	 * @return Returns the scripts.
	 */
	public CollectionVector getScripts() {
		return scripts;
	}

	/**
	 * @return Returns the sprites.
	 */
	public CollectionVector getSprites() {
		return sprites;
	}

	/**
	 * @return Returns the tilesets.
	 */
	public CollectionVector getTilesets() {
		return tilesets;
	}

	/**
	 * @return Returns the SystemFactory object for this project's target system.
	 */
	public SystemFactory getSystemFactory() {
		return sysfactory;
	}

	/**
	 * @param sysfactory The SystemFactory to set.
	 */
	public void setSystemFactory(SystemFactory sysfactory) {
		this.sysfactory = sysfactory;
	}
}
