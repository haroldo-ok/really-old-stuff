/* Sega Genesis RDC-Compressed Tile Loader                       */
/* by Haroldo O. Pinheiro                                        */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rdctile.h"

unsigned char huge_buffer[0x8C00]; /* 35k */
uint tileset_base_tile;
uint tileset_field_addr;
uint tileset_attrs[128];

void tileset_load_RDC(fname, basetile, tilecnt)
char *fname;
uint basetile;
uint tilecnt;
{
    ulong faddr, fsize;
	
	get_GFS_file(&faddr, &fsize, fname);
	RDC_Decompress(faddr, huge_buffer);
	set_bkg_data(basetile,tilecnt,huge_buffer);
}

void put_2x2_block(x, y, blocknum)
uint x;
uint y;
register uint blocknum;
{
    register ulong *pl;
    register uint *pw;
    register ulong i;

	blocknum = (blocknum << 2) + tileset_base_tile + 
               (tileset_attrs[blocknum] & (TILESET_ATR_PALETTE | TILESET_ATR_PRIORITY));

    /* Point to the coordinate we want (WIDTH=Plane width defined in .H) */
/*    i = tileset_field_addr + (  2 * ((x << 1) + (extWIDTH*(y << 1)) ) ); */
    i = tileset_field_addr + (  ((x << 1) + ((y << 1) << 6) ) << 1); 

    pl = (ulong *) GFXCNTL;
    *pl = GFX_WRITE_ADDR(i);

    pw = (uint *) GFXDATA;

   /* Grava caracter+atributo */
    *pw = blocknum;
	blocknum += 2;
    *pw = blocknum;

	i += extWIDTH << 1;
    *pl = GFX_WRITE_ADDR(i);
	blocknum--;

    *pw = blocknum;
	blocknum += 2;
    *pw = blocknum;
}