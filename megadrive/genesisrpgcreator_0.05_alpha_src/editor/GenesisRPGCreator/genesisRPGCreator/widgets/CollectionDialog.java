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

package genesisRPGCreator.widgets;


import java.awt.*;
import java.awt.event.*;
import java.util.AbstractList;

import javax.swing.*;

import tiled.mapeditor.widget.*;


public class CollectionDialog extends JDialog implements ActionListener
{
	protected AbstractList      collection   = null;
	protected CollectionManager colman       = null;
	protected Object            selecteditem = null;

    public CollectionDialog(Container parent, AbstractList collection, String title) {
        super((JFrame)null, title, true);
        this.collection = collection;
    	setSize(200, 320);
        init();
        setResizable(false);
        setLocationRelativeTo(parent);
    }

    private void init() {
    	colman = new CollectionManager(collection);
    	
    	// OK and Cancel buttons

        JButton okButton     = new JButton("OK");
        JButton cancelButton = new JButton("Cancel");
        okButton.addActionListener(this);
        cancelButton.addActionListener(this);

        JPanel buttons = new VerticalStaticJPanel();
        buttons.setLayout(new BoxLayout(buttons, BoxLayout.X_AXIS));
        buttons.add(Box.createGlue());
        buttons.add(okButton);
        buttons.add(Box.createRigidArea(new Dimension(5, 0)));
        buttons.add(cancelButton);

		// Main panel

        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.PAGE_AXIS));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        mainPanel.add(colman);
        mainPanel.add(Box.createRigidArea(new Dimension(0, 5)));
        mainPanel.add(Box.createGlue());
        mainPanel.add(buttons);

        getContentPane().add(mainPanel);
        getRootPane().setDefaultButton(okButton);
    }

    public Object displayDialog() {
        setVisible(true);
        return selecteditem;
    }

    public void actionPerformed(ActionEvent e) {
        if (e.getActionCommand().equals("OK")) {
            selecteditem = colman.getSelectedItem();       	
            dispose();
        } else {
            dispose();
        }
    }
}
