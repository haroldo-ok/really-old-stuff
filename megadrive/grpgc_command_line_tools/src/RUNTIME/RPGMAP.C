/* RPG Map Routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rdctile.h"
#include "rpgmap.h"
#include "rpgwalk.h"
#include "zopint.h"
#include "actor.h"

uchar *map_ptrs[128];

uchar *map_line_ptr;
uchar *map_col_ptr;
uint map_line_num;
uint map_col_num;

uint map_flags;
uint map_x, map_y;
uint map_old_x, map_old_y;
uint map_w, map_h;
uint map_w_mask, map_h_mask;
uint map_coord_x_mask, map_coord_y_mask;

rpg_map_entry_exit *map_exits;
uint map_exit_count;
rpg_map_entry_exit *map_exit_found;

void ref_to_filename(fname, ref, ext) 
char *fname;
register char *ref;
register char *ext;
{
	register char *p, *c;
	register uint i;

	p = fname;
	for (i = 0; i != 13; i++) {
		*p = 0;
		p++;
	}

	p = fname;
	c = ref;
	for (i = 0; (i != 8) && (*c); i++) {
		*p = *c;
		p++;
		c++;
	}

	*p = '.';
	p++;

	c = ext;
	while (*c) {
		*p = *c;
		p++;
		c++;
	}
}

void rpg_map_load_exits(entry, data) 
rpg_map_entry_head *entry;
uchar *data;
{
	map_exits = (rpg_map_entry_exit *)data;
	map_exit_count = entry->recs;
}

void rpg_map_load_palettes(entry, data) 
rpg_map_entry_head *entry;
uchar *data;
{
	char *rec;
	char fname[13];
	ulong faddr;
	uint i;

	rec = (char *)data;
	for (i = 0; i != entry->recs; i++) {	
		ref_to_filename(fname, rec, EXT_PALETTE);
		get_GFS_fileaddr(&faddr, fname);
		set_colors(i, faddr);

		rec += 8;
	}
}

void rpg_map_load_tilesets(entry, data) 
rpg_map_entry_head *entry;
uchar *data;
{
	char *rec;
	char fname[13];
	uint baset;
	uint i, j, *p;
	ulong faddr;


	tileset_base_tile  = FIRST_TILE_BKG;
	tileset_field_addr = BPLAN;

	for(i = 0; i != 128; i++){
		tileset_attrs[i] = 0;
	}

	rec = (char *)data;
	baset = FIRST_TILE_BKG;
	for (i = 0; i != entry->recs; i++) {	
		ref_to_filename(fname, rec, EXT_TILESET);
		tileset_load_RDC(fname, baset, 512);

		ref_to_filename(fname, rec, EXT_TILESET_ATR);
		get_GFS_fileaddr(&faddr, fname);
		if (faddr != 0) {
			/* Must cleanup this code later */
			p = (uint *)faddr;
			for(j = 0; j != 128; j++){
				tileset_attrs[j] = *p;
				p++;
			}
		}

		rec += 8;
		baset += 512;
	}
}

void rpg_map_load_sprites(entry, data) 
rpg_map_entry_head *entry;
uchar *data;
{
	char *rec;
	char fname[13];
	uint baset;
	uint i;

	rec = (char *)data;
	baset = FIRST_TILE_SPR;
	for (i = 0; i != entry->recs; i++) {	
		ref_to_filename(fname, rec, EXT_SPRITE);
		tileset_load_RDC(fname, baset, SPR_TILE_CNT);

		rec += 8;
		baset += SPR_TILE_CNT;
	}
}

void rpg_map_load_actors(entry, data) 
rpg_map_entry_head *entry;
uchar *data;
{
	uint i;
	rpg_map_entry_actor *rec;
	walker *spr;
	zop_prog_rec *prog;
	char fname[13];

	spr = actor_sprites;
	spr++;
	prog = actor_progs;
	prog++;

	rec = (rpg_map_entry_actor *)data;
	for (i = 0; i != entry->recs; i++) {	
		init_walker(spr, FIRST_TILE_SPR+(rec->sprnum*SPR_TILE_CNT));
		spr->pos_x  = rec->xpos << 4;
		spr->pos_y  = rec->ypos << 4;
		spr->palnum = rec->palnum;
		spr->sprnum = i+1;
		
		ref_to_filename(fname, rec->script, EXT_SCRIPT);
		zop_load_prog(prog, fname, i+1);

		prog++;
		spr++;
		rec++;
	}
}

