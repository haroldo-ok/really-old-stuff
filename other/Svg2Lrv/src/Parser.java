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
import net.sourceforge.opensvgviewer.*;


import javax.xml.parsers.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import org.w3c.dom.*;

import java.io.*;
import java.awt.Color;
import java.awt.image.*;
import java.util.*;
import java.applet.*;

import java.lang.*;

class Parser {

    public static void parse(Node node, Scene scene) {
	int t = node.getNodeType();
	switch (t) {
        case Node.ATTRIBUTE_NODE: break;
        case Node.CDATA_SECTION_NODE: break;
        case Node.COMMENT_NODE: break;
        case Node.DOCUMENT_FRAGMENT_NODE: break;
        case Node.DOCUMENT_NODE: break;
        case Node.DOCUMENT_TYPE_NODE: break;
	case Node.ELEMENT_NODE:
	    if ((node.getNodeName()).equals("svg"))
            	elements(node, scene);
            break;
        case Node.ENTITY_NODE: break;
        case Node.ENTITY_REFERENCE_NODE: break;
        case Node.NOTATION_NODE: break;
        case Node.PROCESSING_INSTRUCTION_NODE: break;
        case Node.TEXT_NODE: break;
        default: break;
	}

	for (Node n=node.getFirstChild(); n!=null; n=n.getNextSibling()) {
	    Parser.parse(n, scene);
        }
    }

    public static void elements(Node nd, Scene scene) {
    	String t_elem = nd.getNodeName();
    	if (t_elem.equals("svg")) {
            OsvSVG svg = Parser.svg(nd);
	    if (svg.hasViewbox()) {
		scene.translate( -svg.getViewboxX(), -svg.getViewboxY());
		//scene.scale(svg.getX(),svg.getY(),(svg.getWidth()/svg.getViewboxWidth()),(svg.getWidth()/svg.getViewboxWidth()));
		scene.scale((int)svg.getX(),(int)svg.getY(),(svg.getWidth()/svg.getViewboxWidth()));
	    }
	    for (Node child = nd.getFirstChild();
		 child != null;
		 child = child.getNextSibling()) {
	    	Parser.elements(child,scene);
            }
        }    	    	
    	if (t_elem.equals("g")) {
            MyGroup gp = new MyGroup( nd, Color.black, Color.white, 1, 1, 0);
            Vector gobjs = gp.getVobjs();
            for (int ind=0;ind<gobjs.size();ind++){
		//scene.objects.addElement(gobjs.elementAt(ind));
		scene.addNode(gobjs.elementAt(ind));
            }
            gobjs.removeAllElements();
        } else if (t_elem.equals("circle")) {
            //scene.objects.addElement(Parser.circle(nd));
	    scene.addNode(Parser.circle(nd));
	} 
	// Improving to suport in next version					
	/*else if (t_elem.equals("ellipse")) {
            //scene.objects.addElement(Parser.ellipse(nd));
	    scene.addNode(Parser.ellipse(nd));
	}*/ else if (t_elem.equals("line")) {
            //scene.objects.addElement(Parser.line(nd));
	    scene.addNode(Parser.line(nd));
	} else if (t_elem.equals("rect")) {
            //scene.objects.addElement(Parser.rect(nd));
	    scene.addNode(Parser.rect(nd));
        }
    	if (t_elem.equals("polygon")) {
    	    try {	
    	    	Polygon pg = Parser.polygon(nd);
            	//scene.objects.addElement(pg);
		scene.addNode(pg);
             } catch (OutOfMemoryError er){
            	System.out.println("Erro de memoria ao criar objecto num:: ?");
            	System.exit(0);
            }
	}			
	if (t_elem.equals("polyline")) {
	    try {
    	    	Polyline pl = Parser.polyline(nd);
            	//scene.objects.addElement(pl);
		scene.addNode(pl);
            } catch (OutOfMemoryError er){
            	System.out.println("Erro de memoria ao criar objecto num:: ?");
            	System.exit(0);
            }
	}		
	// Improving to suport in next version				
	/*if (t_elem.equals("text")) {
    	    //scene.objects.addElement(Parser.text(nd));
	    scene.addNode(Parser.text(nd));
	}
	if (t_elem.equals("image")) {
	    //scene.objects.addElement(Parser.image(nd));
	    scene.addNode(Parser.image(nd));
	}				
	if (t_elem.equals("path")) {
    	    Path pth = Parser.path(nd);
	    Color cs = pth.getStrokeColor();
	    Color cf = pth.getFillColor();
	    Vector pobjs = pth.getPathObjects();	
            for (int ind=0;ind<pobjs.size();ind++){
            	if ( ((pobjs.elementAt(ind)).toString()).startsWith("Polyline") ){
			((Polyline)pobjs.elementAt(ind)).setStrokeColor(cs);
			((Polyline)pobjs.elementAt(ind)).setFillColor(cf);
		}
		if ( ((pobjs.elementAt(ind)).toString()).startsWith("Bezier") ){
			((Bezier)pobjs.elementAt(ind)).setStrokeColor(cs);				
			((Bezier)pobjs.elementAt(ind)).setFillColor(cf);					
		}
		if ( ((pobjs.elementAt(ind)).toString()).startsWith("Line") )		
			((Line)pobjs.elementAt(ind)).setStrokeColor(cs);				
	    	//scene.objects.addElement(pobjs.elementAt(ind));
		scene.addNode(pobjs.elementAt(ind));
		
            }
            pobjs.removeAllElements();
	}*/
	if (t_elem.equals("desc")) {
		Node child = nd.getFirstChild();
		//scene.desc = child.getNodeValue().trim();
		scene.setDesc(child.getNodeValue().trim());
	} else
	    //scene.desc = "Description not available";
	    scene.setDesc("Description not available");
	if (t_elem.equals("title")) {
		Node child = nd.getFirstChild();
		//scene.title = child.getNodeValue().trim();
		scene.setTitle(child.getNodeValue().trim());
	} else
	    //scene.title = "Title not available";	
	    scene.setTitle("Title not available");
    }

