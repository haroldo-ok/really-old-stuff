/*
 * Created on 14/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.mapeditor;

import java.awt.event.ActionEvent;
import java.util.AbstractList;

import genesisRPGCreator.Main;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.widgets.CollectionManager;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class MapCollectionManager extends CollectionManager {
	/**
	 * @param collection
	 */
	public MapCollectionManager(AbstractList collection) {
		super(collection);
		// TODO Auto-generated constructor stub
	}

	/* (non-Javadoc)
	 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
		if(e.getSource().equals(buttonadd)) {
			if (collection != null) {
			}
		} else if(e.getSource().equals(buttonedit)) {
        	if(getSelectedIndex() != -1) {
        	    MapEditor maped = (MapEditor)Main.getInstance().addInternalFrame(new MapEditor());
        		maped.loadMap((TiledMap)getSelectedItem());
        	}
		} else if(e.getSource().equals(buttonclone)) {
			
		} else if(e.getSource().equals(buttondel)) {
			
		} else {
			super.actionPerformed(e);		
		}
	}
}
