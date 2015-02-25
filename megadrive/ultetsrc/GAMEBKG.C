#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "gamebkg.h"
#include "options.h"
#include "utils.h"
#include "mission.h"
#include "language.h"

extern uint extWIDTH;

uint plf_display_width,plf_display_height;

void draw_score(X,Y,score)
uint X;
uint Y;
ulong score;
{
	register uint i;
    register ulong *pl;
    register uint *pw;
    register ulong j;
    register uint attr;
	uint buf1[7],buf2[7];

	for(i = 0; i != 7; i++){
		buf1[i] = 0;
		buf2[i] = 0;
	}

	for(i = 6; (score != 0L)||(i == 6); i--){
		buf2[i] = score % 10;
		buf1[i] = buf2[i] + (256+64+16);
		buf2[i] += (256+64+32);
		score /= 10;
	}

	attr = BUILD_ATTR(2,0,0,0);

	/* Primeiro, a parte superior */
    j = APLAN + (  2 * (X + (extWIDTH*Y) ) ); 

    pl = (ulong *) GFXCNTL;
    *pl = GFX_WRITE_ADDR(j);

    pw = (uint *) GFXDATA;

	for(i = 0; i != 7; i++){
		*pw = buf1[i] | attr;
	}

	/* Depois, a parte inferior */
	Y++;
    j = APLAN + (  2 * (X + (extWIDTH*Y) ) ); 

    pl = (ulong *) GFXCNTL;
    *pl = GFX_WRITE_ADDR(j);

    pw = (uint *) GFXDATA;

	for(i = 0; i != 7; i++){
		*pw = buf2[i] | attr;
	}
}

void draw_piece(X,Y,piece)
uint X;
uint Y;
char piece [][4];
{
	register uint i,j;

	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			if(piece[i][j]){
				put_tile(256+piece[i][j]-1,BUILD_ATTR(1,0,0,0),X+j,Y+i,APLAN);
			}else{
				put_tile(0,BUILD_ATTR(1,0,0,0),X+j,Y+i,APLAN);
			}
		}
	}
}

void draw_extended_playfield_display_frame(plf)
playfield *plf;
{
	register uint i;

	put_tile((256+64+7),BUILD_ATTR(2,0,0,0), /* Canto superior direito */
			 plf->left+plf->width+plf_display_width,plf->top+1+plf_display_height,APLAN);

	put_tile((256+64+6),BUILD_ATTR(2,0,0,0), /* Canto inferior esquerdo */
			 plf->left+plf->width,plf->top+1+(plf_display_height*2),APLAN);
	put_tile((256+64+4),BUILD_ATTR(2,0,0,0), /* Canto inferior direito */
			 plf->left+plf->width+plf_display_width,plf->top+1+(plf_display_height*2),APLAN);

	for(i = plf->top+2+plf_display_height; i != plf->top+(plf_display_height*2)+1; i++){
		put_tile((256+64+1),BUILD_ATTR(2,0,0,0), /* Lateral direita */
				 plf->left+plf->width+plf_display_width,i,APLAN);
	}

	for( i = plf->left+plf->width+1; i != plf->left+plf->width+plf_display_width; i++){
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Parte inferior */
				 i,plf->top+1+(plf_display_height*2),APLAN);
	}
}

void draw_extended_playfield_display(plf)
playfield *plf;
{
	register uint i;

	draw_extended_playfield_display_frame(plf);

	for(i = 0; i != 6; i++){
		out_text(plf->left+plf->width+1,plf->top+plf_display_height+2+i,
				 1,APLAN,__SURVIVAL_STBAR(i));
	}
	out_uint(plf->left+plf->width+plf_display_width-5,
			 plf->top+plf_display_height+2,
			 1,APLAN,5,plf->curr_speed + 1);
	out_uint(plf->left+plf->width+plf_display_width-5,
			 plf->top+plf_display_height+3,
			 1,APLAN,5,(uint)plf->total_lines);
	for(i = 0; i != 4; i++){
		out_uint(plf->left+plf->width+plf_display_width-5,
				 plf->top+plf_display_height+i+4,
				 1,APLAN,5,(uint)plf->line_stats[i]);
	}
}

