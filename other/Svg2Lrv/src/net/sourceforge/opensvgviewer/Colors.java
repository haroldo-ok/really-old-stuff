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

import java.io.*;
import java.util.*;
import java.awt.*;

public class Colors {

    public static Color RGB(String str) {
	String red = str.substring(1,3);
	String green = str.substring(3,5);
	String blue = str.substring(5,7);
	int redc = Integer.parseInt(red,16);
	int greenc = Integer.parseInt(green,16);
	int bluec = Integer.parseInt(blue,16);
	return (new Color (redc,greenc,bluec));
    }

    public Colors()    {
	this.colors.put("aliceblue", Colors.RGB("#F0F8FF"));
	this.colors.put("antiquewhite", Colors.RGB("#FAEBD7"));
	this.colors.put("aqua", Colors.RGB("#00FFFF"));
	this.colors.put("aquamarine", Colors.RGB("#7FFFD4"));
	this.colors.put("azure", Colors.RGB("#F0FFFF"));
	this.colors.put("beige", Colors.RGB("#F5F5DC"));
	this.colors.put("bisque", Colors.RGB("#FFE4C4"));
	this.colors.put("black", Colors.RGB("#000000"));
	this.colors.put("blanchedalmond", Colors.RGB("#FFEBCD"));
	this.colors.put("blue", Colors.RGB("#0000FF"));
	this.colors.put("blueViolet", Colors.RGB("#8A2BE2"));
	this.colors.put("brown", Colors.RGB("#A52A2A"));
	this.colors.put("burlywood", Colors.RGB("#DEB887"));
	this.colors.put("cadetblue", Colors.RGB("#5F9EA0"));
	this.colors.put("chartreuse", Colors.RGB("#7FFF00"));
	this.colors.put("chocolate", Colors.RGB("#D2691E"));
	this.colors.put("coral", Colors.RGB("#FF7F50"));
	this.colors.put("cornflowerblue", Colors.RGB("#6495ED"));
	this.colors.put("cornsilk", Colors.RGB("#FFF8DC"));
	this.colors.put("crimson", Colors.RGB("#DC143C"));
	this.colors.put("cyan", Colors.RGB("#00FFFF"));
	this.colors.put("darkblue", Colors.RGB("#00008B"));
	this.colors.put("darkcyan", Colors.RGB("#008B8B"));
	this.colors.put("darkgoldenrod", Colors.RGB("#B8860B"));
	this.colors.put("darkgray", Colors.RGB("#A9A9A9"));
	this.colors.put("darkgreen", Colors.RGB("#006400"));
	this.colors.put("darkkhaki", Colors.RGB("#BDB76B"));
	this.colors.put("darkmagenta", Colors.RGB("#8B008B"));
	this.colors.put("darkolivegreen", Colors.RGB("#556B2F"));
	this.colors.put("darkorange", Colors.RGB("#FF8C00"));
	this.colors.put("darkorchid", Colors.RGB("#9932CC"));
	this.colors.put("darkred", Colors.RGB("#8B0000"));
	this.colors.put("darksalmon", Colors.RGB("#E9967A"));
	this.colors.put("darkseagreen", Colors.RGB("#8FBC8F"));
	this.colors.put("darkslateblue", Colors.RGB("#483D8B"));
	this.colors.put("darkslategray", Colors.RGB("#2F4F4F"));
	this.colors.put("darkturquoise", Colors.RGB("#00CED1"));
	this.colors.put("darkviolet", Colors.RGB("#9400D3"));
	this.colors.put("deeppink", Colors.RGB("#FF1493"));
	this.colors.put("deepskyblue", Colors.RGB("#00BFFF"));
	this.colors.put("dimgray", Colors.RGB("#696969"));
	this.colors.put("dodgerblue", Colors.RGB("#1E90FF"));
	this.colors.put("firebrick", Colors.RGB("#B22222"));
	this.colors.put("floralwhite", Colors.RGB("#FFFAF0"));
	this.colors.put("forestgreen", Colors.RGB("#228B22"));
	this.colors.put("fuchsia", Colors.RGB("#FF00FF"));
	this.colors.put("gainsboro", Colors.RGB("#DCDCDC"));
	this.colors.put("ghostwhite", Colors.RGB("#F8F8FF"));
	this.colors.put("gold", Colors.RGB("#FFD700"));
	this.colors.put("goldenrod", Colors.RGB("#DAA520"));
	this.colors.put("gray", Colors.RGB("#808080"));
	this.colors.put("green", Colors.RGB("#008000"));
	this.colors.put("greenyellow", Colors.RGB("#ADFF2F"));
	this.colors.put("honeydew", Colors.RGB("#F0FFF0"));
	this.colors.put("hotpink", Colors.RGB("#FF69B4"));
	this.colors.put("indianred", Colors.RGB("#CD5C5C"));
	this.colors.put("indigo", Colors.RGB("#4B0082"));
	this.colors.put("ivory", Colors.RGB("#FFFFF0"));
	this.colors.put("khaki", Colors.RGB("#F0E68C"));
	this.colors.put("lavender", Colors.RGB("#E6E6FA"));
	this.colors.put("lavenderblush", Colors.RGB("#FFF0F5"));
	this.colors.put("lawngreen", Colors.RGB("#7CFC00"));
	this.colors.put("lemonchiffon", Colors.RGB("#FFFACD"));
	this.colors.put("lightblue", Colors.RGB("#ADD8E6"));
	this.colors.put("lightcoral", Colors.RGB("#F08080"));
	this.colors.put("lightcyan", Colors.RGB("#E0FFFF"));
	this.colors.put("lightgoldenrodyellow", Colors.RGB("#FAFAD2"));
	this.colors.put("lightgrey", Colors.RGB("#D3D3D3"));
	this.colors.put("lightgreen", Colors.RGB("#90EE90"));
	this.colors.put("lightpink", Colors.RGB("#FFB6C1"));
	this.colors.put("lightsalmon", Colors.RGB("#FFA07A"));
	this.colors.put("lightseagreen", Colors.RGB("#20B2AA"));
	this.colors.put("lightskyblue", Colors.RGB("#87CEFA"));
	this.colors.put("lightslateblue", Colors.RGB("#8470FF"));
	this.colors.put("lightslategray", Colors.RGB("#778899"));
	this.colors.put("lightsteelblue", Colors.RGB("#B0C4DE"));
	this.colors.put("lightyellow", Colors.RGB("#FFFFE0"));
	this.colors.put("lime", Colors.RGB("#00FF00"));
	this.colors.put("limegreen", Colors.RGB("#32CD32"));
	this.colors.put("linen", Colors.RGB("#FAF0E6"));
	this.colors.put("magenta", Colors.RGB("#FF00FF"));
	this.colors.put("maroon", Colors.RGB("#800000"));
	this.colors.put("mediumaquamarine", Colors.RGB("#66CDAA"));
	this.colors.put("mediumblue", Colors.RGB("#0000CD"));
	this.colors.put("mediumorchid", Colors.RGB("#BA55D3"));
	this.colors.put("mediumpurple", Colors.RGB("#9370D8"));
	this.colors.put("mediumseagreen", Colors.RGB("#3CB371"));
	this.colors.put("mediumslateblue", Colors.RGB("#7B68EE"));
	this.colors.put("mediumspringgreen", Colors.RGB("#00FA9A"));
	this.colors.put("mediumturquoise", Colors.RGB("#48D1CC"));
	this.colors.put("mediumvioletred", Colors.RGB("#C71585"));
	this.colors.put("midnightblue", Colors.RGB("#191970"));
	this.colors.put("mintcream", Colors.RGB("#F5FFFA"));
	this.colors.put("mistyrose", Colors.RGB("#FFE4E1"));
	this.colors.put("moccasin", Colors.RGB("#FFE4B5"));
	this.colors.put("navajowhite", Colors.RGB("#FFDEAD"));
	this.colors.put("navy", Colors.RGB("#000080"));
	this.colors.put("oldlace", Colors.RGB("#FDF5E6"));
	this.colors.put("olive", Colors.RGB("#808000"));
	this.colors.put("olivedrab", Colors.RGB("#6B8E23"));
	this.colors.put("orange", Colors.RGB("#FFA500"));
	this.colors.put("orangered", Colors.RGB("#FF4500"));
	this.colors.put("orchid", Colors.RGB("#DA70D6"));
	this.colors.put("palegoldenrod", Colors.RGB("#EEE8AA"));
	this.colors.put("palegreen", Colors.RGB("#98FB98"));
	this.colors.put("paleturquoise", Colors.RGB("#AFEEEE"));
	this.colors.put("palevioletred", Colors.RGB("#D87093"));
	this.colors.put("papayawhip", Colors.RGB("#FFEFD5"));
	this.colors.put("peachpuff", Colors.RGB("#FFDAB9"));
	this.colors.put("peru", Colors.RGB("#CD853F"));
	this.colors.put("pink", Colors.RGB("#FFC0CB"));
	this.colors.put("plum", Colors.RGB("#DDA0DD"));
	this.colors.put("powderblue", Colors.RGB("#B0E0E6"));
	this.colors.put("purple", Colors.RGB("#800080"));
	this.colors.put("red", Colors.RGB("#FF0000"));
	this.colors.put("rosybrown", Colors.RGB("#BC8F8F"));
	this.colors.put("royalblue", Colors.RGB("#4169E1"));
	this.colors.put("saddlebrown", Colors.RGB("#8B4513"));
	this.colors.put("salmon", Colors.RGB("#FA8072"));
	this.colors.put("sandybrown", Colors.RGB("#F4A460"));
	this.colors.put("seagreen", Colors.RGB("#2E8B57"));
	this.colors.put("seashell", Colors.RGB("#FFF5EE"));
	this.colors.put("sienna", Colors.RGB("#A0522D"));
	this.colors.put("silver", Colors.RGB("#C0C0C0"));
	this.colors.put("skyblue", Colors.RGB("#87CEEB"));
	this.colors.put("slateblue", Colors.RGB("#6A5ACD"));
	this.colors.put("slategray", Colors.RGB("#708090"));
	this.colors.put("snow", Colors.RGB("#FFFAFA"));
	this.colors.put("springgreen", Colors.RGB("#00FF7F"));
	this.colors.put("steelblue", Colors.RGB("#4682B4"));
	this.colors.put("tan", Colors.RGB("#D2B48C"));
	this.colors.put("teal", Colors.RGB("#008080"));
	this.colors.put("thistle", Colors.RGB("#D8BFD8"));
	this.colors.put("tomato", Colors.RGB("#FF6347"));
	this.colors.put("turquoise", Colors.RGB("#40E0D0"));
	this.colors.put("violet", Colors.RGB("#EE82EE"));
	this.colors.put("violetred", Colors.RGB("#D02090"));
	this.colors.put("wheat", Colors.RGB("#F5DEB3"));
	this.colors.put("white", Colors.RGB("#FFFFFF"));
	this.colors.put("whitesmoke", Colors.RGB("#F5F5F5"));
	this.colors.put("yellow", Colors.RGB("#FFFF00"));
	this.colors.put("yellowgreen", Colors.RGB("#9ACD32"));
    }

    public Color getColor(String clr){
	String cor = clr.toLowerCase();
	return (Color)this.colors.get(cor);
    }

    public static Hashtable colors = new Hashtable();
}

