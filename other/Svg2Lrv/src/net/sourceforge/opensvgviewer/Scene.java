package net.sourceforge.opensvgviewer;

import java.awt.*;
import java.util.*;

public class Scene {

    public Scene() {
	reset();
    }

    public void reset() {
	toIdentity(t);
	toIdentity(s);
	toIdentity(r);
	toIdentity(matrix);
    	objects.removeAllElements();
    }

    /*******************************************/
    /*** MATRIX TRANSFORMATIONS ****************/
    /*******************************************/

    public void translate(float x, float y) {
	t[0][2] = x;
	t[1][2] = y;
	matrix = mul(t, matrix);
    }

    // used for the area scale
    public void scale(float x, float y, float scaleX, float scaleY) {
	s[0][0] = scaleX; //x
	s[1][1] = scaleY; //y
	s[0][2] = scaleX * x; // x translate
	s[1][2] = scaleY * y; // y translate
	matrix = mul(s, matrix);
    }

    // used for the free scale
    public void scale(int x, int y, float scale) {
	s[0][0] = scale; //x
	s[1][1] = scale; //y
	s[0][2] = x * ( 1 - scale); // x translate
	s[1][2] = y * ( 1 - scale); // y translate
	matrix = mul(s, matrix);
    }

    // I wonder! is this for rotations ? ;) - again it can be optimized ( the Math.cos and Math.sin )
    public void rotate(float x, float y, float a) {
	cos = (float)Math.cos(a);
	sin = (float)Math.sin(a);

	r[0][0] = cos; r[0][1] = -sin; r[0][2] = x * ( 1 - cos ) + y * sin;
	r[1][0] = sin; r[1][1] =  cos; r[1][2] = y * ( 1 - cos ) - x * sin;
	
	matrix = mul(r, matrix);
    }
   
    /*******************************************/
    /*** TRANSFORMING THE POINTS ***************/
    /*******************************************/

    public void computeXY(float[] xyIn, int[] xyOut, int arraySize) {
	for (i=0; i<arraySize; i=i+2) {
	    xyOut[i]   = (int)(matrix[0][0]*xyIn[i] + matrix[0][1] * xyIn[i+1] + matrix[0][2]); // X
	    xyOut[i+1] = (int)(matrix[1][0]*xyIn[i] + matrix[1][1] * xyIn[i+1] + matrix[1][2]); // Y
	}
    }

    public void computeXY(float[] xIn, float[] yIn, int[] xOut, int[] yOut, int np) {
	for (i=0; i<np; i++) {
	    xOut[i] = (int)(matrix[0][0]*xIn[i] + matrix[0][1] * yIn[i] + matrix[0][2]); // X
	    yOut[i] = (int)(matrix[1][0]*xIn[i] + matrix[1][1] * yIn[i] + matrix[1][2]); // Y	    
	}
    }

    public float getScale() { return matrix[0][0]; }

    /*********************************************************/
    /*********************************************************/
    /*********************************************************/

    public void addNode(Object o) {
	objects.addElement(o);
	size = objects.size();
    }

    public Vector getObjects() { return objects; }

    public void setDesc(String d) { desc = d; }

    public void setTitle(String t) { title = t; }   
    
    /*********************************************************/
    /** PRIVADOS *********************************************/
    /*********************************************************/
    
    // to store all the objects
    private Vector objects = new Vector();

    /** The scale value is saved separatly */
    private float scaleX, scaleY;

   /** The <b>SVG</b> description.*/
    private String desc = "Description not available";
    /** The <b>SVG</b> title.*/
    private String title = "Title not available";

    private int size;
    private int i;
    private float cos,sin;

    private float[][] matrix = new float[3][3]; // result matrix
    private float[][] m; // auxiliar matrix

    private float[][] t = new float[3][3]; // translation matrix
    private float[][] s = new float[3][3]; // scale matrix
    private float[][] r = new float[3][3]; // rotation matrix


    /**
     * @param float[][] a - source matrix a
     * @param float[][] b - source matrix b
     * @param float[][] m - result matrix (a * b)
     */
    private float[][] mul(float[][] a, float[][] b) {
	m = new float[3][3];
	m[0][0] = a[0][0]*b[0][0] + a[0][1]*b[1][0] + a[0][2]*b[2][0];
	m[1][0] = a[1][0]*b[0][0] + a[1][1]*b[1][0] + a[1][2]*b[2][0];
	m[2][0] = a[2][0]*b[0][0] + a[2][1]*b[1][0] + a[2][2]*b[2][0];

	m[0][1] = a[0][0]*b[0][1] + a[0][1]*b[1][1] + a[0][2]*b[2][1];
	m[1][1] = a[1][0]*b[0][1] + a[1][1]*b[1][1] + a[1][2]*b[2][1];
	m[2][1] = a[2][0]*b[0][1] + a[2][1]*b[1][1] + a[2][2]*b[2][1];

	m[0][2] = a[0][0]*b[0][2] + a[0][1]*b[1][2] + a[0][2]*b[2][2];
	m[1][2] = a[1][0]*b[0][2] + a[1][1]*b[1][2] + a[1][2]*b[2][2];
	m[2][2] = a[2][0]*b[0][2] + a[2][1]*b[1][2] + a[2][2]*b[2][2];
	return m;

    }

    private void toIdentity(float[][] a) {
	a[0][0] = 1; a[0][1] = 0; a[0][2] = 0;
	a[1][0] = 0; a[1][1] = 1; a[1][2] = 0;
	a[2][0] = 0; a[2][1] = 0; a[2][2] = 1;
    }

}