    public static GCircle circle(Node node) {
	GCircle obj = new GCircle();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("cx")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("cy")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("r")) {
		obj.setRadius(Float.valueOf(value).floatValue());
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	return obj;
    }
    
    // Improving to suport in next version				
    /*public static GEllipse ellipse(Node node) {
	GEllipse obj = new GEllipse();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("cx")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("cy")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("rx")) {
		obj.setXRadius(Float.valueOf(value).floatValue());
	    } else if (name.equals("ry")) {
		obj.setYRadius(Float.valueOf(value).floatValue());
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	return obj;
    }

    public static GImage image(Node node) {
	GImage obj = new GImage();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("x")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("y")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("height")) {
		obj.setHeight(Float.valueOf(value).floatValue());
	    } else if (name.equals("width")) {
		obj.setWidth(Float.valueOf(value).floatValue());
	    } else if (name.equals("xlink:href")) {
		obj.setLink(value);
	    }
	}
	return obj;
    }*/

    public static GLine line(Node node) {
	GLine obj = new GLine();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("x1")) {
		obj.setX1(Float.valueOf(value).floatValue());
	    } else if (name.equals("y1")) {
		obj.setY1(Float.valueOf(value).floatValue());
	    } else if (name.equals("x2")) {
		obj.setX2(Float.valueOf(value).floatValue());
	    } else if (name.equals("y2")) {
		obj.setY2(Float.valueOf(value).floatValue());
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	return obj;
    }
    
    // Improving to suport in next version				
    /*public static GPath path(Node node) {
	GPath obj = new GPath();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("d")) {
		Parser.addPath(obj, value);
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	return obj;
    }*/

    public static GPolygon polygon(Node node) {
	GPolygon obj = new GPolygon();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("points")) {
		String sep = ", ";
		Vector coords = new Vector();
		StringTokenizer st = new StringTokenizer(value, sep);
		while (st.hasMoreTokens())
		    coords.addElement(st.nextToken());
		obj.np = coords.size()/2;
		obj.px = new float[coords.size()/2];
		obj.py = new float[coords.size()/2];
		for (int j=0; j<coords.size(); j++)
		    obj.str2pts((String)coords.elementAt(j), j);
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	obj.compile();
	return obj;
    }

