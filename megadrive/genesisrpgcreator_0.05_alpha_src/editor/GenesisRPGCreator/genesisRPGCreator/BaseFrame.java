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

import javax.swing.JInternalFrame;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class BaseFrame extends JInternalFrame {
    public BaseFrame(){
    	super();
    	setClosable(true);
    	setMaximizable(true);
    	setIconifiable(true);
    	setResizable(true);
    	
    	setSize(320, 240);
    }
}
