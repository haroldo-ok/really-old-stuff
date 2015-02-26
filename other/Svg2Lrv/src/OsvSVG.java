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
import net.sourceforge.opensvgviewer.*;


import org.w3c.dom.*;
import java.awt.*;
import java.util.*;

public class OsvSVG {
    	
    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    public OsvSVG() { totalShapes++; }

    public float getX() { return x; }
    public float getY() { return y; }
    public float getWidth() { return width; }
    public float getHeight() { return height; }

    public void setX(float x) { this.x = x; }
    public void setY(float y) {	this.y = y; }
    public void setWidth(float w) { width = w; }
    public void setHeight(float h) { height = h; }

    public float getViewboxX() { return viewboxX; }
    public float getViewboxY() { return viewboxY; }
    public float getViewboxWidth() { return viewboxWidth; }
    public float getViewboxHeight() { return viewboxHeight; }

    public void setViewboxX(float x) { viewboxX = x; }
    public void setViewboxY(float y) {	viewboxY = y; }
    public void setViewboxWidth(float w) { viewboxWidth = w; }
    public void setViewboxHeigth(float h) { viewboxHeight = h; }

    public boolean hasViewbox() { return hasViewbox_v; }

/** Method that parses the string that constains info about the viewbox
* @param the string viewbox
*/
public void str2pts(String pontos)
{
	hasViewbox_v=true;
    	String sep=" ,\n\t\r";
    	StringTokenizer st = new StringTokenizer(pontos,sep);
	this.viewboxX = Float.valueOf(st.nextToken()).floatValue();
	this.viewboxY = Float.valueOf(st.nextToken()).floatValue();
	this.viewboxWidth = Float.valueOf(st.nextToken()).floatValue();
	this.viewboxHeight = Float.valueOf(st.nextToken()).floatValue();
}

/** Method that converts the width to a float value
* @param the string to convert
* @return the value width
*/
public void convStrWid(String param)
{
    	if (param.endsWith("%")) {
    		String sub = param.substring(0,param.length()-1);
    		float num = Float.valueOf(sub).floatValue();
    		this.width*=(num / 100);
    	}
    	else  this.width = convStr(param);
}      	

/** Method that converts the height to a float value
* @param the string to convert
* @return the value height
*/
public void convStrHei(String param)
{
    	if (param.endsWith("%")) {
    		String sub = param.substring(0,param.length()-1);
    		float num = Float.valueOf(sub).floatValue();
    		this.height*=(num / 100);
    	}
    	else this.height = convStr(param);
}      	

/** Method that converts from cm,mm,px,pt to a float value
* @param the string to convert
* @return the float value
*/
public float convStr(String param)
{
	if (param.endsWith("cm")) {
    		String sub = param.substring(0,param.length()-2);
    		float num = Float.valueOf(sub).floatValue();
    		return (num * 35.43307f);
    	}
    	else if (param.endsWith("mm")) {
    		String sub = param.substring(0,param.length()-2);
    		float num = Float.valueOf(sub).floatValue();
    		return (num * 3.543307f);
    	}        	
    	else if (param.endsWith("pt")) {
    		String sub = param.substring(0,param.length()-2);
    		float num = Float.valueOf(sub).floatValue();
    		return (num * 1.25f);
    	}        	
    	else if (param.endsWith("px")) {
    		String sub = param.substring(0,param.length()-2);
    		float num = Float.valueOf(sub).floatValue();
    		return num;
    	}
    	else {
    		float num = Float.valueOf(param).floatValue();
    		return num;
    	}
}
      	
    float x=0;
    float y=0;
    float width = 240;
    float height = 320;	
    float viewboxX=0;
    float viewboxY=0;
    float viewboxWidth = 240;
    float viewboxHeight = 320;

    boolean hasViewbox_v;
}
