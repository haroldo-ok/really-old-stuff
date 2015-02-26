package net.sourceforge.opensvgviewer;

import java.awt.Graphics;

public class GCircle extends Circle implements Drawable {

    public GCircle () { }

    public void draw (Graphics g, Scene scene) {

	// transform
	scene.computeXY( pxy, xy, 2 );
	radius = (int)(scene.getScale() * pradius);
	
	// paint
	if (isFilled_v) {
	    g.setColor(fillColor);
	    g.fillOval((int)xy[0], (int)xy[1], radius, radius);
	}

	g.setColor(strokeColor);
	g.drawOval(xy[0], xy[1], radius, radius);
    }

    private int[] xy = new int[2];
    private int radius;
}
