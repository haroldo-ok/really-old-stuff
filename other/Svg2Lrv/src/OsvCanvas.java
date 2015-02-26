/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2003 Miguel Angelo Couto Castro
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
import net.sourceforge.opensvgviewer.Drawable;
import net.sourceforge.opensvgviewer.Scene;

import java.awt.*;
import java.awt.image.*;
import java.util.*;

public class OsvCanvas extends Canvas{
    
    /* constructor */
    public OsvCanvas(Viewer v) {
	toolBar = v.getToolBar();
	scene = v.getScene();
	objects = scene.getObjects();
	
	// load the toolbar image
	//Image tempImage = loadImageSync("menu.jpg");
	Image tempImage = Toolkit.getDefaultToolkit().getImage("menu.jpg"); //enter full path to view toolbar path in PDA
	toolBarImage = CropImageSync ( tempImage, 0, 0, 120, 24 );
    }
    
    /***********************************************************************************/
    /** STATE MACHINE ******************************************************************/
    /***********************************************************************************/
    public void setState(int s) {
	state = s;
    }
    
    /***********************************************************************************/
    /** GRAPHICS ***********************************************************************/
    /***********************************************************************************/

    /**
     * Initialize the draw area with the applet window dimensions
     * and get a referenc to the Graphics Context of the created Image
     * also get a reference to the current frontbuffer graphics
     * @author Miguel Angelo - 26/06/2003
     */
    public void init() {
	// init the screen viewport size
	canvasWidth = 240;//size().width;
	canvasHeight = 320;//size().height;
	canvasCenterX = (int)(canvasWidth/2);
	canvasCenterY = (int)(canvasHeight/2);
	screenBBox.width = canvasWidth;
	screenBBox.height = canvasHeight;
    		
	// Try to create an off-screen drawing buffer
	// for double-buffered graphics...
	try	
	{
	    backImage  = createImage(canvasWidth, canvasHeight);
	    backBuffer = backImage.getGraphics();	    
	}
	catch (Exception e) 
	{
	    System.out.println("Failed to set up double-buffered graphics");
	    backImage = null;
	    backBuffer = null;
	    return;
	} 

	// get a reference to the current frontbuffer
	frontBuffer = getGraphics();
    }

    /**
     * Reset all the scene to load a new file.
     * @author Miguel Angelo 30/06/2003 */
    public void reset(){
	state = MOVE; 	
	objectsSize = objects.size();
	backBuffer.setColor( backColor );
	backBuffer.fillRect(0, 0, canvasWidth, canvasHeight);
    }

    public void draw() {
	/* clear the back buffer */
	backBuffer.setColor(Color.white);
	backBuffer.fillRect(0, 0, canvasWidth, canvasHeight);
	
	/* draw all the objects in to the backbuffer */
        for(i=0; i<objectsSize; i++)
	    ((Drawable)(objects.elementAt(i))).draw(backBuffer, scene);
                	
	// now that we have finish drawing in the backbuffer, refresh the frontbuffer with the backbuffer contents
	paint(getGraphics());//frontBuffer);
    }

    /**
     * just draw the backbuffer image on the frontbuffer
     * @author Miguel Angelo 30/06/2003
     */
    public void paint(Graphics g)
    {
        // the last thing to do before paint is to draw the toolbar in the backbuffer
	backBuffer.drawImage(toolBarImage, 0, 0, this);
        
	// draw to lines crossing in the center of the canvas
	//backBuffer.setColor(Color.black);
	//backBuffer.drawLine(canvasWidth/2,0,canvasWidth/2,canvasHeight);
	//backBuffer.drawLine(0,canvasHeight/2,canvasWidth,canvasHeight/2);

	// now paint the backbuffer in the frontbuffer
	g.drawImage(backImage, 0, 0, this); 	    //  Just display the "back" buffer
    }

    //If we don't specify this, the canvas might not show up at all
    //(depending on the layout manager).
    //public Dimension minimumSize()
    //{
    //    return new Dimension(150,130);
    //}

    //If we don't specify this, the canvas might not show up at all
    //(depending on the layout manager).
    //public Dimension preferredSize()
    //{
    //    return minimumSize();
    //}

    /***********************************************************************************/
    /** EVENTS *************************************************************************/
    /***********************************************************************************/

