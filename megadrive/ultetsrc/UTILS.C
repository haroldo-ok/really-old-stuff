#include "genesis.h"
#include "utils.h"

/* Rotina de n£meros aleat¢rios, baseada em RG_RAND.C (SNIPPETS) */
#define A 16807         /* multiplier */
#define M 2147483647L   /* 2**31 - 1 */
#define Q 127773L       /* m div a */
#define R 2836          /* m mod a */

ulong randomnum;

long nextlongrand()
{
      unsigned long lo, hi;

      randomnum++; /* adicionei por minha conta */

      lo = A * (long)(randomnum & 0xFFFF);
      hi = M * (long)((unsigned long)randomnum >> 16);
      lo += (hi & 0x7FFF) << 16;
      if (lo > M)
      {
            lo &= M;
            ++lo;
      }
      lo += hi >> 15;
      if (lo > M)
      {
            lo &= M;
            ++lo;
      }
      return (long)lo;
}

uint random(range)
uint range;
{
    randomnum = nextlongrand();
	return ((uint)randomnum % range);
}

extern uint extWIDTH;

void put_tile(tile, attr, posx, posy, fieldAdr)
/* baseada na fun‡Æo show_tiles, de genesis.h */
uint tile;
uint attr;
uint fieldAdr;
{
    register ulong *pl;
    register uint *pw;
    register ulong i;

    /* Point to the coordinate we want (WIDTH=Plane width defined in .H) */
    i = fieldAdr + (  2 * (posx + (extWIDTH*posy) ) ); 

    pl = (ulong *) GFXCNTL;
    *pl = GFX_WRITE_ADDR(i);

    pw = (uint *) GFXDATA;

   /* Grava caracter+atributo */
    *pw = tile | attr;

}

char char2hex(ch)
char ch;
{
	return ((ch <= '9')?(ch-'0'):(ch-'A'+10));
}

uint get_str_char(str)
char **str;
{
	register uint ch;

	switch(**str){
		case '~':
			(*str)++;
			if(**str){
				ch = char2hex(**str);
				(*str)++;
				if(**str){
					ch = (ch << 4)| char2hex(**str);
					(*str)++;
				}
			}else{
				ch = '~';
			}
		break;
		default:
			ch = **str;
			(*str)++;
		break;
	}
	
	return ch;
}

uint strlen2(str)
char *str;
{
	register uint cnt;

	cnt = 0;
	while(get_str_char(&str)){
		cnt++;
	}
	return cnt;
}

void out_text(X,Y,pal,fieldAddr,str)
uint X;
uint Y;
uint pal;
uint fieldAddr;
char *str;
{
    register ulong *pl;
    register uint *pw;
    register ulong i;
    register uint attr,chr;

	attr = BUILD_ATTR(pal,0,0,0);

    /* Point to the coordinate we want (WIDTH=Plane width defined in .H) */
    i = fieldAddr + (  2 * (X + (extWIDTH*Y) ) ); 

    pl = (ulong *) GFXCNTL;
    *pl = GFX_WRITE_ADDR(i);

    pw = (uint *) GFXDATA;

   /* Grava caracter+atributo */
   while(*str){
      chr = get_str_char(&str);
      if(chr == '\t'){
	     *pw = attr;
	     *pw = attr;
	     *pw = attr;
	     *pw = attr;
      }else{
	     *pw = chr | attr;
      }
   }
}

void out_uint(X,Y,pal,fieldAddr,pad,num)
uint X;
uint Y;
uint pal;
uint fieldAddr;
uint pad;
uint num;
{
	register uint i;
	register char str[6],*ptr;

	if(pad > 5){
		pad = 5;
	}

	for(i = 0; i != 6; i++){
		str[i] = ' ';
	}
	str[5] = 0;
	str[4] = '0';
	ptr = &str[5];

	do{
		ptr--;
		*ptr = '0' + (num % 10);
		if(pad)	pad--;
		num /= 10;
	}while(num);

	while(pad){
		ptr--;
		pad--;
	}

	out_text(X,Y,pal,fieldAddr,ptr);
}

