/*
 * Created on 23/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.gfs;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import genesisRPGCreator.util.CollectionVector;
import genesisRPGCreator.util.ResourceItem;
import genesisRPGCreator.util.Util;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class GFS extends CollectionVector {

	/**
	 * 
	 */
	public GFS() {
		super();
		// TODO Auto-generated constructor stub
	}

	public byte[] getData() throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		saveToStream(bos);
		
		return bos.toByteArray();
	}
	
	public void saveToStream(OutputStream os) throws IOException {
		ByteArrayOutputStream head = new ByteArrayOutputStream();		
		ByteArrayOutputStream body = new ByteArrayOutputStream();
		
		sort();
		Util.writeLongReverse(size(), head);
		
		int headersize = ((size()*GFSDirEntry.getEntrySize())+4+15) & 0x7FFFFFF0; // 16 byte-aligned
		int currofs = headersize;
		for(int i = 0; i != size(); i++) {
			ResourceItem item = (ResourceItem)get(i);
			GFSDirEntry  dir  = new GFSDirEntry(item.getID(), item.getSize(), currofs);
			
			head.write(dir.getBytes());
			body.write(item.getData());

			currofs += item.getSize();
			currofs =  (currofs + 15) & 0x7FFFFFF0; // 16 byte-aligned
			
			while(body.size() != (currofs-headersize)) { // Pads the body until it's correctly aligned
				body.write(0xFF);
			}
		}
		
		while(head.size() != headersize) {
			head.write(0xFF);
		}
		
		head.writeTo(os);
		body.writeTo(os);
	}
}
