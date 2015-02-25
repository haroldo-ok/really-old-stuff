/* Rotinas diversas        */
/* por Haroldo O. Pinheiro */

#ifndef _INCLUDE_UTILS
#define _INCLUDE_UTILS

#include "genesis.h"

#define BUILD_ATTR(pal,pri,flipV,flipH) ((flipH << 11) + (flipV << 12) + (pal << 13) + (pri << 15))

uint random(range);
void put_tile(tile, attr, posx, posy, fieldAdr);
uint strlen2(str);
void out_text(X,Y,pal,fieldAddr,str);
void out_uint(X,Y,pal,fieldAddr,pad,num);
void out_ulong(X,Y,pal,fieldAddr,pad,num);
void set_bkg_data(first,count,data);
void set_bkg_tiles(X,Y,W,H,data,fieldAddr,basetile);
void fill_bkg_rect(X,Y,W,H,fieldAddr,basetile);
void fade_from_to(palSrc, palDest, palNum);

#endif