void out_ulong(X,Y,pal,fieldAddr,pad,num)
uint X;
uint Y;
uint pal;
uint fieldAddr;
uint pad;
ulong num;
{
	register uint i;
	register char str[10],*ptr;

	if(pad > 9){
		pad = 9;
	}

	for(i = 0; i != 10; i++){
		str[i] = ' ';
	}
	str[9] = 0;
	str[8] = '0';
	ptr = &str[9];

	do{
		ptr--;
		*ptr = '0' + (num % 10);
		if(pad)	pad--;
		num /= 10;
	}while(num);

	while(pad){
		ptr--;
		pad--;
	}

	out_text(X,Y,pal,fieldAddr,ptr);
}

void set_bkg_data(first,count,data)
uint first;
uint count;
uint *data;
{
	register uint i;

	/* Copia os caracteres da imagem, 32 de cada vez */
	for(i = first*32; count; i += 32*32){
		if(count > 32){
			dma_vram_copy(data, i, 32*32);
			count -= 32;
		}else{
			dma_vram_copy(data, i, count*32);
			count = 0;
		}
		data += 32*32/2;
	}
}

void set_bkg_tiles(X,Y,W,H,data,fieldAddr,basetile)
uint X,Y;
uint W,H;
uint *data;
uint fieldAddr;
uint basetile;
{
    register ulong *pl;
    register uint *pw;
    register ulong l;
	register uint i, j;

	for(i = 0; i != H; i++){
		/* Aponta para o endere‡o inicial da linha */
	    l = fieldAddr + (  2 * (X + (extWIDTH*Y) ) ); 

	    pl = (ulong *) GFXCNTL;
	    *pl = GFX_WRITE_ADDR(l);

	    pw = (uint *) GFXDATA;

		/* Grava a linha */
		for(j = 0; j != W; j++){
			*pw = (*data)+basetile;
			data++;
		}

		Y++;
	}
}

void fill_bkg_rect(X,Y,W,H,fieldAddr,basetile)
uint X,Y;
uint W,H;
uint fieldAddr;
uint basetile;
{
    register ulong *pl;
    register uint *pw;
    register ulong l;
	register uint i, j;

	for(i = 0; i != H; i++){
		/* Aponta para o endere‡o inicial da linha */
	    l = fieldAddr + (  2 * (X + (extWIDTH*Y) ) ); 

	    pl = (ulong *) GFXCNTL;
	    *pl = GFX_WRITE_ADDR(l);

	    pw = (uint *) GFXDATA;

		/* Grava a linha */
		for(j = 0; j != W; j++){
			*pw = basetile;
		}

		Y++;
	}
}

/* Baseado na rotina fade_in do genesis.c */
void fade_from_to(palSrc, palDest, palNum)
uint *palSrc;
uint *palDest;
uint palNum;
{
    uint tmp_pal[16];
    register ulong *pl;
    register uint *pw;
    register uint *pal_ptr;
    register uint i, j, c;
    register ulong Decal;

    /* see set_colors() */
    Decal = (32 * palNum);

    /* Initialize a temporary palette */
    for (i = 0; i < 16; i++)
        tmp_pal[i] = palSrc[i];

    /* Fade in loop */
    for (i = 0; i < 16; i++)
    {
        /* Pointer to palette we want */
        pal_ptr = palDest;
    
        /* Setup GFX to save colors */
        pl = (ulong *) GFXCNTL;
        *pl = GFX_COLOR_WRITE_ADDR(Decal);

        /* Setup GFX data register */
        pw = (uint *) GFXDATA;
        
        /* Increment one color B,G,R at a time */
        for (j = 0; j < 16; j++)
        {
            /* increment OR decrement BLUE till reaching target color */
            c = tmp_pal[j] & 0xf00;
            if (c < (*pal_ptr & 0xf00)){
                tmp_pal[j] += 0x100;
			}else if (c > (*pal_ptr & 0xf00)){
                tmp_pal[j] -= 0x100;
			}
            /* check GREEN */
            c = tmp_pal[j] & 0xf0;
            if (c < (*pal_ptr & 0xf0)){
                tmp_pal[j] += 0x10;
			}else if (c > (*pal_ptr & 0xf0)){
                tmp_pal[j] -= 0x10;
			}
            /* check RED */
            c = tmp_pal[j] & 0xf;
            if (c < (*pal_ptr & 0xf)){
                tmp_pal[j] += 0x1;
			}else if (c > (*pal_ptr & 0xf)){
                tmp_pal[j] -= 0x1;
			}
			pal_ptr++;

            /* Store color */
            *pw = tmp_pal[j];
        }

        /* Wait a sec... */
        for (j = 0; j < 4; j++)
            wait_sync();
    }
}
