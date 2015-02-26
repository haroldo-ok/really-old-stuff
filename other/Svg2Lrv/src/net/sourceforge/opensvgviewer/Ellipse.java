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


public class Ellipse extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    public Ellipse() { totalShapes++; }

    public float getX() { return x; }
    public float getY() { return y; }
    public float getXRadius() { return xRadius; }
    public float getYRadius() { return yRadius; }

    public void setX(float x) { this.x = x; }
    public void setY(float y) { this.y = y; }
    public void setXRadius(float xr) { xRadius = xr; }
    public void setYRadius(float yr) { yRadius = yr; }

    protected float x;
    protected float y;
    protected float xRadius;
    protected float yRadius;
}
