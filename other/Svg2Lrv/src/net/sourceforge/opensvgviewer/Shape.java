/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2003 Marco Monteiro
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


import java.awt.Color;
import java.awt.Rectangle;

public abstract class Shape {

    public final boolean isFilled() { return isFilled_v; }
    public final boolean isStroked() { return isStroked_v; }
    public final boolean isVisible() { return isVisible_v; }

    // SET METHODS

    public final void setState(boolean b) { isVisible_v = b; }
    public final void setBoundingBox(Rectangle r) { boundingBox=r; }

    public final void setStrokeColor(Color c) { 
	strokeColor = c; 
	isStroked_v = true;
    }
    public final void setStrokeColor(String str) {
	if (str.startsWith("#")) strokeColor = Colors.RGB(str);
	else strokeColor = colorsList.getColor(str);
	isStroked_v = true;
    }
    public final void setFillColor(Color c) {
	fillColor = c;
	isFilled_v = true;
    }
    public final void setFillColor(String str) {
	isFilled_v = true;
	if (str.equals("none")) { fillColor = null; isFilled_v = false; }
	else if (str.startsWith("#")) fillColor = Colors.RGB(str);
	else fillColor = colorsList.getColor(str);
    }

    // GET METHODS

    public final Color getStrokeColor() { return strokeColor; }  
    public final Color getFillColor() { return fillColor; }   
    public final Rectangle getBoundingBox() { return boundingBox; }

    // PROTECTED
    
    protected boolean isFilled_v=false;
    protected boolean isStroked_v=false;
    protected boolean isVisible_v;
    protected Color fillColor = Color.white;
    protected Color strokeColor = Color.black;
    protected Rectangle boundingBox;

    // STATIC 

    private static Colors colorsList = new Colors();
}	
