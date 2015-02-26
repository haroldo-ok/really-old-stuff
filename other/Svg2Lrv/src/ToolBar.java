/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2003 Miguel Castro
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

import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.*;

public class ToolBar { 

    private final static int buttonSize = 24;

    private final static int N_BUTTONS = 5;
    private Rectangle buttonArea[];
    
    private static boolean downFlag;

    Viewer  viewer;

    public ToolBar(Viewer v)
    {
	viewer = v;

	/* create the buttons */
	buttonArea = new Rectangle[N_BUTTONS];
	
	Rectangle area = new Rectangle(0,0,buttonSize, buttonSize);
	for(int i=0; i<N_BUTTONS; i++) {
	    buttonArea[i] = new Rectangle(area);
	    area.x += buttonSize; // width of the button
	}
    }

    /******************/
    /* event handling */
    /******************/

    public boolean mouseDown(int x, int y) {
	downFlag = false;
	for (int i=0; i<N_BUTTONS; i++) {
	    if (buttonArea[i].inside(x, y)) {
		switch(i) {
		case 0:
		    //System.out.println("ToolBar.mouseDown.command(close)");
		    downFlag = true;
		    break;
		case 1:
		    //System.out.println("ToolBar.mouseDown.command(open)");
		    downFlag = true;
		    break;
		case 2:
		    //System.out.println("ToolBar.mouseDown.command(move)");
		    downFlag = true;
		    break;
		case 3:
		    //System.out.println("ToolBar.mouseDown.command(zoom)");
		    downFlag = true;
		    break;
		case 4:
		    //System.out.println("ToolBar.mouseDown.command(rotate)");
		    downFlag = true;
		    break;
		}
		break;
	    }
	}
	return downFlag;
    }

    public boolean mouseUp(int x, int y) {
	if (downFlag) {
	    for (int i=0; i<N_BUTTONS; i++) {
		if (buttonArea[i].inside(x, y)) {
		    switch(i) {
		    case 0:
			//System.out.println("ToolBar.mouseUp.command(close)");
			viewer.closeAction();
			break;
		    case 1:
			//System.out.println("ToolBar.mouseUp.command(open)");
			viewer.loadFileAction();
			break;
		    case 2:
			//System.out.println("ToolBar.mouseUp.command(move)");
			viewer.moveAction();
		    break;
		    case 3:
			//System.out.println("ToolBar.mouseUp.command(zoom)");
			viewer.zoomAction();
			break;
		    case 4:
			//System.out.println("ToolBar.mouseUp.command(rotate)");
			viewer.rotateAction();
			break;
		    }
		    break;
		}
	    }
	}
	return downFlag;
    }
}