void draw_mission_playfield_display(plf)
playfield *plf;
{
	register uint i, Y;

	draw_extended_playfield_display_frame(plf);

	Y = plf->top+plf_display_height+2;

	/* Fase e Velocidade */
	out_text(plf->left+plf->width+1,Y,
			 1,APLAN,__MISSION_STBAR(0));
	out_uint(plf->left+plf->width+plf_display_width-5,
			 Y,1,APLAN,5,mission_number);
	Y++;

	out_text(plf->left+plf->width+1,Y,
			 1,APLAN,__MISSION_STBAR(1));
	out_uint(plf->left+plf->width+plf_display_width-5,
			 Y,1,APLAN,5,plf->curr_speed+1);
	Y++;

	/* Blocos especiais */
	if(mishead->special_blocks){
		out_text(plf->left+plf->width+1,Y,
				 1,APLAN,__MISSION_STBAR(2));
		out_uint(plf->left+plf->width+plf_display_width-5,
				 Y,1,APLAN,5,plf->special_blocks);
		Y++;
	}

	/* Meta */
	if(mission_has_meta){
		for(i = 0; i != 4; i++){
			out_text(plf->left+plf->width+1,Y,
					 1,APLAN,__MISSION_STBAR(i+3));
			out_uint(plf->left+plf->width+plf_display_width-5,
					 Y,1,APLAN,5,plf->line_countdown[i]);
			Y++;
		}
	}

	/* Tempo */
	if(mishead->count_down){
		out_text(plf->left+plf->width+1,Y,
				 1,APLAN,__MISSION_STBAR(7));
		out_uint(plf->left+plf->width+plf_display_width-5,
				 Y,1,APLAN,5,mission_timer);
		Y++;
	}
}

void draw_playfield_display_right(plf)
playfield *plf;
{
	register uint i;

	put_tile((256+64+6),BUILD_ATTR(2,0,0,0), /* Canto superior esquerdo */
			 plf->left+plf->width,plf->top+2,APLAN);
	put_tile((256+64+6),BUILD_ATTR(2,0,0,0), /* Canto inferior esquerdo */
			 plf->left+plf->width,plf->top+1+plf_display_height,APLAN);

	put_tile((256+64+8),BUILD_ATTR(2,0,0,0), /* Canto superior direito */
			 plf->left+plf->width+plf_display_width,plf->top+2,APLAN);
	put_tile((256+64+4),BUILD_ATTR(2,0,0,0), /* Canto inferior direito */
			 plf->left+plf->width+plf_display_width,plf->top+1+plf_display_height,APLAN);

	for(i = plf->top+3; i != plf->top+plf_display_height+1; i++){
		put_tile((256+64+1),BUILD_ATTR(2,0,0,0), /* Lateral direita */
				 plf->left+plf->width+plf_display_width,i,APLAN);
	}

	for(i = plf->left+plf->width+1; i != plf->left+plf->width+plf_display_width; i++){
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Parte superior */
				 i,plf->top+2,APLAN);
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Divis¢ria */
				 i,plf->top+5,APLAN);
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Parte inferior */
				 i,plf->top+1+plf_display_height,APLAN);
	}

	put_tile((256+64+6),BUILD_ATTR(2,0,0,0), /* Parte esquerda da divis¢ria */
			 plf->left+plf->width,plf->top+5,APLAN);
	put_tile((256+64+7),BUILD_ATTR(2,0,0,0), /* Parte direita da divis¢ria */
			 plf->left+plf->width+plf_display_width,plf->top+5,APLAN);

	if(curr_game_mode == _GAMEMODE_1P_SURVIVAL){
		draw_extended_playfield_display(plf);
	}else if(curr_game_mode == _GAMEMODE_MISSION){
		draw_mission_playfield_display(plf);
	}
}
void draw_playfield_display_left(plf)
playfield *plf;
{
	register uint i;

	put_tile((256+64+7),BUILD_ATTR(2,0,0,0), /* Canto superior direito */
			 plf->left-1,plf->top+2+plf_display_height,APLAN);
	put_tile((256+64+7),BUILD_ATTR(2,0,0,0), /* Canto inferior direito */
			 plf->left-1,plf->top+1+(plf_display_height*2),APLAN);

	put_tile((256+64+9),BUILD_ATTR(2,0,0,0), /* Canto superior esquerdo */
			 plf->left-plf_display_width-1,plf->top+2+plf_display_height,APLAN);
	put_tile((256+64+2),BUILD_ATTR(2,0,0,0), /* Canto inferior esquerdo */
			 plf->left-plf_display_width-1,plf->top+1+(plf_display_height*2),APLAN);

	for(i = plf->top+3+plf_display_height; i != plf->top+(plf_display_height*2)+1; i++){
		put_tile((256+64+1),BUILD_ATTR(2,0,0,0), /* Lateral direita */
				 plf->left-plf_display_width-1,i,APLAN);
	}

	for(i = plf->left-2; i != plf->left-plf_display_width-1; i--){
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Parte superior */
				 i,plf->top+2+plf_display_height,APLAN);
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Divis¢ria */
				 i,plf->top+5+plf_display_height,APLAN);
		put_tile((256+64+3),BUILD_ATTR(2,0,0,0), /* Parte inferior */
				 i,plf->top+1+(plf_display_height*2),APLAN);
	}

	put_tile((256+64+7),BUILD_ATTR(2,0,0,0), /* Parte direita da divis¢ria */
			 plf->left-1,plf->top+5+plf_display_height,APLAN);
	put_tile((256+64+6),BUILD_ATTR(2,0,0,0), /* Parte esquerda da divis¢ria */
			 plf->left-plf_display_width-1,plf->top+5+plf_display_height,APLAN);
}

