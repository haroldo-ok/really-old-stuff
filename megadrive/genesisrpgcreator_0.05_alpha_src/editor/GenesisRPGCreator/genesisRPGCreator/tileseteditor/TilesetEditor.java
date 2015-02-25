/*
 *  Genesis RPG Creator World Designer, (c) 2005
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */

package genesisRPGCreator.tileseteditor;

import java.awt.event.*;
import java.awt.*;
import java.io.FileInputStream;
import java.util.Vector;

import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import tileMolester.colorcodecs.ColorCodec;
import tileMolester.tilecodecs.LinearTileCodec;
import tiled.core.*;
import tiled.mapeditor.util.*;
import tiled.mapeditor.widget.*;

import genesisRPGCreator.BaseFrame;
import genesisRPGCreator.Main;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.tileset.TiledTileSet;
import genesisRPGCreator.util.CollectionVector;
import genesisRPGCreator.util.GenesisTileFileFilter;

public class TilesetEditor extends BaseFrame implements ActionListener,
    TileSelectionListener, ListSelectionListener
{
    private TilePalettePanel pc;
    private TiledTileSet     tileset;
    private Tile             currentTile;
    
    private boolean isnew = false;
    
    JMenu fileMenu = null;
    JMenu helpMenu = null;
    
    JMenuBar menu = null;

    public TilesetEditor() {
        super();
        setTitle("Tileset editor");
        init();
        setSize(new Dimension(300, 200));
    }

    private void init() {
    	createMenuBar();
    	
        pc = new TilePalettePanel();
        pc.setCurrentzoom(2);
        pc.addTileSelectionListener(this);
        JScrollPane paletteScrollPane = new JScrollPane(pc,
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
                JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);

        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(paletteScrollPane, BorderLayout.CENTER);
    }

	private void createMenuBar() {
        fileMenu = new JMenu("File");
        fileMenu.add(createMenuItem("New...",     null, "NewTile",    "Creates a new tileset"                          ));
        fileMenu.addSeparator();
        fileMenu.add(createMenuItem("Open...",    null, "OpenTile",   "Opens an existing tileset"                      ));
        fileMenu.add(createMenuItem("Save...",    null, "SaveTile",   "Saves the current tileset"                      ));
        fileMenu.add(createMenuItem("Save as...", null, "SaveTileAs", "Saves the current tileset with a different name"));
        fileMenu.addSeparator();
        fileMenu.add(createMenuItem("Import raw...",  null, "ImportTile", "Imports a raw tileset"));
        fileMenu.addSeparator();
        fileMenu.add(createMenuItem("Exit", null, "ExitTile", "Exits the tileset editor"));
        
        helpMenu = new JMenu("Help");
        helpMenu.add(createMenuItem("About...", null, "AboutSystem", "About the tileset editor"));

        menu = new JMenuBar();
        menu.add(fileMenu);
        menu.add(helpMenu);
        
        setJMenuBar(menu);
	}

	private JMenuItem createMenuItem(String name, Icon icon, String action, String tt) {
        JMenuItem menuItem = new JMenuItem(name);
        menuItem.addActionListener(this);
        if (icon != null) {
            menuItem.setIcon(icon);
        }
        if (action != null) {
        	menuItem.setActionCommand(action);
        }
        if (tt != null) {
            menuItem.setToolTipText(tt);
        }
        return menuItem;
    }

	public void actionPerformed(ActionEvent e) {
        String cmd = e.getActionCommand();
        Object src = e.getSource();
        
        if (cmd.equals("SaveTile") || cmd.equals("SaveTileAs")) {
        	if (tileset == null) {
    			JOptionPane.showMessageDialog(this, "There's no TileSet to save!","Error",JOptionPane.WARNING_MESSAGE);
        		return;
        	}
        	
        	CollectionVector tilesets = Main.project.getTilesets();
        	
        	String idstring = "";
        	if (cmd.equals("SaveTileAs") || isNew()) {
        		idstring = JOptionPane.showInputDialog(this, "Type an ID for the new TileSet").toUpperCase();
        		if (idstring.trim().equals("")) {
        			JOptionPane.showMessageDialog(this, "ID string can't be empty!","Error",JOptionPane.WARNING_MESSAGE);
        			return;
        		}
        		
        		if (tilesets.findID(idstring) != -1) {
                    int result = JOptionPane.showConfirmDialog(this,
                            "There's already a TileSet with this same ID. " + 
							"Are you sure you want to overwrite it?", 
							"Overwrite TileSet?",
                            JOptionPane.YES_NO_OPTION);
                    if (result != JOptionPane.OK_OPTION) {
                        return;
                    }        			
        		}
        		
            	tileset.setID(idstring);
        	} else {
        		idstring = tileset.getID();
        	}
        	
        	int index = tilesets.findID(idstring);
        	if (index != -1) {
        		tilesets.setElementAt(tileset, index);
        	} else {
        		tilesets.add(tileset);
        	}
        	        	
        	isnew = false;
        } else if (cmd.equals("ImportTile")) {
        	importRawTileset();
        }
    }

	public void tileSelected(TileSelectionEvent event) {
        Tile tile = event.getTile();
        if (tile != null) {
//            editor.setCurrentTile(tile);
        }
    }

    public void valueChanged(ListSelectionEvent e) {
/*        Vector add = new Vector();
        Object[] setlist = sets.getSelectedValues();
        for (int i = 0; i < setlist.length; i++) {
            add.add(setlist[i]);
        }
        pc.setTilesets(add);*/
    
    }
	/**
	 * @return Returns the tileset.
	 */
	public TiledTileSet getTileset() {
		return tileset;
	}
	
	/**
	 * @param tileset The tileset to set.
	 */
	public void setTileset(TiledTileSet tileset) {
		Vector vec   = new Vector();
		this.tileset = tileset;
		
		if (tileset != null) { 
			vec.add(tileset.getTileSet());
		}
        pc.setTilesets(vec);
	}

    /**
	 * Imports a tileset from a raw tileset file 
	 */
	protected void importRawTileset() {
        JFileChooser ch = new JFileChooser();

        ch.setFileFilter(new GenesisTileFileFilter());
        int ret = ch.showOpenDialog(this);
        if (ret == JFileChooser.APPROVE_OPTION) {
            String filename = ch.getSelectedFile().getAbsolutePath();
            try {
            	TiledTileSet tileset = new TiledTileSet("TEST",(PrjPalette)Main.project.getPalettes().get(0), 
            			                                new LinearTileCodec("Sega Genesis", 4, ColorCodec.LITTLE_ENDIAN, "Sega Genesis"));
            	tileset.loadFromStream(new FileInputStream(filename));
            	setTileset(tileset);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
		
	}
	
	/**
	 * @return Tells if the current tileset is new. 
	 */
	public boolean isNew() {
		return isnew;
	}
	
	/**
	 * Creates a new tileset.
	 */
	public void newTileSet() {
		isnew = true;
	}
}
