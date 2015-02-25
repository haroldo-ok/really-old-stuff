#ifndef _INC_BATTLE
#define _INC_BATTLE

typedef struct{
	int xofs, yofs;
	uint sprnum;
	uint delay;
	uint next;
}spr_anim_frame;

typedef struct{
	spr_anim_frame *anim;
	uint anim_hit, anim_atk1, anim_atk2, anim_atk3;
	uint hit_dly1, hit_dly2, hit_dly3;
}battle_anim_def;

/* Coment rio adicionado por causa de um pau do compilador */

typedef struct{
	uint X, Y;
	uint sprnum;
	ulong base;
	uint dest;
	spr_anim_frame *anim;
	uint dly_cntr, anim_num;
	uint mirror;
	battle_anim_def *battle_def;
	void *enemy; /* Era para ser um ptr para anim_status_rec (â, compilador chato!) */
	uint enm_hit_dly_cntr;
}anim_status_rec;

void play_battle_mode();

#endif
