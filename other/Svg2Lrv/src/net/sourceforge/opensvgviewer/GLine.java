package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GLine extends Line implements Drawable {

    public GLine () {}

    public void draw (Graphics g, Scene scene) {
	// transform
	scene.computeXY(xy, ixy, 4);

	// paint
	g.setColor(strokeColor);
	g.drawLine(ixy[0], ixy[1], ixy[2], ixy[3]);
    }

    private int[] ixy = new int[4];
}
