/*
 * Created on 10/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.tileseteditor;

import java.awt.BorderLayout;
import java.util.Vector;

import genesisRPGCreator.BaseFrame;
import genesisRPGCreator.Main;
import genesisRPGCreator.tileset.TiledTileSet;
import genesisRPGCreator.widgets.CollectionManager;

import javax.swing.BorderFactory;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.event.ListSelectionEvent;

import tiled.mapeditor.util.TileSelectionEvent;
import tiled.mapeditor.util.TileSelectionListener;
import tiled.mapeditor.widget.TilePalettePanel;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class TilesetManager extends BaseFrame implements TileSelectionListener {
	protected CollectionManager tilecollection = null;
    protected TilePalettePanel  pc             = null;
    protected JScrollPane       preview        = null; 

	/**
	 * 
	 */
	public TilesetManager() {
		super();
		// TODO Auto-generated constructor stub
		setTitle("Tileset Manager");
        setSize(418, 400);

		// Tileset list
		tilecollection = new TilesetCollectionManager(Main.project.getTilesets()) {
			public void valueChanged(ListSelectionEvent e) {
				super.valueChanged(e);
				updateTilesetPreview();	
			}
		};
		
		// Tileset preview
        pc = new TilePalettePanel();
        pc.setCurrentzoom(2);
        pc.addTileSelectionListener(this);
        
        preview = new JScrollPane(pc, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
//        preview.setVisible(false);
        
/*        JPanel previewpnl = new JPanel();
        previewpnl.setLayout(new BorderLayout());
//		previewpnl.add(preview, BorderLayout.CENTER);
		previewpnl.add(pc, BorderLayout.CENTER);*/

		// The split panel
		JSplitPane splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, true);
        splitPane.setBorder(BorderFactory.createEmptyBorder(0, 0, 0, 0));
        splitPane.setResizeWeight(0.25);
        splitPane.setTopComponent(tilecollection);
        splitPane.setBottomComponent(preview);

        getRootPane().setLayout(new BorderLayout());
		getRootPane().add(splitPane, BorderLayout.CENTER);
		
		updateTilesetPreview();
	}

	/* (non-Javadoc)
	 * @see tiled.mapeditor.util.TileSelectionListener#tileSelected(tiled.mapeditor.util.TileSelectionEvent)
	 */
	public void tileSelected(TileSelectionEvent e) {
		// TODO Auto-generated method stub		
	}

	private void updateTilesetPreview() {
		Vector       vec  = new Vector();
		TiledTileSet item = (TiledTileSet)tilecollection.getSelectedItem();
		if(item != null) {
		   vec.add(item.getTileSet());
           pc.setTilesets(vec);
		}
	}
}
