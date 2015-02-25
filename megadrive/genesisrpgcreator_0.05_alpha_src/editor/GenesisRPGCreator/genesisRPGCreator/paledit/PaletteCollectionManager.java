/*
 * Created on 30/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.paledit;

import java.awt.event.ActionEvent;
import java.util.AbstractList;

import javax.swing.JOptionPane;

import tileMolester.core.TMPalette;

import genesisRPGCreator.Main;
import genesisRPGCreator.widgets.CollectionManager;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class PaletteCollectionManager extends CollectionManager {

	/**
	 * @param collection
	 */
	public PaletteCollectionManager(AbstractList collection) {
		super(collection);
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.widgets.CollectionManager#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
		if(e.getSource().equals(buttonadd)) {
			if (collection != null) {
				String idstring = JOptionPane.showInputDialog(this, "Type an ID for the new Palette").toUpperCase();
				if (idstring.trim().equals("")) {
					JOptionPane.showMessageDialog(this, "ID string can't be empty!","Error",JOptionPane.WARNING_MESSAGE);
					return;
				}
				
				TMPalette tmpal = Main.project.getSystemFactory().createPalette(idstring);
				
				addItem(tmpal);
			}
		} else if(e.getSource().equals(buttonclone)) {
			
		} else if(e.getSource().equals(buttondel)) {
			
		} else {
			super.actionPerformed(e);		
		}
	}
}
