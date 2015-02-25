/* ZOP bytecode interpreter                                      */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "rpgmap.h"
#include "rdctile.h"
#include "rpgwalk.h"
#include "rpg_gui.h"
#include "zopint.h"
#include "actor.h"

uint zop_instr_per_frame;
uchar zop_flags[256];
char zop_text_buf[1024], *zop_text_ptr;
char zop_menu_text_buf[512], *zop_menu_text_ptr, *zop_menu_ptrs[16];
uint zop_menu_dests[16], zop_menu_cnt;
uint zop_debug_mode;

void zop_vm_init()
{
	zop_instr_per_frame = ZOP_MAX_INSTR_PER_FRAME;
	zop_debug_mode = FALSE;
	zop_vm_reset();
	zop_clear_flags();
}

void zop_vm_reset()
{
	zop_text_buf[0] = 0;
	zop_text_ptr    = zop_text_buf;
	zop_menu_cnt = 0;
}

void zop_load_prog(prog, fname, actornum)
zop_prog_rec *prog;
char *fname;
uint actornum;
{
    ulong faddr, fsize;
	char *p;
	
	get_GFS_file(&faddr, &fsize, fname);

	p = (char *)faddr;
	p += 4; /* Skips the "ZOP" signature */

	prog->eventcnt = *p;
	p++;
	prog->eventcnt = (prog->eventcnt << 8) | (*p);
	p++;

	prog->eventptr = (zop_evt_rec *)p;
	p += (prog->eventcnt << 2);

	prog->evtpc = NULL;

	prog->baseaddr = p;
	prog->pc       = prog->baseaddr;
	prog->actornum = actornum;
}

uchar zop_exec_instruction(prog) /* returns TRUE if should yield the current timeslice */
register zop_prog_rec *prog;
{
	register uint op, pr;
	register uint tmp, tmp2;
	uint hack;

	pr = *(prog->pc);
	op = pr & ZOP_BTC_OP_MASK;
	pr &= ZOP_BTC_PR_MASK;

/*	if(zop_debug_mode && (prog->actornum == 3)){
		gotoxy(1, 1);
		write_uint(prog->actornum, 4);
		write_ulong(prog->pc-prog->baseaddr, 8);
		write_uint(op, 4);
		write_uint(pr, 4);
		putch('\n');
		wait_pressnrelease();
	}*/

	prog->pc++;

	switch(op){
		case ZOP_OP_NOP:
			switch(pr){
				case ZOP_PR_NOP_DELAY:
				return TRUE;
			}
		break;

		case ZOP_OP_WLK_WALK:
		case ZOP_OP_WLK_TRY:
			switch(pr){
				case ZOP_PR_DIR_NORTH: 
					tmp = RWK_FC_UP; 
				break;
				case ZOP_PR_DIR_SOUTH:
					tmp = RWK_FC_DOWN; 
				break;
				case ZOP_PR_DIR_EAST:
					tmp = RWK_FC_RIGHT; 
				break;
				case ZOP_PR_DIR_WEST:
					tmp = RWK_FC_LEFT; 
				break;
			}

			if(op != ZOP_OP_WLK_TRY){
				if(!actor_walk(prog->actornum, tmp)){
					prog->pc--;
				}
			}else{
				actor_walk(prog->actornum, tmp);
			}
		return TRUE;

		case ZOP_OP_TXT:
			switch(pr){
				case ZOP_PR_TXT_CLEAR:
					*zop_text_buf = 0;
					zop_text_ptr  = zop_text_buf;
				break;

				case ZOP_PR_TXT_WRITE:
					zop_add_text_inc(&(prog->pc));
					zop_add_text("\n");
					prog->pc++;
				break;

				case ZOP_PR_TXT_DISPLAY:
					zop_display_text(FALSE);
				break;

				case ZOP_PR_TXT_DISCLR:
					zop_display_text(TRUE);
				break;
			}
		break;

		case ZOP_OP_MNU:
			switch(pr){
				case ZOP_PR_MNU_CLEAR:
					zop_menu_cnt = 0;
				break;

				case ZOP_PR_MNU_ADD:
					tmp = *(prog->pc);
					prog->pc++;
					tmp = (tmp << 8) + *(prog->pc);
					prog->pc++;

					if(!zop_menu_cnt){
						zop_menu_text_ptr = zop_menu_text_buf;
					}

					zop_menu_ptrs[zop_menu_cnt]  = zop_menu_text_ptr;
					zop_menu_dests[zop_menu_cnt] = tmp;

					while(*(prog->pc)){
						*zop_menu_text_ptr = *(prog->pc);
						prog->pc++;
						zop_menu_text_ptr++;
					}

					*zop_menu_text_ptr = 0;
					zop_menu_text_ptr++;
					prog->pc++;

					zop_menu_cnt++;
				break;

				case ZOP_PR_MNU_DISPLAY:
					zop_display_menu(prog, FALSE);
				break;

				case ZOP_PR_MNU_DISCLR:
					zop_display_menu(prog, TRUE);
				break;
			}
		break;

		case ZOP_OP_SET:
		case ZOP_OP_CLR:
		case ZOP_OP_TFZ:
		case ZOP_OP_TZF:
		case ZOP_OP_NOT:
			tmp = (pr << 8) | (*(prog->pc));
			prog->pc++;
			switch(op){
				case ZOP_OP_SET:
					zop_set_flag(tmp, 1);
				break;
				case ZOP_OP_CLR:
					zop_set_flag(tmp, 2);
				break;
				case ZOP_OP_TFZ:
					zop_set_flag0((uint)zop_get_flag(tmp));
				break;
				case ZOP_OP_TZF:
					zop_set_flag(tmp, (uint)zop_get_flag0());
				break;
				case ZOP_OP_NOT:
					zop_set_flag0(!(uint)zop_get_flag0());
				break;
			}
		break;

		case ZOP_OP_BRA:
			tmp = *(prog->pc);
			prog->pc++;
			tmp = (tmp << 8) + (*(prog->pc));
			prog->pc++;

			switch(pr){
				case ZOP_PR_BRA_ALWAYS:
					tmp2 = TRUE;
				break;
				case ZOP_PR_BRA_SET:
					tmp2 = zop_get_flag0();
				break;
				case ZOP_PR_BRA_NOTSET:
					tmp2 = !zop_get_flag0();
				break;
			}

			if(tmp2){
				prog->pc = prog->baseaddr + tmp;
			}
		break;

		case ZOP_OP_SYS:
		break;

		default:
			prog->pc = NULL;
			return TRUE;		    
	}

	return FALSE;
}

