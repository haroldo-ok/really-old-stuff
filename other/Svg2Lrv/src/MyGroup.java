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
import net.sourceforge.opensvgviewer.*;


import org.w3c.dom.*;
import java.awt.Color;
import java.util.*;

/* Representation of a group of elements. */
public class MyGroup extends Shape {
    	/** value that hold the translate transformation */
    	float tfx=0,tfy=0;
    	/** value that hold the rotation transformation */
    	float rot=0;
    	/** value that hold the rotation transformation */
    	float scl=1;

    	/** vector that holds the elements */
    	Vector vobjs = new Vector();

public MyGroup (Node nd, Color stroke, Color fill, float tfx, float tfy, float rot)
{
	setStrokeColor(stroke);
	this.tfx = tfx;
	this.tfy = tfy;
	this.rot = rot;
    	NamedNodeMap attribs = nd.getAttributes();
        for (int i = 0; i < attribs.getLength(); i++) {
            	Node att = attribs.item(i);
            	String t_att = att.getNodeName();
        	if (t_att.equals("stroke")){
        		setStrokeColor((String)att.getNodeValue());
	       	}
        	if (t_att.equals("fill")){
        		setFillColor((String)att.getNodeValue());
	       	}
        	if (t_att.equals("style")){
		    String sty = (String)att.getNodeValue();
		    setStyle(sty);
	       	}
        	if (t_att.equals("transform")){
        		String trf = (String)att.getNodeValue();
        		setTransform(trf);
	       	}
        }

        for (Node child = nd.getFirstChild(); child != null; child = child.getNextSibling()) {
            	create(child);
        }
    }


/** Method that creates the elements from the child's group nodes.
* @param Node nodo
*/
private void create(Node ndc)
{
    	String t_elem = ndc.getNodeName();
    	if (t_elem.equals("g")) {
            MyGroup gp = new MyGroup(ndc,strokeColor,fillColor,this.tfx,this.tfy,this.rot);
		Vector vct = gp.getVobjs();
            for (int id=0;id<vct.size();id++){
            	vobjs.addElement(vct.elementAt(id));
            }
            vct.removeAllElements();
        }
      	if (t_elem.equals("rect")) {
            GRect r = Parser.rect(ndc);
            if (!r.isStroked()) r.setStrokeColor(strokeColor);
            if (!r.isFilled()) r.setFillColor(fillColor);
            vobjs.addElement(r);
        }
    	if (t_elem.equals("line")) {
    	    GLine l = Parser.line(ndc);
            if (!l.isStroked()) l.setStrokeColor(strokeColor);
            vobjs.addElement(l);
	}
    	if (t_elem.equals("circle")) {
    	    GCircle c = Parser.circle(ndc);
            if (!c.isStroked()) c.setStrokeColor(strokeColor);
            if (!c.isFilled()) c.setFillColor(fillColor);
            vobjs.addElement(c);
	}
        // Improving to suport in next version					
    	/*if (t_elem.equals("ellipse")) {
    	    GEllipse e = Parser.ellipse(ndc);
            if (!e.isStroked()) e.setStrokeColor(strokeColor);
            if (!e.isFilled()) e.setFillColor(fillColor);
            vobjs.addElement(e);
	}*/
    	if (t_elem.equals("polygon")) {
    	    GPolygon pg = Parser.polygon(ndc);
            if (!pg.isStroked()) pg.setStrokeColor(strokeColor);
            if (!pg.isFilled()) pg.setFillColor(fillColor);
            vobjs.addElement(pg);
	}
	if (t_elem.equals("polyline")) {
	    try {
    	    	GPolyline pl = Parser.polyline(ndc);
            	if (!pl.isStroked()) pl.setStrokeColor(strokeColor);
            	if (!pl.isFilled()) pl.setFillColor(fillColor);
            	vobjs.addElement(pl);
            } catch (OutOfMemoryError er){
            	System.out.println("Erro de memoria ao criar objecto num:: ");
            	System.exit(0);
            }
	}
	// Improving to suport in next version				
	/*if (t_elem.equals("text")) {
    	    GText st = Parser.text(ndc);
            if (!st.isStroked()) st.setStrokeColor(strokeColor);
            st.setRotation(this.rot);
            st.translate(this.tfx,this.tfy);
   	    vobjs.addElement(st);
	}
	if (t_elem.equals("image")) {
    	    GImage im = Parser.image(ndc);
    	    vobjs.addElement(im);
	}
	if (t_elem.equals("path")) {
    	    GPath pth = Parser.path(ndc);
    	    if (!pth.isStroked()) pth.setStrokeColor(strokeColor);
    	    if (!pth.isFilled()) pth.setFillColor(fillColor);
	    Color cs = pth.getStrokeColor();
	    Color cf = pth.getFillColor();
	    Vector pobjs = pth.getPathObjects();
            for (int ind=0;ind<pobjs.size();ind++){
            	if ( ((pobjs.elementAt(ind)).toString()).startsWith("OsvPolyline") ){
			((GPolyline)pobjs.elementAt(ind)).setStrokeColor(cs);
			((GPolyline)pobjs.elementAt(ind)).setFillColor(cf);
		}
		if ( ((pobjs.elementAt(ind)).toString()).startsWith("Bezier") ){
			((Bezier)pobjs.elementAt(ind)).setStrokeColor(cs);
			((Bezier)pobjs.elementAt(ind)).setFillColor(cf);
		}
		if ( ((pobjs.elementAt(ind)).toString()).startsWith("OsvLine") )
			((GLine)pobjs.elementAt(ind)).setStrokeColor(cs);
	    	vobjs.addElement(pobjs.elementAt(ind));
            }
            pobjs.removeAllElements();
	}*/
}


/** Method to get the vector that contains all the elements of the group
* @return a vector
*/
public Vector getVobjs()
{
    	return this.vobjs;
}

/** Method that takes all info about the <code>style</style>.
* @param a styled string.
*/
private void setStyle(String sty)
{
    	String sep=":; ";
    	StringTokenizer st = new StringTokenizer(sty,sep);
    	while(st.hasMoreTokens()) {
    		String style = st.nextToken();
    		String value = st.nextToken();
    		if (style.equals("stroke")){
		    setStrokeColor(value);
    		}
		if (style.equals("fill")){
		    setFillColor(value);
    		}
    	}
}

/** Method that checks is the shape has any transformation and sents a call to every method
responsable for a specific transform.
*/
private void setTransform(String trans)
{
	String sep=" ,\n\t\r";
	StringTokenizer st = new StringTokenizer(trans,sep);
	while(st.hasMoreTokens()) {
		String ttrans = st.nextToken();
		if (ttrans.startsWith("translate")) setTranslate(ttrans+","+st.nextToken());
		if (ttrans.startsWith("rotate")) setRotate(ttrans);
		if (ttrans.startsWith("scale")) setScale(ttrans);
	}
}

/** Method that applys the translation transformation to the group.
* @param string styled
*/
public void setTranslate(String trsl)
{
	String seps=" ,translate()\n\t\r";
	StringTokenizer st = new StringTokenizer(trsl,seps);
	this.tfx = Float.valueOf(st.nextToken()).floatValue();
	this.tfy = Float.valueOf(st.nextToken()).floatValue();
}

/** Method that applys the rotation transformation to the group.
* @param string styled
*/
public void setRotate(String trot)
{
	String seps=" ,rotate()\n\t\r";
	StringTokenizer st = new StringTokenizer(trot,seps);
	this.rot = Float.valueOf(st.nextToken()).floatValue();
}

/** Method that applys the scale transformation to the group.
* @param string styled
*/
public void setScale(String tscl)
{
	String seps=" ,scale()\n\t\r";
	StringTokenizer st = new StringTokenizer(tscl,seps);
	this.scl = Float.valueOf(st.nextToken()).floatValue();
}

/** Method that returns the scale transformation of the group.
* @return the scale value
*/
public float getScale()
{
	return this.scl;
}

/** Method that returns the rotation transformation of the group.
* @return the rotation value
*/
public float getRotation()
{
	return this.rot;
}

/** Method that returns the X translation transformation of the group.
* @return the X translation value.
*/
public float getTranslX()
{
	return this.tfx;
}

/** Method that returns the Y translation transformation of the group.
* @return the Y translation value.
*/
public float getTranslY()
{
	return this.tfy;
}
}