    /** Mouse down event.
     * @author Miguel Angelo */
    public boolean mouseDown(Event e, int x, int y)
    {
	// send the event to the toolbar
	if ( ! toolBar.mouseDown(x, y) ) {
	    
	    // save the current mouse coords
	    mouseDownX = x;
	    mouseDownY = y;
	    mouseOldX = x;
	    mouseOldY = y;
	    
	    // calculate the zoom rectangle aspect ratio
	    zoomAspectRatio = (float)canvasHeight / (float)canvasWidth;
	    
	    // refresh the screen viewport boudingBox
	    screenBBox.width = canvasWidth;
	    screenBBox.height = canvasHeight;

	}
	return true;
    }

    /** Mouse drag event.
     * @author Miguel Angelo - 26/06/2003 */
    public boolean mouseDrag(Event e, int x, int y)
    {
	if(state == MOVE){
	    //if ( x != mouseOldX || y != mouseOldY ) {
		scene.translate( x - mouseOldX , y - mouseOldY );
		draw();
		//}	
	}
	else if(state == ZOOM){
	    if (Math.abs( x - mouseDownX) > areaZoomTrigger)
		state = ZOOM_AREA;
	    else if (Math.abs( y - mouseDownY) > freeZoomTrigger)
		state = ZOOM_FREE;
        }
	else if ( state == ZOOM_AREA ) {
	    computeZoomArea(x, y);
	    // all the calc done! now put the zoom rectangle on top of the everything (frontbuffer)
	    paint(frontBuffer);

	    // paint the real zoom window - for debug
	    //frontBuffer.setColor( Color.red );
	    //frontBuffer.drawRect( zoomCoordX, zoomCoordY, zoomCoordW, zoomCoordH);

	    // paint the user zoom window
	    frontBuffer.setColor( Color.black );
	    frontBuffer.drawRect( zoomRectX1, zoomRectY1, zoomRectX2 - zoomRectX1, zoomRectY2 - zoomRectY1);
	}
	else if ( state == ZOOM_FREE ) {
	    if ( y > mouseOldY) {
		scene.scale(canvasCenterX, canvasCenterY, 1 - (float)(y - mouseOldY)/canvasHeight ); // zoom out
		draw();
	    }
	    else if ( y < mouseOldY) {
		scene.scale(canvasCenterX, canvasCenterY, 1 + (float)(mouseOldY - y)/canvasHeight ); // zoom in
		draw();
	    }
	}

	mouseOldX = x;
	mouseOldY = y;

	return true;
    }

    /**
     * Mouse up event. Used to calculate the new values for elements in pan and zoom area. 
     * To increase the performance in pan image buffer is moved while a thread is calculating the new values for
     * all elements.     
     * @author Miguel Angelo - 27/06/2003
     */    
    public boolean mouseUp(Event e, int x, int y)
    {
	// send the event to the toolbar
	if ( ! toolBar.mouseUp(x, y) ) {
	    if(state == ZOOM_AREA){
		computeZoomArea(x, y);
		if ( zoomCoordW != 0 && zoomCoordH != 0 ) {
		    scene.scale( -zoomCoordX, -zoomCoordY,
				 (float)canvasWidth / (float)zoomCoordW, (float)canvasHeight / (float)zoomCoordH);
		    draw();
		} else {
		    System.out.println("OsvCanvas. AVISO: evitar esta situação");
		}
		// return to zoom query state
		state = ZOOM;
	    }
	    else if (state == ZOOM_FREE) {
		// return to zoom query state
		state = ZOOM;
	    }
	    else if (state == ROTATE) {
		scene.rotate(x, y, (float)((90*Math.PI)/180));
		draw();
	    }
	}

	return true;
    }

    /*
    public boolean handleEvent(Event evt)
    {
        if (evt.target instanceof Canvas)
        {
	    
            return true;
        }
        else
        {
            boolean result = super.handleEvent(evt);
            return result;
        }
    }
    */

    /***********************************************************************************/
    /** UTILS **************************************************************************/
    /***********************************************************************************/
    
