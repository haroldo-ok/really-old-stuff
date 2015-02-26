/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2002 PT Inovação 
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


import org.w3c.dom.*;
import java.awt.*;
import java.util.*;

public class Path extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    public Path() { totalShapes++; }

    public static void addMoveTo(String command, String param) {
	float mx;
	float my;
	String seps = " ,";
	StringTokenizer tok = new StringTokenizer(param,seps);
	
	closeAllElements();
	
	mx = Float.valueOf(tok.nextToken()).floatValue();
	my = Float.valueOf(tok.nextToken()).floatValue();
	if (command.equals("M")) {
	    px_ini = mx;
	    py_ini = my;
	    px_act = mx;
	    py_act = my;
	} else {
	    px_ini = px_act + mx;
	    py_ini = py_act + my;
	    px_act = px_ini;
	    py_act = py_ini;
	}
	
	while (tok.hasMoreTokens()){
	    String prm = tok.nextToken() + "," + tok.nextToken();
	    addLineTo("L",prm);
	}
    }

    public static void addLineTo(String command, String param) {
	float xl;
	float yl;
	String seps = " ,";

	px[np] = px_act;
	py[np] = py_act;
	np++;
	
	StringTokenizer tok = new StringTokenizer(param,seps);
	while (tok.hasMoreTokens()){
	    xl = Float.valueOf(tok.nextToken()).floatValue();
	    yl = Float.valueOf(tok.nextToken()).floatValue();
	    if (command.equals("L")) {
		px_act = xl;
		py_act = yl;
	    } else {
		px_act += xl;
		py_act += yl;
	    }
	    px[np] = px_act;
	    py[np] = py_act;
	    np++;
	}
    }

    public static void addHorizLine(String command, String param) {
	float xl;
	String seps = " ,";
	
	px[np] = px_act;
	py[np] = py_act;
	np++;
	
	StringTokenizer tok = new StringTokenizer(param,seps);
	while (tok.hasMoreTokens()){
	    xl = Float.valueOf(tok.nextToken()).floatValue();
	    if (command.equals("H")) {
		px_act = xl;
	    } else {
		px_act += xl;
	    }
	    px[np] = px_act;
	    py[np] = py_act;
	    np++;
	}
    }

    public static void addVertLine(String command, String param) {
	float yl;
	String seps = " ,";
	
	px[np] = px_act;
	py[np] = py_act;
	np++;

	StringTokenizer tok = new StringTokenizer(param,seps);
	while (tok.hasMoreTokens()){
	    yl = Float.valueOf(tok.nextToken()).floatValue();
	    if (command.equals("V")) {
		py_act = yl;
	    } else {
		py_act += yl;
	    }
	    px[np] = px_act;
	    py[np] = py_act;
	    np++;
	}
    }

    public static void addCubicBezier(String command, String param) {
	int dim = param.length();
	float ptsb[][] = new float[dim][2];
	int npb = 0;
	int dep = 2;
	float xb,yb,x1c,x2c,y1c,y2c;
	String seps = " ,";

	closeAllElements();

	ptsb[npb][0] = px_act;
	ptsb[npb][1] = py_act;
	npb++;

	StringTokenizer tok = new StringTokenizer(param,seps);
	while (tok.hasMoreTokens()){
	    x1c = Float.valueOf(tok.nextToken()).floatValue();
	    y1c = Float.valueOf(tok.nextToken()).floatValue();
	    x2c = Float.valueOf(tok.nextToken()).floatValue();
	    y2c = Float.valueOf(tok.nextToken()).floatValue();
	    xb = Float.valueOf(tok.nextToken()).floatValue();
	    yb = Float.valueOf(tok.nextToken()).floatValue();
	    if (command.equals("C")) {
		ptsb[npb][0] = x1c;
		ptsb[npb][1] = y1c;
		npb++;
		ptsb[npb][0] = x2c;
		ptsb[npb][1] = y2c;
		npb++;
		px_act = xb;
		py_act = yb;
	    } else {
		ptsb[npb][0] = x1c+px_act;
		ptsb[npb][1] = y1c+py_act;
		npb++;
		ptsb[npb][0] = x2c+px_act;
		ptsb[npb][1] = y2c+py_act;
		npb++;
		px_act += xb;
		py_act += yb;
	    }
	    ptsb[npb][0] = px_act;
	    ptsb[npb][1] = py_act;
	    npb++;
	}
	
	for (int i=0;i<npb-1;i+=3){
	    int l = i;
	    float ptb[][] = new float[4][2];
	    ptb[0][0] = ptsb[l][0];
	    ptb[0][1] = ptsb[l][1];
	    ptb[1][0] = ptsb[l+1][0];
	    ptb[1][1] = ptsb[l+1][1];
	    ptb[2][0] = ptsb[l+2][0];
	    ptb[2][1] = ptsb[l+2][1];
	    ptb[3][0] = ptsb[l+3][0];
	    ptb[3][1] = ptsb[l+3][1];
	    Bezier bz = new Bezier(ptb,4,dep);
	    p_obj.addElement(bz);
	}
    }

    public static void addQuadBezier(String command, String param) {
	int dim = param.length();
	float ptsb[][] = new float[dim][2];
	int npb = 0;
	int dep = 2;
	float xb,yb,x1c,y1c;
	String seps = " ,";

	closeAllElements();
	
	ptsb[npb][0] = px_act;
	ptsb[npb][1] = py_act;
	npb++;
	
	StringTokenizer tok = new StringTokenizer(param,seps);
	while (tok.hasMoreTokens()){
	    x1c = Float.valueOf(tok.nextToken()).floatValue();
	    y1c = Float.valueOf(tok.nextToken()).floatValue();
	    xb = Float.valueOf(tok.nextToken()).floatValue();
	    yb = Float.valueOf(tok.nextToken()).floatValue();
	    if (command.equals("Q")) {
		ptsb[npb][0] = x1c;
		ptsb[npb][1] = y1c;
		npb++;
		px_act = xb;
		py_act = yb;
	    } else {
		ptsb[npb][0] = x1c+px_act;
		ptsb[npb][1] = y1c+py_act;
		npb++;
		px_act += xb;
		py_act += yb;
	    }
	    ptsb[npb][0] = px_act;
	    ptsb[npb][1] = py_act;
	    npb++;
	}
	
	for (int i=0;i<npb-1;i+=2){
	    int l = i;
	    float ptb[][] = new float[3][2];
	    ptb[0][0] = ptsb[l][0];
	    ptb[0][1] = ptsb[l][1];
	    ptb[1][0] = ptsb[l+1][0];
	    ptb[1][1] = ptsb[l+1][1];
	    ptb[2][0] = ptsb[l+2][0];
	    ptb[2][1] = ptsb[l+2][1];
	    Bezier bz = new Bezier(ptb,3,dep);
	    p_obj.addElement(bz);
	}
    }

    public static void addClose(String command) {
	if (lastToken.equals("L") || lastToken.equals("l") ||
	    lastToken.equals("H") || lastToken.equals("h") ||
	    lastToken.equals("V") || lastToken.equals("v")) {
	    px[np] = px_ini;
	    py[np] = py_ini;
	    np++;
	    px_act = px_ini;
	    py_act = py_ini;
	    
	    Polyline pl = new Polyline(px,py,np);
	    p_obj.addElement(pl);
	    float auxx[] = new float[max];
	    float auxy[] = new float[max];
	    px = auxx;
	    py = auxy;
	    np = 0;
	} else {
	    Line lin = new Line(px_act,py_act,px_ini,py_ini);
	    p_obj.addElement(lin);
	}
    }

    // Return the vector path objects.
    public Vector getPathObjects() {
	return this.p_obj;
    }

    // Clears all the path elements.
    public void clearPath() {
	p_obj.removeAllElements();
    }

    // Closes all elements.
    public static void closeAllElements() {
	closePoly();
    }

    // Add new polyline to the array of path elements.
    public static void closePoly() {
	if (np != 0) {
	    Polyline pl = new Polyline(px,py,np);
	    p_obj.addElement(pl);
	    px = new float[max];
	    py = new float[max];
	    np = 0;
	}
    }

    static int max;
    static float px_ini = 0; // The inicial x point.
    static float py_ini = 0; // The inicial y point.
    static float px_act; // The current x point.
    static float py_act; // The current y point.
    static float px[]; // All of the x points.
    static float py[]; // All of the y point.
    static int np = 0; // The number of points.

    static String path = null; // The string with the points to parse.
    public static String lastToken = null; // The last token parsed
    
    static Vector p_obj = new Vector(); // Elements created in this class
}