void rpg_map_load(mapname)
char *mapname;
{
    ulong faddr, fsize;	
	rpg_map_header *head;
	rpg_map_entry_head *entry;
	uchar *p;
	char *s;

	map_flags = 0;

	map_exit_count = 0;
	map_exit_found = NULL;
	
	get_GFS_file(&faddr, &fsize, mapname);


	if ((faddr == 0) && (fsize == 0)) {
		cputs("Map ");
		cputs(mapname);
		cputs(" not found.\n");
	}

	p    =  (uchar *)faddr;
	head =  (rpg_map_header *)p;
	p    += sizeof(rpg_map_header);

	
	entry = (rpg_map_entry_head *)p;
	while (strcmp(entry->signature, MAP_ENTRY_END)) {
		p += sizeof(rpg_map_entry_head);

		s = entry->signature;
		if (!strcmp(s, MAP_ENTRY_EXITS)) {
			rpg_map_load_exits(entry, p);
		} else if (!strcmp(s, MAP_ENTRY_PALETTES)) {
			rpg_map_load_palettes(entry, p);
		} else if (!strcmp(s, MAP_ENTRY_TILESETS)) {
			rpg_map_load_tilesets(entry, p);
		} else if (!strcmp(s, MAP_ENTRY_SPRITES)) {
			rpg_map_load_sprites(entry, p);
		} else if (!strcmp(s, MAP_ENTRY_ACTORS)) {
			rpg_map_load_actors(entry, p);
		} else if (!strcmp(s, MAP_ENTRY_MAP_UNCOMPRESSED)) {
		} else if (!strcmp(s, MAP_ENTRY_MAP_COMPRESS_RDC)) {
			/* Decompresses the map into memory */
			rpg_map_init_ptrs(huge_buffer+16384, head->width, head->height);
			RDC_Decompress((ulong)p, huge_buffer+16384);
		} else if (!strcmp(s, MAP_ENTRY_MAP_COMPRESS_RLE)) {
		}


		p += entry->size;
		entry = (rpg_map_entry_head *)p;
	}
}

void rpg_map_exit(map_exit, x, y)
rpg_map_entry_exit *map_exit;
int x, y;
{
	char fname[13];

	ref_to_filename(fname, map_exit->destmap, EXT_MAP);
	rpg_map_load(fname);

	if (map_exit->destx == MAP_DEST_SAME) {
		map_x = x;
	} else if (map_exit->destx == MAP_DEST_MIRROR) {
		if (x > (map_w >> 1)) {
			map_x = 1;
		} else {
			map_x = map_w - 2;
		}
	} else {
		map_x = map_exit->destx;
	}

	if (map_exit->desty == MAP_DEST_SAME) {
		map_y = y;
	} else if (map_exit->desty == MAP_DEST_MIRROR) {
		if (y > (map_h >> 1)) {
			map_y = 1;
		} else {
			map_y = map_h - 2;
		}
	} else {
		map_y = map_exit->desty;
	}
}

void rpg_map_init_ptrs(addr, width, height)
uchar *addr;
uint width;
uint height;
{
	register uint i;	
	register uchar *p;

	p = addr;
	for(i = 0; i != height; i++){
		map_ptrs[i] = p;
		p += width;
	}
	
	map_line_ptr = addr;
	map_col_ptr  = addr;
	map_line_num = 0;
	map_col_num  = 0;

	map_w = width;
	map_h = height;
	map_w_mask = width-1;
	map_h_mask = height-1;
	map_coord_x_mask = (map_w_mask << 4) | 0x0F;
	map_coord_y_mask = (map_h_mask << 4) | 0x0F;
}

void rpg_map_select_col(colnum)
register uint colnum;
{
	map_col_ptr = map_line_ptr + colnum;
	map_col_num = colnum;
}

void rpg_map_select_line(linenum)
register uint linenum;
{
	map_line_ptr = map_ptrs[linenum];
	map_line_num = linenum;
	rpg_map_select_col(map_col_num);
}

