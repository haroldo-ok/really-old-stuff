/* Sega Genesis RDC-Compressed Tile Loader */
/* by Haroldo O. Pinheiro                  */

#ifndef _INC_RDCTILE_

extern unsigned char huge_buffer[];
extern uint tileset_base_tile;
extern uint tileset_field_addr;

void tileset_load_RDC(fname, basetile, tilecnt);

void put_2x2_block(x, y, blocknum);

#define _INC_RDCTILE_

#endif
