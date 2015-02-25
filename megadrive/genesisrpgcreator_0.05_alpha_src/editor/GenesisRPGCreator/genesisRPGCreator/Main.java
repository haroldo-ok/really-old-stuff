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
package genesisRPGCreator;

import genesisRPGCreator.io.xml.XMLProjectReader;
import genesisRPGCreator.io.xml.XMLProjectWriter;
import genesisRPGCreator.mapeditor.MapEditor;
import genesisRPGCreator.mapeditor.MapManager;
import genesisRPGCreator.paledit.PaletteEditor;
import genesisRPGCreator.sysdeps.ProjectBuilder;
import genesisRPGCreator.sysdeps.segagenesis.GenesisFactory;
import genesisRPGCreator.sysdeps.segagenesis.GenesisProjectBuilder;
import genesisRPGCreator.sysdeps.segagenesis.GenesisROMFileFilter;
import genesisRPGCreator.themes.BlueTheme;
import genesisRPGCreator.tileseteditor.TilesetEditor;
import genesisRPGCreator.tileseteditor.TilesetManager;
import genesisRPGCreator.util.GenesisProjectFileFilter;
import genesisRPGCreator.util.RDCOutputStream;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsEnvironment;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.beans.PropertyVetoException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Vector;

import javax.imageio.ImageIO;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JApplet;
import javax.swing.JDesktopPane;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JInternalFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.RootPaneContainer;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.plaf.metal.MetalLookAndFeel;

import com.jgoodies.plaf.plastic.PlasticXPLookAndFeel;

/**
 * @author Haroldo O. Pinheiro
 * 
 * TODO Finish the project manager: All the maps, graphics, tiles and scripts of the project will be managed by a single class<BR>
 * TODO Create project Open/Save functions. Probably as a zipped XML file.<BR>
 * TODO Finish the map editor<BR>
 * TODO Finish the pallete editor/palette manager<BR>
 * TODO Create the tileset editor/tileset manager<BR>
 * TODO Port the script compiler to Java<BR>
 * TODO Create routine to export everything into a Sega Genesis ROM.<BR>
 * TODO Do an overall code cleanup, removing unused classes, and make the palette/tileset more generic, so that it can work for plataforms other than the Sega Genesis
 *  
 */
public class Main extends JPanel implements ActionListener {
	static public double VERSION_NUMBER = 0.05;
	static public String VERSION_STATUS = "alpha";
	static public String VERSION        = Double.toString(VERSION_NUMBER) + " " + VERSION_STATUS;
	
	static public boolean DEBUG_MODE = false;
	
	static public Project project = null;
	
	static protected Main instance = null;
		
	protected RootPaneContainer container = null;
	protected JDesktopPane      desktop   = null;
	
	protected JMenu    fileMenu    = null;
	protected JMenu    mapMenu     = null;
	protected JMenu    palMenu     = null;
	protected JMenu    tileMenu    = null;
	protected JMenu    scriptMenu  = null;
	protected JMenu    compileMenu = null;
	protected JMenu    helpMenu    = null;
	protected JMenuBar menu 	   = null;
	
	protected int internalframeofs = 0;
	
	protected Icon iconNew    = null;
	protected Icon iconOpen   = null;
	protected Icon iconSave   = null;
	protected Icon iconSaveAs = null;
	