void draw_playfield_frame(plf)
playfield *plf;
{
	register uint i;

	if(plf->update_plf_frame){
		put_tile((256+64),BUILD_ATTR(2,0,0,0), /* Canto superior esquerdo */
				 plf->left-1,plf->top+1,APLAN);
		put_tile((256+64+5),BUILD_ATTR(2,0,0,0), /* Canto superior direito */
				 plf->left+plf->width,plf->top+1,APLAN);
	
	    for(i = plf->top+2; i != plf->top+plf->height; i++){ /* Laterais */
			put_tile((256+64+1),BUILD_ATTR(2,0,0,0), /* Lateral esquerda */
					 plf->left-1,i,APLAN);
			put_tile((256+64+1),BUILD_ATTR(2,0,0,0), /* Lateral direita */
					 plf->left+plf->width,i,APLAN);
    	}

	    for(i = plf->left; i != plf->left+plf->width; i++){ /* parte inferior */
			put_tile((256+64+3),BUILD_ATTR(2,0,0,0),
					 i,plf->top+plf->height,APLAN);
	    }

		put_tile((256+64+2),BUILD_ATTR(2,0,0,0), /* Canto inferior esquerdo */
				 plf->left-1,plf->top+plf->height,APLAN);
		put_tile((256+64+4),BUILD_ATTR(2,0,0,0), /* Canto inferior direito */
				 plf->left+plf->width,plf->top+plf->height,APLAN);

		if(plf->left > 20){
			draw_playfield_display_left(plf);
			draw_score(plf->left-8,plf->top+3+plf_display_height,plf->score);
			for(i = 0; i != 2; i++){
				draw_piece(plf->left-5-(5*i),plf->top+6+plf_display_height,plf->piece_preview[i]);
			}
		}else{
			draw_playfield_display_right(plf);
			draw_score(plf->left+plf->width+plf_display_width-7,plf->top+3,plf->score);
			for( i = 0; 
				 (i != (plf_display_width/5)) && (i != plf->preview_count);
				 i++){
				draw_piece(plf->left+plf->width+1+(5*i),plf->top+6,plf->piece_preview[i]);
			}
		}
	}
}
