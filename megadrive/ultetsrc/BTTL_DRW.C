#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "gamebkg.h"
#include "psgsound.h"
#include "language.h"
#include "battle.h"

void draw_life_meter(X,Y,basetile,attr,width,value,max,mirror)
uint X, Y;
uint basetile, attr;
uint width;
uint value, max;
uint mirror;
{
	register uint i;
	uint buf[20];
	uint val1, val2;

	for(i = 0; i != width; i++){
		buf[i] = basetile;
    }

	val1 = value * width * 5 / max;
	val2 = val1 / 5;
	val1 %= 5;

	for(i = 0; i != val2; i++){
		buf[i] = basetile+4;
    }
	buf[i] = basetile+val1;

	if(!mirror){
		for(i = 0; i != width; i++){
			put_tile(buf[i],attr,X++,Y,APLAN);
    	}
	}else{
		for(i = 0; i != width; i++){
			put_tile(buf[i],attr,X--,Y,APLAN);
    	}
	}
}

void draw_battle_playfield_display_right(plf)
playfield *plf;
{
	register uint i;

	put_tile((256+64+6),BUILD_ATTR(1,0,0,0), /* Canto superior esquerdo */
			 plf->left+plf->width,plf->top+2,APLAN);
	put_tile((256+64+6),BUILD_ATTR(1,0,0,0), /* Canto inferior esquerdo */
			 plf->left+plf->width,plf->top+7,APLAN);

	put_tile((256+64+8),BUILD_ATTR(1,0,0,0), /* Canto superior direito */
			 plf->left+plf->width+plf_display_width,plf->top+2,APLAN);
	put_tile((256+64+4),BUILD_ATTR(1,0,0,0), /* Canto inferior direito */
			 plf->left+plf->width+plf_display_width,plf->top+7,APLAN);

	for(i = plf->top+3; i != plf->top+7; i++){
		put_tile((256+64+1),BUILD_ATTR(1,0,0,0), /* Lateral direita */
				 plf->left+plf->width+plf_display_width,i,APLAN);
	}

	for(i = plf->left+plf->width+1; i != plf->left+plf->width+plf_display_width; i++){
		put_tile((256+64+3),BUILD_ATTR(1,0,0,0), /* Parte superior */
				 i,plf->top+2,APLAN);
		put_tile((256+64+3),BUILD_ATTR(1,0,0,0), /* Parte inferior */
				 i,plf->top+7,APLAN);
	}

	put_tile((256+64+42),BUILD_ATTR(1,0,0,0), /* Canto esquerdo da barra de sangue */
			 plf->left+plf->width+1,plf->top+8,APLAN);
	put_tile((256+64+26),BUILD_ATTR(1,0,0,0), /* Canto direito da barra de sangue */
			 plf->left+plf->width+plf_display_width,plf->top+8,APLAN);

	put_tile((256+64+42),BUILD_ATTR(1,0,0,0), /* Canto esquerdo da barra de energia */
			 plf->left+plf->width+1,plf->top+9,APLAN);
	put_tile((256+64+26),BUILD_ATTR(1,0,0,0), /* Canto direito da barra de energia */
			 plf->left+plf->width+plf_display_width,plf->top+9,APLAN);

	draw_life_meter(plf->left+plf->width+2,plf->top+8, /* Barra de vida */
					(256+64+27),BUILD_ATTR(1,0,0,0),plf_display_width-2,
					plf->life,255,FALSE);
	draw_life_meter(plf->left+plf->width+2,plf->top+9, /* Barra de energia */
					(256+64+43),BUILD_ATTR(1,0,0,0),plf_display_width-2,
					plf->energy,255,FALSE);
}

