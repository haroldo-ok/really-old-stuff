/*
 * Created on 28/01/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.util;

import java.util.AbstractList;

import javax.swing.table.AbstractTableModel;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class CollectionTableModel extends AbstractTableModel {
	protected AbstractList collection = null;

	/**
	 * 
	 */
	public CollectionTableModel(AbstractList collection) {
		super();
		this.collection = collection;
	}

	public int getColumnCount() {
		return 2;
	}

	public int getRowCount() {
		if (collection != null) {
			return collection.size();
		} else {
			return 0;
		}
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getValueAt(int, int)
	 */
	public Object getValueAt(int rowIndex, int columnIndex) {
		if ((collection != null) && (collection.get(rowIndex) instanceof CollectionItem)) {
			switch (columnIndex) {
				case 0:
					return ((CollectionItem)collection.get(rowIndex)).getID();
				
				case 1:
					return ((CollectionItem)collection.get(rowIndex)).getDescription();
			}
		}
		
		return "";
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getColumnName(int)
	 */
	public String getColumnName(int column) {
		switch (column) {
			case 0:
				return "Name";

			case 1:
				return "Description";
		}
		return super.getColumnName(column);
	}

}