    private void computeZoomArea(int x, int y) {
	zoomRectX1 = mouseDownX;
	zoomRectY1 = mouseDownY;
	zoomRectX2 = x;
	zoomRectY2 = y;

	int aux;
	if (zoomRectX1 > zoomRectX2) { aux = zoomRectX1; zoomRectX1 = zoomRectX2; zoomRectX2 = aux; }
	if (zoomRectY1 > zoomRectY2) { aux = zoomRectY1; zoomRectY1 = zoomRectY2; zoomRectY2 = aux; }

	zoomCoordX = zoomRectX1;
	zoomCoordY = zoomRectY1;

	zoomCoordW = zoomRectX2 - zoomRectX1;
	zoomCoordH = zoomRectY2 - zoomRectY1;

	int w_save = zoomCoordW;
	int h_save = zoomCoordH;

	int h_aux = (int)(zoomCoordW * zoomAspectRatio);
	int w_aux = (int)(zoomCoordH / zoomAspectRatio);

	if ( zoomCoordH < h_aux ) {    
	    zoomCoordH = h_aux;
	    zoomCoordY = zoomRectY1 - (int)((zoomCoordH - h_save)/2);
	}
	else if ( zoomCoordW < w_aux ) {
	    zoomCoordW = w_aux;
	    zoomCoordX = zoomRectX1 - (int)((zoomCoordW - w_save)/2);
	}
    }

    /**
     * Method to load an image, and wait for it to load.
     * @param String imgFile the image file name and path
     * @return Image a new image
     * @author Miguel Angelo - 27/06/2003
     */
    private Image loadImageSync( String imgFile )
    {
	MediaTracker  mt;
	Image         img;
	
	// start the image loading
	img = getToolkit().getImage(imgFile);
	mt = new MediaTracker(this);
	mt.addImage( img, 0 );
	
	// wait until the image be fully loaded
	try	 { mt.waitForAll(); }
	catch(Exception e) { img = null; };
	
	if( img == null )
	    System.err.println( "Error loading image: '" + imgFile + "'" );
	
	return img;
    }

    /**
     * Method to crop an image, and wait for it to finish.
     * @param Image the image
     * @return Image a new croped image
     * @author Miguel Angelo - 27/06/2003
     */
    private Image CropImageSync( Image source, int x, int y, int w, int h)
    {
	MediaTracker	mt;
	Image		img;
	CropImageFilter crop;
	
	// Começar o carregamento da Imagem
	crop  = new CropImageFilter(x,y,w,h);
	img = createImage(new FilteredImageSource(source.getSource(), crop));
	
	mt = new MediaTracker(this);
	mt.addImage( img, 0 );
	
	// Esperar até que o carregamento esteja concluido
	try	 { mt.waitForAll(); }
	catch(Exception e) { img = null; };
	
	if( img == null )
	    System.err.println( "Error cutting image" );
	
	return img;
    }

    /***********************************************************************************/
    /** PRIVATE FINALS *****************************************************************/
    /***********************************************************************************/

    /* auxiliar variable to save the zoom box coords in the correct order */
    private final static int areaZoomTrigger = 6; //  the x distance needed to confirm the Area Zoom
    private final static int freeZoomTrigger = 10; //  the y distance needed to confirm the Free Zoom
    private final static float freeZoomIn = (float)1.05; // free zoom increment to zoom in
    private final static float freeZoomOut = (float)0.95; // free zoom increment to zoom out

    /***********************************************************************************/
    /** PRIVATE ************************************************************************/
    /***********************************************************************************/

    /* Where the draw is done before being sent to the frontBuffer.
     * @author Miguel Angelo */
    private int      canvasWidth, canvasHeight, canvasCenterX, canvasCenterY;
    private Graphics frontBuffer; // reference to the current graphics context
    private Image    backImage;
    private Graphics backBuffer;
    private Color    backColor = new Color(255, 255, 255); // Background colour
    private ToolBar  toolBar;
    private Image    toolBarImage;
    private Scene scene;   // reference to the OscScene
    private Vector   objects; // reference to the Objects Vector at Scene

    /* bounding box - utilizado para saber se uma primitiva se encontra na àrea de visualização
     */
    private Rectangle boundingBox = new Rectangle();
    private Rectangle screenBBox =  new Rectangle(); // the location of the screen viewport

    /* auxiliar variables to suport the mouse methods */
    private int mouseOldX;
    private int mouseOldY;
    private int mouseDownX;
    private int mouseDownY;

    // auxiliar variavels for zoom suport
    private float zoomAspectRatio;
    private int zoomRectX1, zoomRectY1,	zoomRectX2, zoomRectY2;
    private int zoomCoordX, zoomCoordY, zoomCoordW, zoomCoordH;

    private int i, objectsSize; // counter and size of the Objects Vector
    private int cx, cy;
    private float alfW, alfH;

    /* state machine */
    private int state;
    public final static int 
	MOVE = 0,
	ZOOM = 1,
	ZOOM_AREA = 2,
	ZOOM_FREE = 3,
	ROTATE = 4;

}
