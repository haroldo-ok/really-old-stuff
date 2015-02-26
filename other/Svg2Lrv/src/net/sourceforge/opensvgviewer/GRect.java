package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GRect extends Rect implements Drawable {

    public GRect () {}

    public void draw (Graphics g, Scene scene) {

	scene.computeXY( pxy, xy, 2);
	scale = scene.getScale();
	w = (int)(width * scale);
	h = (int)(height * scale);
	
	if (isFilled_v) {
	    g.setColor(fillColor);
	    g.fillRect((int)xy[0], (int)xy[1], w, h);
	}
	
	g.setColor(strokeColor);
	g.drawRect(xy[0], xy[1], w, h);
	
    }

    private int[] xy = new int[2];
    private int w, h;
    private float scale;
   
}