void draw_battle_playfield_display_left(plf)
playfield *plf;
{
	register uint i;

	put_tile((256+64+7),BUILD_ATTR(1,0,0,0), /* Canto superior direito */
			 plf->left-1,plf->top+2+plf_display_height,APLAN);
	put_tile((256+64+7),BUILD_ATTR(1,0,0,0), /* Canto inferior direito */
			 plf->left-1,plf->top+7+plf_display_height,APLAN);

	put_tile((256+64+9),BUILD_ATTR(1,0,0,0), /* Canto superior esquerdo */
			 plf->left-plf_display_width-1,plf->top+2+plf_display_height,APLAN);
	put_tile((256+64+2),BUILD_ATTR(1,0,0,0), /* Canto inferior esquerdo */
			 plf->left-plf_display_width-1,plf->top+7+plf_display_height,APLAN);

	for(i = plf->top+3+plf_display_height; i != plf->top+plf_display_height+7; i++){
		put_tile((256+64+1),BUILD_ATTR(1,0,0,0), /* Lateral direita */
				 plf->left-plf_display_width-1,i,APLAN);
	}

	for(i = plf->left-2; i != plf->left-plf_display_width-1; i--){
		put_tile((256+64+3),BUILD_ATTR(1,0,0,0), /* Parte superior */
				 i,plf->top+2+plf_display_height,APLAN);
		put_tile((256+64+3),BUILD_ATTR(1,0,0,0), /* Parte inferior */
				 i,plf->top+7+plf_display_height,APLAN);
	}

	put_tile((256+64+42),BUILD_ATTR(1,0,0,0), /* Canto esquerdo da barra de sangue */
			 plf->left-plf_display_width-1,plf->top+1+plf_display_height,APLAN);
	put_tile((256+64+26),BUILD_ATTR(1,0,0,0), /* Canto direito da barra de sangue */
			 plf->left-2,plf->top+1+plf_display_height,APLAN);

	put_tile((256+64+42),BUILD_ATTR(1,0,0,0), /* Canto esquerdo da barra de energia */
			 plf->left-plf_display_width-1,plf->top+plf_display_height,APLAN);
	put_tile((256+64+26),BUILD_ATTR(1,0,0,0), /* Canto direito da barra de energia */
			 plf->left-2,plf->top+plf_display_height,APLAN);

	draw_life_meter(plf->left-3,plf->top+1+plf_display_height, /* Barra de vida */
					(256+64+27),BUILD_ATTR(1,0,0,1),plf_display_width-2,
					plf->life,255,TRUE);
	draw_life_meter(plf->left-3,plf->top+plf_display_height, /* Barra de energia */
					(256+64+43),BUILD_ATTR(1,0,0,1),plf_display_width-2,
					plf->energy,255,TRUE);
}

void draw_battle_playfield_frame(plf)
playfield *plf;
{
	register uint i;

	if(plf->update_plf_frame){
		put_tile((256+64),BUILD_ATTR(1,0,0,0), /* Canto superior esquerdo */
				 plf->left-1,plf->top+1,APLAN);
		put_tile((256+64+5),BUILD_ATTR(1,0,0,0), /* Canto superior direito */
				 plf->left+plf->width,plf->top+1,APLAN);
	
	    for(i = plf->top+2; i != plf->top+plf->height; i++){ /* Laterais */
			put_tile((256+64+1),BUILD_ATTR(1,0,0,0), /* Lateral esquerda */
					 plf->left-1,i,APLAN);
			put_tile((256+64+1),BUILD_ATTR(1,0,0,0), /* Lateral direita */
					 plf->left+plf->width,i,APLAN);
    	}

	    for(i = plf->left; i != plf->left+plf->width; i++){ /* parte inferior */
			put_tile((256+64+3),BUILD_ATTR(1,0,0,0),
					 i,plf->top+plf->height,APLAN);
	    }

		put_tile((256+64+2),BUILD_ATTR(1,0,0,0), /* Canto inferior esquerdo */
				 plf->left-1,plf->top+plf->height,APLAN);
		put_tile((256+64+4),BUILD_ATTR(1,0,0,0), /* Canto inferior direito */
				 plf->left+plf->width,plf->top+plf->height,APLAN);

		if(plf->left > 20){
			draw_battle_playfield_display_left(plf);
			for(i = 0; i != 2; i++){
				draw_piece(plf->left-7-(5*i),plf->top+3+plf_display_height,plf->piece_preview[i]);
			}
		}else{
			draw_battle_playfield_display_right(plf);
			for( i = 0; 
				 (i != (plf_display_width/5)) && (i != plf->preview_count);
				 i++){
				draw_piece(plf->left+plf->width+3+(5*i),plf->top+3,plf->piece_preview[i]);
			}
		}
	}
}

