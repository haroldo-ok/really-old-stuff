/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2002 PT Inovação 
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


public class Text extends Shape {

    protected static int totalShapes;

    public int getTotalShapes() { return totalShapes; }

    public Text() { totalShapes++; }

    public float getX() { return pxy[0]; }
    public float getY() { return pxy[1]; }
    public float getRotation() { return rotation; }
    public int getFontSize() { return fontSize; }
    public int getFontStyle() { return fontStyle; }
    public String getFontFamily() { return fontFamily; }
    public String getText() { return text; }

    public void setX(float x) { pxy[0]=x; }
    public void setY(float y) { pxy[1]=y; }
    public void setRotation(float r) { rotation=r; }
    public void setFontSize(int size) { fontSize=size; }
    public void setFontStyle(int style) { fontStyle=style; }
    public void setFontFamily(String family) { fontFamily=family; }
    public void setText(String t) { text = t; }

    public java.awt.Font getFont() {
    	return new java.awt.Font(fontFamily, fontStyle, fontSize);
    }

    public void setFont(String family, int style, int size) {
	fontFamily = family;
	fontStyle = style;
	fontSize = size;
    }

    public void translate(float x, float y) {
    	pxy[0]+=x;
    	pxy[1]+=y;    		
    }

    public void setStyle(String s) {
    	String sep=":; ";
    	java.util.StringTokenizer st = new java.util.StringTokenizer(s,sep);
    	while(st.hasMoreTokens()) {
	    String style = st.nextToken();
	    String value = st.nextToken();
	    if (style.equals("stroke")) {
		setStrokeColor(value);
	    } else if (style.equals("font-size")) {
		fontSize=Float.valueOf(value).intValue();
	    } else if (style.equals("font-family")) {
		fontFamily=value;
	    }
    	}
    }

    protected float[] pxy = new float[2];
    protected float rotation;
    protected int fontSize;
    protected int fontStyle=java.awt.Font.PLAIN;
    protected String fontFamily="times";
    protected String text;
}
