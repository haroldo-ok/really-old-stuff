/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2003  Marco Monteiro
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
package net.sourceforge.opensvgviewer;


/* FIXME: It has fillColor and it shouldn't */

public class Line extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    public Line() { totalShapes++; }

    public Line(float x1, float y1, float x2, float y2) {
	this();
    	xy[0] = x1;
    	xy[1] = y1;
    	xy[2] = x2;
    	xy[3] = y2;
    }

    public float getX1() { return xy[0]; }
    public float getY1() { return xy[1]; }
    public float getX2() { return xy[2]; }
    public float getY2() { return xy[3]; }

    public void setX1(float x1) { xy[0] = x1; }
    public void setY1(float y1) { xy[1] = y1; }
    public void setX2(float x2) { xy[2] = x2; }
    public void setY2(float y2) { xy[3] = y2; }

    protected float[] xy = new float[4];
}
