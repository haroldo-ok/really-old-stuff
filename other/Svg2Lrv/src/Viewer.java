/*
 *  This source code file is part of the "Open SVG Viewer" project.
 *  Copyright (C) 2002 PT Inova��o 
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
import net.sourceforge.opensvgviewer.Scene;

import javax.xml.parsers.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import org.w3c.dom.*;

import java.awt.*;
import java.awt.event.*;
import java.io.*;

public class Viewer extends Frame {

	/* command line starter */
	public static void main(String args[]) {
		new Viewer();
	}

	/* class constructor */
	public Viewer() {
		toolBar = new ToolBar(this);
		scene = new Scene();
		canvas = new OsvCanvas(this);

		setVisible(false);
		setResizable(true);
		WindowAdapter window = new WindowAdapter() {
			public void windowClosing(WindowEvent evt) {
				exit(0);
			}

			public void windowResized(WindowEvent evt) {
				System.out.println("resized");
			}

			public void windowIconified(WindowEvent e) {
				System.out.println("iconified");
			}

			public void windowDeiconified(WindowEvent e) {
				System.out.println("deiconified");
			}
		};
		addWindowListener(window);

		setTitle(appTitle);
		setLayout(layout);

		// gfxEngine.setLocation(new Point(100,0));
		add(canvas, BorderLayout.CENTER);

		// computador de mao
		// appWidth=250; // canvas 240 + 10 (frame border)
		// appHeight=350; // canvas 320 + 30 (frame border)
		appWidth = 200;
		appHeight = 320;

		setSize(appWidth, appHeight);
		// setLocation(10,30);

		appCenterX = (int) (appWidth / 2);
		appCenterY = (int) (appHeight / 2);

		// everything's done! ready to show it
		setVisible(true);
		// sleeping one second ... give some time to frame setVisible
		// try { Thread.sleep(1000); } catch (Exception e) { }
		// the canvas can only be initializated if the Frame is visible
		canvas.init();
		canvas.reset();
	}

	public Scene getScene() {
		return scene;
	}

	public ToolBar getToolBar() {
		return toolBar;
	}

	/** ****************************************** */
	/** ACTIONS ********************************* */
	/** ****************************************** */

	public void closeAction() {
		exit(0);
	}

	public void loadFileAction() {
		loader = new FileDialog(this, "Browse", FileDialog.LOAD);
		loader.setDirectory("../examples");
		loader.setFile("*.svg");

		// mostrar o fileDialog e esperar pelo resultado
		loader.show();

		// ok! o utilizador escolheu um ficheiro
		filename = loader.getFile();
		path = loader.getDirectory();

		if (filename != null) {

			docBuilderFactory = DocumentBuilderFactory.newInstance();

			try {
				db = docBuilderFactory.newDocumentBuilder();
			} catch (ParserConfigurationException pce) {
				System.out
						.println("Viewer.ERRO: Cannot create new Document Builder");
			}

			try {
				doc = db.parse(new File(path + filename));
				setTitle(appTitle + "[" + filename + "]");
				scene.reset();
				Parser.parse(doc, scene);
				canvas.reset();
				canvas.draw();
			} catch (SAXException se) {
				System.out.println("Viewer.ERRO: " + se.getMessage());
				System.exit(1);
			} catch (IOException ioe) {
				System.out.println("Viewer.ERRO: " + ioe.getMessage());
				System.exit(1);
			}
		}
	}

	public void moveAction() {
		canvas.setState(canvas.MOVE);
	}

	public void zoomAction() {
		canvas.setState(canvas.ZOOM);
	}

	public void rotateAction() {
		canvas.setState(canvas.ROTATE);
	}

	public boolean keyDown(Event e, int keyb) {
		if (keyb == Event.UP) {
			scene.translate(0.0f, -40.0f);
			canvas.draw();
		} else if (keyb == Event.DOWN) {
			scene.translate(0.0f, 40.0f);
			canvas.draw();
		} else if (keyb == Event.LEFT) {
			scene.translate(-40.0f, 0.0f);
			canvas.draw();
		} else if (keyb == Event.RIGHT) {
			scene.translate(40.0f, 0.0f);
			canvas.draw();
		}
		return true;
	}

	public void mousePressed(MouseEvent evt) {
		requestFocus();
	}

	private void exit(int e) {
		System.exit(e);
	}

	private final static String appTitle = "Open Gnu Viewer for Svg";
	private static Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();

	private static int appWidth = screen.width;
	private static int appHeight = screen.height;
	private static int appCenterX = (int) (appWidth / 2);
	private static int appCenterY = (int) (appHeight / 2);
	
	private static ToolBar toolBar;
	private static Scene scene;
	private static OsvCanvas canvas;
	private static BorderLayout layout = new BorderLayout();
	private static FileDialog loader;
	private static String filename = "";
	private static String path;
	private static Document doc;
	private static DocumentBuilder db;
	private static DocumentBuilderFactory docBuilderFactory;

}
