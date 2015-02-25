/*
 *  Genesis RPG Creator World Designer, (c) 2004
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Haroldo O. Pinheiro <haroldoop@gmail.com>
 */

package genesisRPGCreator.util;

import java.io.File;
import java.util.Iterator;
import java.util.LinkedList;

import javax.swing.filechooser.FileFilter;


public class GenesisTileFileFilter extends FileFilter
{
    private String desc;
    private LinkedList exts;
    
    public GenesisTileFileFilter() {
        desc = new String("Genesis tileset");
        exts = new LinkedList();
        exts.add(new String("til"));
        exts.add(new String("rdc"));
    }

    public GenesisTileFileFilter(String filter, String desc) {
    	exts = new LinkedList();
    	this.desc = desc;
    	String [] ext = filter.split(",");
    	for(int i=0;i<ext.length;i++) {
    		exts.add(ext[i].substring(ext[i].indexOf('.')+1));
    	}
    }
    
    public void setDescription(String d) {
        desc = d;
    }

    public void addExtention(String e) {
        exts.add(e);
    }

    public boolean accept(File f) {
        if (f.isFile()) {
            if (f.getAbsolutePath().lastIndexOf('.') == -1) {
                return false;
            }

            String fileName = f.getAbsolutePath().toLowerCase();
            
            Iterator itr = exts.iterator();
            while (itr.hasNext()) {
            	String ext = (String)itr.next();
                if (fileName.endsWith(ext)) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    public String getDescription() {
    	String filter = "(";
    	Iterator itr = exts.iterator();
        while (itr.hasNext()) {
        	String ext = (String)itr.next();
        	filter = filter+"*."+ext;
        	if(itr.hasNext())
        		filter=filter+",";
        }
        return desc+" "+filter+")";
    }
}
