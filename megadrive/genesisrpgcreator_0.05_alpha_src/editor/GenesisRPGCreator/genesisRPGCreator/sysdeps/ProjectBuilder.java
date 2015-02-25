/*
 * Created on 18/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.sysdeps;

import java.io.IOException;
import java.io.OutputStream;

import genesisRPGCreator.Project;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class ProjectBuilder {
	protected byte[] rawdata;

	/**
	 * 
	 */
	public ProjectBuilder() {
		super();
	}

	public void translateProject(Project proj) throws Exception {
		rawdata = null;
	}
	
	public byte[] getBytes() {
		return rawdata;
	}
	
	public void savetoStream(OutputStream os) throws IOException {
		os.write(rawdata);
	}
}
