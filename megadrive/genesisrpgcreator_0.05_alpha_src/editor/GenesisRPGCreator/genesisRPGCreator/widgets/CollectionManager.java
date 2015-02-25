/*
 * Created on 28/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.widgets;

import genesisRPGCreator.mapeditor.MapEditor;
import genesisRPGCreator.util.CollectionTableModel;

import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.AbstractList;

import javax.imageio.ImageIO;
import javax.swing.AbstractButton;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JToggleButton;
import javax.swing.ListSelectionModel;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class CollectionManager extends JPanel implements ActionListener, ListSelectionListener {
	protected AbstractList collection   = null;
	protected JTable       itemTable    = null;
	protected JPanel       panelbuttons = null;

	protected AbstractButton buttonadd   = null;
	protected AbstractButton buttonedit  = null;
	protected AbstractButton buttonup    = null;
	protected AbstractButton buttondown  = null;
	protected AbstractButton buttonclone = null;
	protected AbstractButton buttondel   = null;

    /**
	 * 
	 */
	public CollectionManager(AbstractList collection) {
		super();
		this.collection = collection;
		
        Icon imgAdd  = loadIcon("/tiled/mapeditor/resources/gnome-new.png");
        Icon imgEdit = loadIcon("/genesisRPGCreator/icon/folders.png");
        Icon imgDel  = loadIcon("/tiled/mapeditor/resources/gnome-delete.png");
        Icon imgDup  = loadIcon("/tiled/mapeditor/resources/gimp-duplicate-16.png");
        Icon imgUp   = loadIcon("/tiled/mapeditor/resources/gnome-up.png");
        Icon imgDown = loadIcon("/tiled/mapeditor/resources/gnome-down.png");

        buttonadd   = createButton(imgAdd,  "Add Item",        "Add Item");
        buttonedit  = createButton(imgEdit, "Edit Item",       "Edit Item");
        buttondel   = createButton(imgDel,  "Delete Item",     "Delete Item");
        buttonclone = createButton(imgDup,  "Duplicate Item",  "Duplicate Item");
        buttonup    = createButton(imgUp,   "Move Item Up",    "Move Item Up");
        buttondown  = createButton(imgDown, "Move Item Down",  "Move Item Down");

        itemTable = new JTable(new CollectionTableModel(collection));
        itemTable.setShowGrid(false);
        itemTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        itemTable.getSelectionModel().addListSelectionListener(this);

        /*
         *...
ListSelectionModel rowSM = table.getSelectionModel();
rowSM.addListSelectionListener(new ListSelectionListener() {
    public void valueChanged(ListSelectionEvent e) {
        ListSelectionModel lsm = (ListSelectionModel)e.getSource();
        if (lsm.isSelectionEmpty()) {
            ...//no rows are selected
        } else {
            int selectedRow = lsm.getMinSelectionIndex();
            ...//selectedRow is selected
        }
    }
});
 
         */
        
        panelbuttons = new JPanel();
        panelbuttons.setLayout(new GridBagLayout());
        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1;
        panelbuttons.add(buttonadd,   c);
        panelbuttons.add(buttonedit,  c);
        panelbuttons.add(buttonup,    c);
        panelbuttons.add(buttondown,  c);
        panelbuttons.add(buttonclone, c);
        panelbuttons.add(buttondel,   c);
        panelbuttons.setMaximumSize(new Dimension(Integer.MAX_VALUE,
        		panelbuttons.getPreferredSize().height));

        setLayout(new GridBagLayout());
        setPreferredSize(new Dimension(120, 120));
        c = new GridBagConstraints();
        c.insets = new Insets(3, 0, 0, 0); c.weightx = 1; c.weighty = 0;
        c.fill = GridBagConstraints.BOTH;
        c.gridx = 0; c.gridy = 0;
        //layerPanel.add(miniMapSp, c);
        c.weighty = 0; c.gridy += 1;
//        add(sliderPanel, c);
        c.weighty = 1; c.gridy += 1;
        add(new JScrollPane(itemTable), c);
        c.weighty = 0; c.insets = new Insets(0, 0, 0, 0); c.gridy += 1;
        add(panelbuttons, c);
	}

	public static BufferedImage loadImageResource(String fname) throws IOException {
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
    
    private AbstractButton createButton(Icon icon, String command, String tt) {
        return createButton(icon, command, false, tt);
    }

    private AbstractButton createButton(Icon icon, String command,
            boolean toggleButton, String tt) {
        AbstractButton button;
        if (toggleButton) {
            button = new JToggleButton("", icon);
        } else {
            button = new JButton("", icon);
        }
        button.setMargin(new Insets(0, 0, 0, 0));
        button.setActionCommand(command);
        button.addActionListener(this);
        if (tt != null) {
            button.setToolTipText(tt);
        }
        return button;
    }

	/* (non-Javadoc)
	 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		
	}
	
	public void addItem(Object o) {
		if (collection != null) {
			collection.add(o);			
			itemTable.revalidate();
			itemTable.repaint();
			itemTable.clearSelection();
			itemTable.addRowSelectionInterval(collection.size()-1, collection.size()-1); 
		}
	}

	public int getSelectedIndex() {
		return itemTable.getSelectedRow();
	}
	
	public Object getSelectedItem() {
		if ((collection != null) && (getSelectedIndex() != -1)) {
			return collection.get(getSelectedIndex());
		}
		
		return null;
	}

	/* (non-Javadoc)
	 * @see javax.swing.event.ListSelectionListener#valueChanged(javax.swing.event.ListSelectionEvent)
	 */
	public void valueChanged(ListSelectionEvent e) {
		// TODO Auto-generated method stub
	}
}
