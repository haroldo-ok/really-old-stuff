import net.sourceforge.opensvgviewer.Drawable;
import net.sourceforge.opensvgviewer.Scene;

import java.awt.*;

public class GSVG extends OsvSVG implements Drawable {

    public GSVG () {}

    public void draw (Graphics g, Scene scene) {
	System.out.println("GSVG.draw");
    }
}
