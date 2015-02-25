/*
 * Created on 20/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.util;

import java.io.File;
import javax.swing.filechooser.FileFilter;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GenesisMapFileFilter extends FileFilter {

	/**
	 * @see javax.swing.filechooser.FileFilter#accept(java.io.File)
	 */
	public boolean accept(File f) {
        if (f.isFile()) {
            if (f.getAbsolutePath().lastIndexOf('.') == -1) {
                return false;
            }

            String fileName = f.getAbsolutePath().toLowerCase();
            
            if (fileName.endsWith(".map")) {
            	return true;
            }
            return false;
        }
        return true;
	}

	/**
	 * @see javax.swing.filechooser.FileFilter#getDescription()
	 */
	public String getDescription() {
		return "Genesis RPG Creator map file (*.map)";
	}

}
