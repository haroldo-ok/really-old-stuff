/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2002 PT Inovação
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

public class Bezier extends Shape {

    protected static int totalShapes;

    public static int getTotalShapes() { return totalShapes; }

    /** Array of points (<code>(x,&nbsp;y)</code> coordinates of starting
     * point, control points and ending point).
     */
    float pts[][] = new float[4][2];
    /** The number of points stored. */
    int np;
    /** The detail of the curve. */
    int dep;
    
    public Bezier (float[][] pts, int np, int dep) {
    	this.pts = pts;
	this.np = np;
	this.dep = dep;
	totalShapes++;
    }

    public float[][] getPts() {
	return this.pts;
    }

    public void setPts(float px[][]) {
	this.pts = pts;
    }

    public int getNp() {
	return this.np;
    }

    public void setNp(int np) {
	this.np = np;
    }

    public int getDep() {
	return this.dep;
    }

    public void setDep(int dep) {
	this.dep = dep;
    }

    /** Method to create, recursively, the bezier curve from an array of points
     * and with a detail.
     * <p> The bezier curve is built by several points. If the detail is equal
     * to zero, the points that form the bezier are just the same as given in
     * the array of points. In the other cases, are created two arrays with new
     * transformed points then they are united to provide new array to be
     * passed recursively to this method with less detail.
     * @param points the array of points.
     * @param n number of points.
     * @param depth the detail of curve.
     * @return array of transformed points.
     */
    public float[][] dBzr(float points[][], int n, int depth) {

	int i, j;
	float x0=0, y0=0, x1, y1;
	float left[][], right[][];
	float ppts[][] = new float[n][2];
	float pptsl[][], pptsr[][];

	if (depth==0) {
	    x0 = points[0][0];
	    y0 = points[0][1];
	    for (i=0; i<n; i++) {
		x1 = (float) points[i][0];
		y1 = (float) points[i][1];
		if (i>0) {
		    ppts[i][0] = x1;
		    ppts[i][1] = y1;
		} else {
		    ppts[i][0] = x0;
		    ppts[i][1] = y0;
		}
		x0 = x1;
		y0 = y1;
	    }
	    return ppts;
	} else {
	    left = new float[n][2];
	    right = new float[n][2];
	    for (i=0; i<n; i++) {
		right[i][0] = points[i][0];
		right[i][1] = points[i][1];
	    }
	    left[0][0] = right[0][0];
	    left[0][1] = right[0][1];

	    for (j=n-1; j>=1; j--) {
		for (i=0; i<j; i++) {
		    right[i][0] = (right[i][0] + right[i+1][0]) / 2;
		    right[i][1] = (right[i][1] + right[i+1][1]) / 2;
		}
		left[n-j][0] = right[0][0];
		left[n-j][1] = right[0][1];
	    }
	    pptsl=dBzr(left,  n, depth-1);
	    pptsr=dBzr(right, n, depth-1);
	    return uniteP(pptsl,pptsr);
	}
    }


    /** Method to unite two bi-dimensional arrays of points.
     * @return an array with the points of first array followed by the points
     * of second array.
     */
    public float[][] uniteP(float pptsl[][], float pptsr[][]) {

    	int z = pptsl.length;
    	float arr[][] = new float[pptsl.length+pptsr.length][2];
    	for (int i=0;i<z;i++) {
	    arr[i][0]=pptsl[i][0];
	    arr[i][1]=pptsl[i][1];
    	}
    	for (int w=0;w<pptsr.length;w++) {
	    arr[z+w][0] = pptsr[w][0];
	    arr[z+w][1] = pptsr[w][1];
	}
	return arr;
    }
}
