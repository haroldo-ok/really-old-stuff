package genesisRPGCreator.themes;

import javax.swing.plaf.*;
import javax.swing.plaf.metal.*;

/**
 * This class describes a theme using gray/blue colors.
 *
 * 1.0 2004-01-11
 * @author Haroldo O. Pinheiro
 * 
 */
public class BlueTheme extends DefaultMetalTheme {

    public String getName() { return "Gray-Blue"; }

    private final ColorUIResource primary1 = new ColorUIResource(64, 96, 128);
    private final ColorUIResource primary2 = new ColorUIResource(140, 160, 192);
    private final ColorUIResource primary3 = new ColorUIResource(180, 200, 235);

    protected ColorUIResource getPrimary1() { return primary1; }
    protected ColorUIResource getPrimary2() { return primary2; }
    protected ColorUIResource getPrimary3() { return primary3; }
}
