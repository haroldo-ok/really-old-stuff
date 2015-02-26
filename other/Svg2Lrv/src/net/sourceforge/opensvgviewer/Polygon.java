/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2002  PT Inovação 
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

public class Polygon extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }	

    public Polygon() { totalShapes++; }

    public Polygon(float[] px, float[] py, int np) {
	this();

	this.px = px;
	this.py = py;
	this.np = np;

	for (int w=0;w<np;w++){
	    if((xMaxb)||(xMax<px[w])){xMaxb=false;xMax=px[w];}
	    if((xMinb)||(xMin>px[w])){xMinb=false;xMin=px[w];}
	    if((yMaxb)||(yMax<py[w])){yMaxb=false;yMax=py[w];}
	    if((yMinb)||(yMin>py[w])){yMinb=false;yMin=py[w];}
    	}
    }

    /*
    
    public float[] getPx()    {
    	return this.px;
    }

    public void setPx(float px[]){
    	this.px = px;
    }

    public float[] getPy(){
    	return this.py;
    }
    
    public void setPy(float py[]){
    	this.py = py;
    }

    public float[] getBound(){
    	float b[]=new float [4];
    	b[0]=this.xMax;
    	b[1]=this.yMax;
    	b[2]=this.xMin;
    	b[3]=this.yMin;
    	return b;
    }

    public int getNp(){
    	return this.np;
    }

    public void setNp(int np){
    	this.np = np;
    }

    */

    public void str2pts(String pt, int i) {
    	int ind = i / 2;
    	int par = i % 2;
    	
    	if (par == 0) {
	    x = Float.valueOf(pt).floatValue();
	    this.px[ind] = x;
	    if((xMaxb)||(xMax<x)){xMaxb=false;xMax=x;}
	    if((xMinb)||(xMin>x)){xMinb=false;xMin=x;}
    	} else {
	    y = Float.valueOf(pt).floatValue();
	    this.py[ind] = y;
	    if((yMaxb)||(yMax<y)){yMaxb=false;yMax=y;}
	    if((yMinb)||(yMin>y)){yMinb=false;yMin=y;}
    	}
    } 	
    
    public float px[];
    public float py[];
    public int np;
    
    float x, y;

    float xMax;
    float xMin;
    float yMax;
    float yMin;

    boolean  xMaxb=true;
    boolean  xMinb=true;
    boolean  yMaxb=true;
    boolean  yMinb=true;
}
