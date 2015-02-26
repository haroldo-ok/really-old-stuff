package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GPath extends Path implements Drawable {

    public GPath () {}

    public void draw (Graphics g, Scene scene) {
	System.out.println("GPath.draw");
    }
}
