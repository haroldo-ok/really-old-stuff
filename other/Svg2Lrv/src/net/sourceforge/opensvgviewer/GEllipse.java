package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GEllipse extends Ellipse implements Drawable {

    public GEllipse () {}

    public void draw (Graphics g, Scene scene) {
	System.out.println("GEllipse.draw");
    }
}