void zop_exec_frame(prog)
zop_prog_rec *prog;
{
	uint instr_left = zop_instr_per_frame;

	if(!prog->pc){
		return;
	}

	if(actor_sprites[prog->actornum].stepcnt){
		return;
	}

	if(prog->evtpc){
		prog->pc    = prog->evtpc;
		prog->evtpc = NULL;
		zop_debug_mode = TRUE;
	}

	while(instr_left){
		instr_left--;
		if(zop_exec_instruction(prog)){
			if(*zop_text_buf){
				zop_display_text(TRUE);
				zop_display_menu(prog, TRUE);
				gui_clear();
			}
			instr_left = 0;			
		}
	}
}

void zop_signal_event(prog, event)
register zop_prog_rec *prog;
register uint event;
{
	register uint i;
	register zop_evt_rec *evtp;

	if((!prog->pc) || (prog->evtpc)){
		return;
	}

	evtp = prog->eventptr;
	for(i = prog->eventcnt; i && (evtp->code != event); i--){
		evtp++;
	}

	if(i){
		prog->evtpc = prog->baseaddr + evtp->addr;
	}
}

void zop_clear_flags()
{
	register uint i;
	register uchar *p;

	p = zop_flags;
	for(i = 0; i != 256; i++){
		*p = 0;
		p++;
	}
}

void zop_set_flag(flag, value)
register uint flag;
register uint value;
{
	register uint mask;
	register uchar *p;

	mask = 1 << (flag & 0x0007);
	p = &(zop_flags[flag >> 3]);

	*p &= 0xFFU - mask;
	if(value){
		*p |= mask;
	}
}

uchar zop_get_flag(flag)
register uint flag;
{
	register uint mask;
	register uchar *p;

	mask = 1 << (flag & 0x0007);
	p = &(zop_flags[flag >> 3]);

	return ((*p & mask) != 0);
}

uchar zop_set_flag0(value)
uint value;
{
	*zop_flags &= 0xFEU;
	*zop_flags |= value;
}

uchar zop_get_flag0()
{
	return (*zop_flags) & 0x01U;
}

void zop_add_text(text)
register char *text;
{
	while(*text){
		*zop_text_ptr = *text;
		zop_text_ptr++;
		text++;
	}
	*zop_text_ptr = 0;
}

void zop_add_text_inc(text)
register char **text;
{
	while(**text){
		*zop_text_ptr = **text;
		zop_text_ptr++;
		(*text)++;
	}
	*zop_text_ptr = 0;
}

void zop_display_text(clear)
uint clear;
{
	gui_pager(0, 21, 40, 7, zop_text_buf);
	if(clear){
		*zop_text_buf = 0;
		zop_text_ptr  = zop_text_buf;
	}
}

void zop_display_menu(prog, clear)
zop_prog_rec *prog;
uint clear;
{
	uint choice;

	if(!zop_menu_cnt){
		return;
	}

	choice = gui_menu(0, 19, 5, 38, 3, 18, zop_menu_ptrs, zop_menu_cnt, TRUE);
	prog->pc = prog->baseaddr+zop_menu_dests[choice];

	if(clear){
		zop_menu_cnt = 0;
	}
}