	public Main(JApplet applet, GraphicsConfiguration gc){
		super();
        instance = this;
        if(applet != null){
        	container = applet;
        } else {
		    container = new JFrame(gc);
		    ((JFrame)container).setTitle("Genesis RPG Creator World Designer v" + VERSION);
        }
		container.getContentPane().add("Center", this);

		setLayout(new BorderLayout());
		
		MetalLookAndFeel.setCurrentTheme(new BlueTheme());
		try {
	        PlasticXPLookAndFeel.setCurrentTheme(new BlueTheme());
			UIManager.setLookAndFeel(new PlasticXPLookAndFeel());

			UIManager.put("AuditoryCues.playList",
					  UIManager.get("AuditoryCues.allAuditoryCues"));
		    if (container instanceof JApplet) {
		    	SwingUtilities.updateComponentTreeUI((JApplet)container);
		    } else {
		    	SwingUtilities.updateComponentTreeUI((JFrame)container);		    	
		    }
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		if (container instanceof JApplet) {
			SwingUtilities.updateComponentTreeUI((JApplet)container);
		} else {
			SwingUtilities.updateComponentTreeUI((JFrame)container);		
		}

		loadIcons();
		createMenuBar();

/*		JToolBar toolbarPanel = new JToolBar();
		toolbarPanel.add(new JButton("Test"));
		add(toolbarPanel, BorderLayout.NORTH);*/
		
		desktop = new JDesktopPane();
		desktop.setBackground(new Color(96, 128, 160));
		add(desktop);
		
		newProject();
		
        if(applet == null){
            ((JFrame)container).setSize(640, 480);
            ((JFrame)container).setExtendedState(JFrame.MAXIMIZED_BOTH);
            ((JFrame)container).show();
        }        
	}
	
	public static void main(String[] args) {
		Main main = new Main(null, GraphicsEnvironment.
                                   getLocalGraphicsEnvironment().
								   getDefaultScreenDevice().
								   getDefaultConfiguration());
	}
	
	private void loadIcons() {
		iconNew    = loadIcon("/tileMolester/icons/New24.gif");
		iconOpen   = loadIcon("/tileMolester/icons/Open24.gif");
		iconSave   = loadIcon("/tileMolester/icons/Save24.gif");
		iconSaveAs = loadIcon("/tileMolester/icons/SaveAs24.gif");		
	}
	
	private void createMenuBar() {
        fileMenu = new JMenu("File");
        fileMenu.add(createMenuItem("New Project...",     iconNew,    "NewProj",    "Creates a new project"                          ));
        fileMenu.addSeparator();
        fileMenu.add(createMenuItem("Open Project...",    iconOpen,   "OpenProj",   "Opens a previously saved project"               ));
        fileMenu.add(createMenuItem("Save Project",       iconSave,   "SaveProj",   "Saves the current project"                      ));
        fileMenu.add(createMenuItem("Save Project as...", iconSaveAs, "SaveProjAs", "Saves the current project with a different name"));
        fileMenu.addSeparator();
        fileMenu.add(createMenuItem("Exit",               null,       "ExitSystem", "Exits Genesis RPG Creator World Designer"       ));
        
        mapMenu = new JMenu("Map");
        mapMenu.add(createMenuItem("New Map...",     null, "NewMap", "Adds a new map to the project"));
        mapMenu.add(createMenuItem("Map manager...", null, "MapMgr", "Opens the map manager"        ));

        palMenu = new JMenu("Palette");
        palMenu.add(createMenuItem("Palettes...", null, "PalMgr", "Opens the palette manager"));

        tileMenu = new JMenu("Tileset");
        tileMenu.add(createMenuItem("New tileset...", null, "NewTile",   "Adds a new tileset to the project"));
        tileMenu.add(createMenuItem("Tileset manager...", null, "TileMgr", "Opens the tileset manager"      ));

        scriptMenu = new JMenu("Scripts");
        scriptMenu.add(createMenuItem("New script...",  null, "NewScript",  "Adds a new script to the project"));
        scriptMenu.add(createMenuItem("Edit script...", null, "EditScript", "Edits an existing script"        ));

        compileMenu = new JMenu("Compile");
        compileMenu.add(createMenuItem("Compile...", null, "CompileProj", "Generates a new ROM from the project"         ));
        compileMenu.add(createMenuItem("Test",       null, "TestProj",    "Tests the project with the built-in simulator"));
        if(DEBUG_MODE) {
        	compileMenu.add(createMenuItem("Save GFS", null, "SaveGFS", "Saves a GFS resource file as C:\\Tmp\\Test.gfs"));
        	compileMenu.add(createMenuItem("Test RDC", null, "TestRDC", "Tests the RDC compression engine"));
        }

        helpMenu = new JMenu("Help");
        helpMenu.add(createMenuItem("About...", null, "AboutSystem", "About Genesis RPG Creator"));

        menu = new JMenuBar();
        menu.add(fileMenu);
        menu.add(mapMenu);
        menu.add(palMenu);
        menu.add(tileMenu);
        menu.add(scriptMenu);
        menu.add(compileMenu);
        menu.add(helpMenu);
        
        if (container instanceof JApplet){
        	((JApplet)container).setJMenuBar(menu);
        } else {
        	((JFrame)container).setJMenuBar(menu);       	
        }
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

	/* (non-Javadoc)
	 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
        String cmd = e.getActionCommand();
        Object src = e.getSource();
        
        if (cmd.equals("NewProj")) {
        	newProject();
        } else if (cmd.equals("OpenProj")) {
        	openProject("");
        } else if (cmd.equals("SaveProj")) {
        	saveProject("", false);
        } else if (cmd.equals("SaveProjAs")) {
        	saveProject("", true);       	
        } else if (cmd.equals("NewMap")) {
        	MapEditor maped = (MapEditor)addInternalFrame(new MapEditor());
        	maped.newMap();
        } else if (cmd.equals("MapMgr")) {
        	if (!internalFrameExists(".MapManager")) {
        		addInternalFrame(new MapManager());        		
        	} else {
        		bringToFront(getInternalFramesByClass(".MapManager")[0]);
        	}
        } else if (cmd.equals("NewTile")) {
        	TilesetEditor tseted = (TilesetEditor)addInternalFrame(new TilesetEditor());
        	tseted.newTileSet();
        } else if (cmd.equals("TileMgr")) {
        	if (!internalFrameExists(".TilesetManager")) {
        		addInternalFrame(new TilesetManager());        		
        	} else {
        		bringToFront(getInternalFramesByClass(".TilesetManager")[0]);
        	}
        } else if (cmd.equals("PalMgr")) {
        	if (!internalFrameExists(".PaletteEditor")) {
        		addInternalFrame(new PaletteEditor());        		
        	} else {
        		bringToFront(getInternalFramesByClass(".PaletteEditor")[0]);
        	}
        } else if (cmd.equals("CompileProj")) {
        	compileProj();
        } else if (cmd.equals("SaveGFS")) {
        	saveGFS();
        } else if (cmd.equals("TestRDC")) {
        	testRDC();
        } else if (cmd.equals("ExitSystem")) {
        	System.exit(0);
        }
	}

	public void newProject() {
		project = (new GenesisFactory()).createProject();
	}
	
	public void openProject(String filename) {
		JFileChooser ch;
		
		// Chooses which file to open
		if ((filename == null) || filename.equals("")) {
			ch = new JFileChooser();
		} else {
			ch = new JFileChooser(filename);
		}

		ch.addChoosableFileFilter(new GenesisProjectFileFilter());
		
		if (ch.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
			filename = ch.getSelectedFile().getAbsolutePath();
		} else {
			// User cancelled operation, do nothing
			return;
		}
		
		try {
			XMLProjectReader reader = new XMLProjectReader();
			project = reader.loadFromStream(new FileInputStream(filename));
			desktop.add(new PaletteEditor());
		} catch (Exception e) {
			e.printStackTrace();
			JOptionPane.showMessageDialog(this,
					                      "Error while loading the project:\n" + e.getLocalizedMessage(),
					                      "Error",JOptionPane.WARNING_MESSAGE);			
		}
	}
	
	public void saveProject(String filename, boolean askfilename) {
		if ((filename == null) || filename.equals("") || askfilename) {
			JFileChooser ch;
			
			if (filename == null) {
				ch = new JFileChooser();
			} else {
				ch = new JFileChooser(filename);
			}
			
			ch.addChoosableFileFilter(new GenesisProjectFileFilter());
			
			if (ch.showSaveDialog(this) == JFileChooser.APPROVE_OPTION) {
				filename = ch.getSelectedFile().getAbsolutePath();
			} else {
				// User cancelled operation, do nothing
				return;
			}
		}
		
		try {
            // Check if file exists
            File exist = new File(filename);
            if (exist.exists()) {
                int result = JOptionPane.showConfirmDialog(this,
                        "The file already exists. Are you sure you want to " +
                        "overwrite it?", "Overwrite file?",
                        JOptionPane.YES_NO_OPTION);
                if (result != JOptionPane.OK_OPTION) {
                    return;
                }
            }

            FileOutputStream out    = new FileOutputStream(filename);
			XMLProjectWriter writer = new XMLProjectWriter(project, out);
			writer.saveToStream();
			out.flush();
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
			JOptionPane.showMessageDialog(this,
					"Error while saving the project:\n" + e.getLocalizedMessage(),
					"Error",JOptionPane.WARNING_MESSAGE);			
		}
	}

	public static BufferedImage loadImageResource(String fname)	throws IOException {
		return ImageIO.read(MapEditor.class.getResourceAsStream(fname));
	}

	private ImageIcon loadIcon(String fname) {
        try {
            return new ImageIcon(loadImageResource(fname));
        } catch (IOException e) {
            System.out.println("Failed to load icon: " + fname);
            return null;
        }
    }
	
	protected JInternalFrame[] getInternalFramesByClass(String classname) {
		JInternalFrame frames[] = desktop.getAllFrames();
		Vector         matches  = new Vector();
		
		for (int i = 0; i != frames.length; i++) {
			if (frames[i].getClass().getName().endsWith(classname)) {
				matches.add(frames[i]);
			}
		}
		
		frames = new JInternalFrame[matches.size()];
		for (int i = 0; i != matches.size(); i++) {
			frames[i] = (JInternalFrame)matches.elementAt(i);
		}
		
		return frames;
	}
	
	protected boolean internalFrameExists(String classname) {
		JInternalFrame frames[] = desktop.getAllFrames();
		
		for (int i = 0; i != frames.length; i++) {
			if (frames[i].getClass().getName().endsWith(classname)) {
				return true;
			}
		}
		
		return false;		
	}
	
	protected int getHighestLayer() {
		JInternalFrame frames[] = desktop.getAllFrames();
		int            layer;
		
		layer = 0;
		for (int i = 0; i != frames.length; i++) {
			if (frames[i].getLayer() > layer) {
				layer = frames[i].getLayer();
			}
		}	

		return layer;
	}
	
	protected Object createWindow(String classname, boolean single) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		Object obj = Class.forName(classname).newInstance();
		if (obj instanceof JInternalFrame) {
			desktop.add((JInternalFrame)obj);
		} 
		/* Not properly implemented, yet. */
		return obj;
	}
	
	public JInternalFrame addInternalFrame(JInternalFrame frame) {
		if (((internalframeofs+frame.getWidth()+6) > desktop.getWidth()) ||
			((internalframeofs+frame.getHeight()+6) > desktop.getHeight())) {
			internalframeofs = 0;
		}
		frame.setBounds(internalframeofs, internalframeofs, 
				        frame.getWidth(), frame.getHeight());
		
		desktop.add(frame);
		try {
			frame.setSelected(true);
		} catch (PropertyVetoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		frame.show();
		
		internalframeofs += 20;
		
		return frame;
	}
	
	public void bringToFront(JInternalFrame frame) {
		frame.hide();
		desktop.remove(frame);
		
		desktop.add(frame);
		try {
			frame.setSelected(true);
		} catch (PropertyVetoException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		frame.show();		
	}
	
	/**
	 * @return Returns the current instance.
	 */
	public static Main getInstance() {
		return instance;
	}
	
	private void saveGFS() {
		try {
		    ProjectBuilder pb = new GenesisProjectBuilder();
			pb.translateProject(project);
			pb.savetoStream(new FileOutputStream("C:\\Tmp\\Test.gfs"));
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * 
	 */
	private void testRDC() {
		try {
			InputStream  in  = new FileInputStream("C:/Tmp/test1.txt");
			OutputStream out = new RDCOutputStream(new FileOutputStream("C:/Tmp/test1.rdc"));
			while(in.available() != 0) {
				out.write(in.read());
			}
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 
	 */
	private void compileProj() {
		String filename = "";
		
		JFileChooser ch = new JFileChooser("RPG.BIN");
		
		ch.addChoosableFileFilter(new GenesisROMFileFilter());
		
		if (ch.showSaveDialog(this) == JFileChooser.APPROVE_OPTION) {
			filename = ch.getSelectedFile().getAbsolutePath();
		} else {
			// User cancelled operation, do nothing
			return;
		}
		
		try {
            // Check if file exists
            File exist = new File(filename);
            if (exist.exists()) {
                int result = JOptionPane.showConfirmDialog(this,
                        "The file already exists. Are you sure you want to " +
                        "overwrite it?", "Overwrite file?",
                        JOptionPane.YES_NO_OPTION);
                if (result != JOptionPane.OK_OPTION) {
                    return;
                }
            }

            FileOutputStream out = new FileOutputStream(filename);            
		    ProjectBuilder pb    = new GenesisProjectBuilder();
			pb.translateProject(project);
			pb.savetoStream(out);
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
			JOptionPane.showMessageDialog(this,
					"Error while saving the project:\n" + e.getLocalizedMessage(),
					"Error",JOptionPane.WARNING_MESSAGE);			
		}		
	}
}
