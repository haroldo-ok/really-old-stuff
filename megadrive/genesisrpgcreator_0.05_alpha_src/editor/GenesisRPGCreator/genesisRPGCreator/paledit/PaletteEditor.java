/*
 * Created on 26/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.paledit;

import java.awt.BorderLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.EtchedBorder;
import javax.swing.event.ListSelectionEvent;

import tileMolester.colorcodecs.ColorCodec;
import tileMolester.core.TMPalette;
import genesisRPGCreator.BaseFrame;
import genesisRPGCreator.Main;
import genesisRPGCreator.sysdeps.segagenesis.GenesisColorCodec;
import genesisRPGCreator.widgets.CollectionManager;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class PaletteEditor extends BaseFrame {
	protected GenesisPalettePane palpane       = new GenesisPalettePane();
	protected CollectionManager  palcollection = null;

	/**
	 * 
	 */
	public PaletteEditor() {
		super();
		// TODO Auto-generated constructor stub
		setTitle("Palette Editor");
        setSize(418, 400);
        	
		ColorCodec codec = new GenesisColorCodec();
		TMPalette  tmpal = new TMPalette("", 16, codec, 0);
		
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
		
		palpane.setPalette(tmpal);
		palpane.setBitDepth(4);

		// Lower panel (Description/Palette)
		JPanel lowerpanel = new JPanel();
		lowerpanel.setLayout(new BorderLayout());
		lowerpanel.setBorder(new EtchedBorder(EtchedBorder.RAISED));

		JPanel lowerpaneltop = new JPanel();
		lowerpaneltop.setLayout(new GridBagLayout());
        GridBagConstraints c = new GridBagConstraints();
        c.anchor = GridBagConstraints.WEST;
        c.fill = GridBagConstraints.NONE;
        c.insets = new Insets(2, 2, 2, 2);
        c.weightx = 1;
        lowerpaneltop.add(new JLabel("Description"), c);
        c.weightx = 8;
        c.fill = GridBagConstraints.HORIZONTAL;
        lowerpaneltop.add(new JTextField(), c);

        lowerpanel.add(lowerpaneltop, BorderLayout.NORTH);
        lowerpanel.add(palpane,       BorderLayout.CENTER);

		getRootPane().setLayout(new BorderLayout());
		getRootPane().add(lowerpanel, BorderLayout.SOUTH);

		// Palette list
		palcollection = new PaletteCollectionManager(Main.project.getPalettes()) {
			public void valueChanged(ListSelectionEvent e) {
				super.valueChanged(e);
				updatePallete();	
			}			
		};
		getRootPane().add(palcollection, BorderLayout.CENTER);
	}
	
	protected void updatePallete() {
		palpane.setPalette((TMPalette)palcollection.getSelectedItem());
	}
}
