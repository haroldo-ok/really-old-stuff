/* RPG Map Routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rdctile.h"
#include "rpgmap.h"

uchar *map_ptrs[128];

uchar *map_line_ptr;
uchar *map_col_ptr;
uint map_line_num;
uint map_col_num;

uint map_x, map_y;
uint map_old_x, map_old_y;
uint map_w, map_h;
uint map_w_mask, map_h_mask;
uint map_coord_x_mask, map_coord_y_mask;

void rpg_map_load(mapname)
char *mapname;
{
    ulong faddr, fsize;	
	rpg_map_header *head;
	uchar *p;
	
	get_GFS_file(&faddr, &fsize, mapname);
	p    =  (uchar *)faddr;
	head =  p;
	p    += sizeof(rpg_map_header);

	rpg_map_init_ptrs(huge_buffer+16384, head->width, head->height);
	RDC_Decompress((ulong)p, huge_buffer+16384);

/*	write_ulong(p, 8);
	write_uint(head->width, 8);
	write_uint(head->height, 8);
	wait_btn_press(BUTTON_A);*/
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