/*
 *  Genesis RPG Creator World Designer, (c) 2004
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */
package genesisRPGCreator;

import javax.swing.JApplet;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class MainApplet extends JApplet {

	/* (non-Javadoc)
	 * @see java.applet.Applet#init()
	 */
	public void init() {
		// TODO Auto-generated method stub
		super.init();
        getContentPane().add(new Main(this, null));
	}
}