void rpg_map_select_next_col()
{
	map_col_ptr++;
	map_col_num++;
}

void rpg_map_draw_rectangle(X1, Y1, X2, Y2, value)
register uint X1;
register uint Y1;
uint X2;
uint Y2;
register uchar value;
{
	register uint w, h;

	if(X1 < X2){
		w = X2-X1+1;
	}else{
		w  = X1-X2+1;
		X1 = X2;
	}
	X2 = w;

	if(Y1 < Y2){
		h = Y2-Y1+1;
	}else{
		h  = Y1-Y2+1;
		Y1 = Y2;
	}

	for(; h; h--){
		rpg_map_select_col(X1);
		rpg_map_select_line(Y1);

		for(w = X2; w; w--){
			*map_col_ptr = value;
			rpg_map_select_next_col();
		}

		Y1++;
	}
}

uchar rpg_map_get_block(X, Y)
register uint X, Y;
{
	rpg_map_select_col(X);
	rpg_map_select_line(Y);

	return *map_col_ptr;
}

void rpg_map_set_block(X, Y, value)
register uint X, Y;
register uchar value;
{
	rpg_map_select_col(X);
	rpg_map_select_line(Y);

	*map_col_ptr = value;
}

void rpg_map_repaint(X, Y)
uint X;
uint Y;
{
	register uint i,j;
	register uint x,y;

	map_x = ((X-16) >> 4) & map_w_mask;
	map_y = ((Y-16) >> 4) & map_h_mask;

	y = map_y;
	for(i = MAP_SCR_BLOCK_Y; i; i--){
		rpg_map_select_line(y);
		x = map_x;
		for(j = MAP_SCR_BLOCK_X; j; j--){
			rpg_map_select_col(x);
			put_2x2_block(x&0x1F, y&0x1F, *map_col_ptr);

			x++;
			x &= map_w_mask;
		}

		y++;
		y &= map_h_mask;
	}

	scrollh(0, -X);
	scrollv(0, Y);

	map_old_x = map_x;
	map_old_y = map_y;
}

void rpg_map_scroll(X, Y)
uint X;
uint Y;
{
	register uint i,j;
	register uint x,y;

	map_x = ((X-16) >> 4) & map_w_mask;
	map_y = ((Y-16) >> 4) & map_h_mask;

	if(map_x != map_old_x){
		y = map_y;
		if( ((map_x > map_old_x) && (map_x-map_old_x < 2)) || 
            ((map_x < map_old_x) && (map_old_x-map_x > 1))){
			x = map_x + MAP_SCR_BLOCK_X-1;
		}else{
			x = map_x;
		}

		x &= map_w_mask;
		y &= map_h_mask;

		rpg_map_select_col(x);
		for(i = MAP_SCR_BLOCK_Y; i; i--){
			rpg_map_select_line(y);
			put_2x2_block(x&0x1F, y&0x1F, *map_col_ptr);

			y++;
			y &= map_h_mask;
		}
	}

	if(map_y != map_old_y){
		x = map_x;
		if( ((map_y > map_old_y) && (map_y-map_old_y < 2)) || 
            ((map_y < map_old_y) && (map_old_y-map_y > 1))){
			y = map_y + MAP_SCR_BLOCK_Y-1;
		}else{
			y = map_y;
		}

		x &= map_w_mask;
		y &= map_h_mask;

		rpg_map_select_line(y);
		for(i = MAP_SCR_BLOCK_X; i; i--){
			rpg_map_select_col(x);
			put_2x2_block(x&0x1F, y&0x1F, *map_col_ptr);

			x++;
			x &= map_w_mask;
		}
	}

	scrollh(0, -X);
	scrollv(0, Y);

	map_old_x = map_x;
	map_old_y = map_y;
}

void rpg_map_search_exit(x, y)
register int x;
register int y;
{
	register rpg_map_entry_exit *p;
	register uint i;
	register int ex, ey;

	p = map_exits;
	for (i = map_exit_count; i != 0; i--) {
		ex = p->x;
		ey = p->y;

		if ((x >= ex) && (x < ex + p->width) &&
            (y >= ey) && (y < ey + p->height)) {
			map_exit_found = p;
			return;
        }

		p++;
	}
}