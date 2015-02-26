package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GPolygon extends Polygon implements Drawable {

    public GPolygon () {}

    public void compile() {
	ixx = new int[np]; // xx to draw
	iyy = new int[np]; // yy to draw
    }

    public void draw (Graphics g, Scene scene) {
	scene.computeXY(px, py, ixx, iyy, np);

	if (isFilled_v) {
	    g.setColor(fillColor);
	    g.fillPolygon(ixx, iyy, np);		
	}
	
	g.setColor(strokeColor);
	g.drawPolygon(ixx, iyy, np); 
	
    }

    private int[] ixx, iyy;
}
