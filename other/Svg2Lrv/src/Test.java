import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Writer;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import net.sourceforge.opensvgviewer.Polygon;
import net.sourceforge.opensvgviewer.Scene;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;


public class Test {

	public static void main(String[] args) {
		Scene scene;
		String filename = "";
		String path;
		Document doc;
		DocumentBuilder db;
		DocumentBuilderFactory docBuilderFactory;

		docBuilderFactory = DocumentBuilderFactory.newInstance();

		try {
			db = docBuilderFactory.newDocumentBuilder();
		} catch (ParserConfigurationException pce) {
			System.out
					.println("Viewer.ERRO: Cannot create new Document Builder");
		}

		try {
			docBuilderFactory = DocumentBuilderFactory.newInstance();
			docBuilderFactory.setValidating(false);
			docBuilderFactory.setNamespaceAware(false);
			docBuilderFactory.setXIncludeAware(false);
			db = docBuilderFactory.newDocumentBuilder();

			doc = db.parse(new File("test.svg"));
			scene = new Scene();
			scene.reset();
			Parser.parse(doc, scene);
			System.out.println(scene);
			
			OutputStream out = new FileOutputStream("test.lvi");
						
			for (Object o : scene.getObjects()) {			
				System.out.println(o);
				if (o instanceof Polygon) {
					Polygon poly = (Polygon)o;
					System.out.println(poly.getFillColor().getRed() + ", " + poly.getFillColor().getGreen() + ", " + poly.getFillColor().getBlue());
					byte col = (byte)(7 * (poly.getFillColor().getRed()+poly.getFillColor().getGreen()+poly.getFillColor().getBlue())/(3*255));
					if (col > 15) {
						col = 15;
					}
					out.write(col);
					for (int i = 0; i != poly.px.length; i++) {
						int x = (int)(poly.px[i] * 128 / 400);
						int y = (int)(poly.py[i] * 128 / 300);
						out.write(x & 0xFF);
						out.write(y & 0xFF);
					}
					out.write(240);
				}
			}
			out.write(254);
			out.write(255);
			out.close();
			
			InputStream is = new FileInputStream("test.lvi");
			PrintWriter wr = new PrintWriter(new FileWriter("test.txt"));
			int n;
			while ((n = is.read()) != -1) {
				wr.print(n);
				wr.print(',');
			}
			wr.close();
		} catch (SAXException se) {
			System.out.println("Viewer.ERRO: " + se.getMessage());
			se.printStackTrace();
			System.exit(1);
		} catch (IOException ioe) {
			System.out.println("Viewer.ERRO: " + ioe.getMessage());
			ioe.printStackTrace();
			System.exit(1);
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
	}
}
