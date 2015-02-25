/*
 * Created on 08/03/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.sysdeps;

import tileMolester.colorcodecs.ColorCodec;
import tileMolester.tilecodecs.LinearTileCodec;
import genesisRPGCreator.Project;
import genesisRPGCreator.map.TiledMap;
import genesisRPGCreator.paledit.PrjPalette;
import genesisRPGCreator.tileset.TiledTileSet;

/**
 * @author wxp
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class SystemFactoryAdapter implements SystemFactory {
	protected ColorCodec colorcodec = null;

	/**
	 * 
	 */
	public SystemFactoryAdapter() {
		super();
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#createProject()
	 */
	public Project createProject() {
		// TODO Auto-generated method stub
		Project    proj = new Project();
		PrjPalette pal  = createPalette("DEFAULT");
		
		pal.setDescription("Default palette");
		
		proj.setSystemFactory(this);
		proj.getPalettes().add(pal);
		
		return proj;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getPaletteCount()
	 */
	public int getPaletteCount() {
		// TODO Auto-generated method stub
		return 1;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getSprPaletteCount()
	 */
	public int getSprPaletteCount() {
		// TODO Auto-generated method stub
		return 0;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getPaletteSize()
	 */
	public int getPaletteSize() {
		// TODO Auto-generated method stub
		return 256;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#createPalette()
	 */
	public PrjPalette createPalette(String id) {
		int def16[] = new int[] {0x000000, 0x000080,
								 0x008000, 0x008080,
								 0x800000, 0x800080,
								 0x808000, 0x808080,
								 0x606060, 0x6060FF,
								 0x60FF60, 0x60FFFF,
								 0xFF6060, 0xFF60FF,
								 0xFFFF60, 0xFFFFFF};
		
		PrjPalette  palette = new PrjPalette(id, getPaletteSize(), getColorCodec(), 0);
		
		int i;
		for (i = 0; (i != palette.getSize()) && (i != def16.length); i++) {
			palette.setEntryRGB(i, def16[i]);			
		}
		
		if (i < palette.getSize()) {
			int count = palette.getSize() - i;			
			for (int j = 0; i != palette.getSize(); i++, j++) {
				palette.setEntryRGB(i, 0xFFFFFF*j/count);							
			}
		}
			
		return palette;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getID()
	 */
	public String getID() {
		// TODO Auto-generated method stub
		return null;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.util.CollectionItem#getDescription()
	 */
	public String getDescription() {
		// TODO Auto-generated method stub
		return null;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#getColorCodec()
	 */
	public ColorCodec getColorCodec() {
		// TODO Auto-generated method stub
		return colorcodec;
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#createTileSet(java.lang.String)
	 */
	public TiledTileSet createTileSet(String id) {
		return new TiledTileSet(id, (PrjPalette)null, new LinearTileCodec("Sega Genesis", 4, ColorCodec.LITTLE_ENDIAN, "Sega Genesis"));
	}

	/* (non-Javadoc)
	 * @see genesisRPGCreator.sysdeps.SystemFactory#createMap(java.lang.String)
	 */
	public TiledMap createMap(String id, Project proj) {
		return new TiledMap(id, 64, 64, (TiledTileSet)proj.getTilesets().get(0));
	}

}
