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

public class Rect extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    public Rect() { totalShapes++; }

    public float getX() { return pxy[0]; }
    public float getY() { return pxy[1]; }
    public float getHeight() { return height; }
    public float getWidth() { return width; }

    public void setX(float x) { pxy[0] = x; }
    public void setY(float y) { pxy[1] = y; }
    public void setHeight(float h) { height=h; }
    public void setWidth(float w) { width=w; }

    protected float[] pxy = new float[2];
    protected float height;
    protected float width;
}






			
	
