/*
 * Created on 10/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.tileseteditor;

import java.awt.event.ActionEvent;
import java.util.AbstractList;

import genesisRPGCreator.Main;
import genesisRPGCreator.tileset.TiledTileSet;
import genesisRPGCreator.widgets.CollectionManager;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class TilesetCollectionManager extends CollectionManager {

	/**
	 * @param collection
	 */
	public TilesetCollectionManager(AbstractList collection) {
		super(collection);
		// TODO Auto-generated constructor stub
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.widgets.CollectionManager#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
		if(e.getSource().equals(buttonadd)) {
			if (collection != null) {
/*				String idstring = JOptionPane.showInputDialog(this, "Type an ID for the new Palette").toUpperCase();
				if (idstring.trim().equals("")) {
					JOptionPane.showMessageDialog(this, "ID string can't be empty!","Error",JOptionPane.WARNING_MESSAGE);
					return;
				}
				
				ColorCodec codec = new GenesisColorCodec();
				TMPalette  tmpal = new PrjPalette(idstring, 16, codec, 0);
				
				tmpal.setEntryRGB( 0, 0x000000);
				tmpal.setEntryRGB( 1, 0x000080);
				tmpal.setEntryRGB( 2, 0x008000);
				tmpal.setEntryRGB( 3, 0x008080);
				tmpal.setEntryRGB( 4, 0x800000);
				tmpal.setEntryRGB( 5, 0x800080);
				tmpal.setEntryRGB( 6, 0x808000);
				tmpal.setEntryRGB( 7, 0x808080);
				tmpal.setEntryRGB( 8, 0x606060);
				tmpal.setEntryRGB( 9, 0x6060FF);
				tmpal.setEntryRGB(10, 0x60FF60);
				tmpal.setEntryRGB(11, 0x60FFFF);
				tmpal.setEntryRGB(12, 0xFF6060);
				tmpal.setEntryRGB(13, 0xFF60FF);
				tmpal.setEntryRGB(14, 0xFFFF60);
				tmpal.setEntryRGB(15, 0xFFFFFF);
				
				addItem(tmpal);*/
			}
		} else if(e.getSource().equals(buttonedit)) {
        	if(getSelectedIndex() != -1) {
        	    TilesetEditor tseted = (TilesetEditor)Main.getInstance().addInternalFrame(new TilesetEditor());
        		tseted.setTileset((TiledTileSet)getSelectedItem());
        	}
		} else if(e.getSource().equals(buttonclone)) {
			
		} else if(e.getSource().equals(buttondel)) {
			
		} else {
			super.actionPerformed(e);		
		}
	}
	
}
