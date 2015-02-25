/*
 * Created on 14/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.mapeditor;

import java.awt.BorderLayout;

import javax.swing.event.ListSelectionEvent;

import genesisRPGCreator.BaseFrame;
import genesisRPGCreator.Main;
import genesisRPGCreator.widgets.CollectionManager;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class MapManager extends BaseFrame {
	protected CollectionManager mapcollection = null;

	/**
	 * 
	 */
	public MapManager() {
		super();
		setTitle("Map Manager");
        setSize(418, 400);

        // The map list
        mapcollection = new MapCollectionManager(Main.project.getMaps()) {
			public void valueChanged(ListSelectionEvent e) {
				super.valueChanged(e);
			}
		};
		
		// The map properties
//		JPanel bottompanel = new JPanel();

		getRootPane().setLayout(new BorderLayout());
		getRootPane().add(mapcollection, BorderLayout.CENTER);
	}

}