    public static GPolyline polyline(Node node) {
	GPolyline obj = new GPolyline();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("points")) {
		String sep = ", ";
		Vector coords = new Vector();
		StringTokenizer st = new StringTokenizer(value, sep);
		while (st.hasMoreTokens())
		    coords.addElement(st.nextToken());
		obj.np = coords.size()/2;
		obj.px = new float[coords.size()/2];
		obj.py = new float[coords.size()/2];
		for (int j=0; j<coords.size(); j++)
		    obj.str2pts((String)coords.elementAt(j), j);		
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	obj.compile();
	return obj;
    }

    public static GRect rect(Node node) {
	GRect obj = new GRect();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("x")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("y")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("height")) {
		obj.setHeight(Float.valueOf(value).floatValue());
	    } else if (name.equals("width")) {
		obj.setWidth(Float.valueOf(value).floatValue());
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("fill")) {
		obj.setFillColor(value);
	    } else if (name.equals("style")) {
		Parser.setStyle(obj, value);
	    }
	}
	return obj;
    }

    public static GSVG svg(Node node) {
	GSVG obj = new GSVG();
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("x")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("y")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("viewBox")) {
		obj.str2pts(value);
	    } else if (name.equals("height")) {
		obj.convStrHei(value);
	    } else if (name.equals("width")) {
		obj.convStrWid(value);
	    } 
	}
	return obj;
    }
    
    // Improving to suport in next version				
    /*public static GText text(Node node) {
	GText obj = new GText();
	obj.setText(node.getFirstChild().getNodeValue().trim());
	NamedNodeMap attributes = node.getAttributes();
	for (int i=0; i<attributes.getLength(); i++) {
	    Node att = attributes.item(i);
	    String name = att.getNodeName();
	    String value = att.getNodeValue();
	    if (name.equals("x")) {
		obj.setX(Float.valueOf(value).floatValue());
	    } else if (name.equals("y")) {
		obj.setY(Float.valueOf(value).floatValue());
	    } else if (name.equals("stroke")) {
		obj.setStrokeColor(value);
	    } else if (name.equals("font-family")) {
		obj.setFontFamily(value);
	    } else if (name.equals("font-size")) {
		obj.setFontSize(Float.valueOf(value).intValue());
	    } else if (name.equals("font-weight")) {
		obj.setFontSize(obj.getFontSize()+1);
	    } else if (name.equals("font-style")) {
		obj.setStyle(value);
	    } else if (name.equals("style")) {
		obj.setStyle(value);
	    }
	}
	return obj;
    }

    public static void addPath(Path path, String string) {
	String sep = "AaCcHhLlMmQqSsTtVvZz";
	StringTokenizer st = new StringTokenizer(string,sep,true);
	while (st.hasMoreTokens()){
	    String act_sep = st.nextToken();
	    if (act_sep.equals("M") || act_sep.equals("m")) {
		String param = st.nextToken();
		path.addMoveTo(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("L") || act_sep.equals("l")) {
		String param = st.nextToken();
		path.addLineTo(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("H") || act_sep.equals("h")) {
		String param = st.nextToken();
		path.addHorizLine(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("V") || act_sep.equals("v")) {
		String param = st.nextToken();
		path.addVertLine(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("C") || act_sep.equals("c")) {
		String param = st.nextToken();
		path.addCubicBezier(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("Q") || act_sep.equals("q")) {
		String param = st.nextToken();
		path.addQuadBezier(act_sep,param);
		Path.lastToken = act_sep;
	    }
	    if (act_sep.equals("Z") || act_sep.equals("z")) {
		path.addClose(act_sep);
	    }
	}
	path.addMoveTo("m","0,0");
    }*/

    public static void setStyle(Shape shape, String s) {
    	String sep=":; ";
    	StringTokenizer st = new StringTokenizer(s,sep);
    	while(st.hasMoreTokens()) {
	    String style = st.nextToken();
	    String value = st.nextToken();
	    if (style.equals("stroke")) {
		shape.setStrokeColor(value);
	    }
	    if (style.equals("fill")) {
		shape.setFillColor(value);
	    }
    	}
    }
}
