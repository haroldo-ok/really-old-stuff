package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GImage extends Image implements Drawable {

    public GImage () {}

    public void draw (Graphics g, Scene scene) {
	System.out.println("GImage.draw");
    }
}
