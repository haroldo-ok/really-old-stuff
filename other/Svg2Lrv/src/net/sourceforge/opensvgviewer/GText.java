package net.sourceforge.opensvgviewer;

import java.awt.*;

public class GText extends Text implements Drawable {

    public GText () {}

    public void draw (Graphics g, Scene scene) {

	if (scaleFactor != scene.getScale()) {
	    scaleFactor = scene.getScale();
	    // atenção este método é muito dispendioso
	    // e provoca a intervenção do Garbage Colector
	    // o que faz com que a aplicação "pare" (durante alguns milisegundos)
	    font = new Font( text, fontStyle, (int)( fontSize * scaleFactor ));
	    //font = font.deriveFont( (float)(fontSize * scaleFactor) ); // disponivel apartir do java 1.2
	    fontMetric = Toolkit.getDefaultToolkit().getFontMetrics(font);
	    strH = Math.abs( fontMetric.getHeight() ); // verificar se é necessário o <Math.abs>
	}
	
	//strH = Math.abs( fontMetric.getHeight() ); // verificar se é necessário o <Math.abs>
	//System.out.println("GText.draw strH["+strH+"]");

	//maux = font.getTransform();
	//maux.rotate((45*Math.PI)/180, 1, 1 );

	if ( strH > 4 ) {

	    scene.computeXY( pxy, xy, 2);
	    
	    g.setColor(strokeColor);
	    g.setFont(font);	
	    
	    g.drawString(text, (int)xy[0], (int)xy[1]);
	    
	}
	
    }

    private int[] xy = new int[2];
    private float scaleFactor=-1; // to save the last used scale factor
    private int strH=0; // to check if a string is big enough to be draw

    private Font font = new Font("", 0, 0);
    private FontMetrics fontMetric;
    
}
