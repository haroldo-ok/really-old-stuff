#include <stdlib.h>
#include <string.h>
#include <sms.h>

typedef struct _actor {
	int x, y;
	char w, h;
	fixed step_x, step_y;
	fixed spd_x, spd_y;
	int tile_no;
	int frame_no;
} actor;

extern unsigned char sortem_tileset_apk[];
extern unsigned int sortem_background_bg2[];

unsigned char pal_main[] = {0x00, 0x30, 0x03, 0x0C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void load_main_tileset() {
	unsigned char buffer[4096];
	aplib_depack(sortem_tileset_apk, buffer);
	load_tiles(buffer, 0, 64, 4);
}

void draw_main_background() {
	int i;

	for (i = 0; i != 14; i++) {
		set_bkg_map(sortem_background_bg2, 0, i << 1, 32, 2);
	}

	set_bkg_map(sortem_background_bg2+64, 0, 4, 32, 2);
	set_bkg_map(sortem_background_bg2+128, 0, 6, 32, 2);
	set_bkg_map(sortem_background_bg2+128, 0, 8, 32, 2);
	set_bkg_map(sortem_background_bg2+128, 0, 10, 32, 2);
	set_bkg_map(sortem_background_bg2+192, 0, 12, 32, 2);
}

int asr(int n, int cnt) {
	if (n < 0) {
		return -((-n) >> cnt);
	} else {
		return n >> cnt;
	}
}

void move_actor(actor *act, int wall_y) {
	unsigned int tx, ty;
	unsigned int tilenum;

	(WORD)act->step_y.w += (WORD)act->spd_y.w;
	act->y += (BYTE)act->step_y.b.h;
	act->step_y.b.h = 0;

	if (act->y < 0) {
		act->y = 0;
		act->spd_y.w = -(WORD)act->spd_y.w;
	} else if (act->y > (192-16)) {
		act->y = (192-16);
		act->spd_y.w = -(WORD)act->spd_y.w;
	}

	(WORD)act->step_x.w += (WORD)act->spd_x.w;
	act->x += (BYTE)act->step_x.b.h;
	act->step_x.b.h = 0;

	if (act->x < 0) {
		act->x = 0;
		act->spd_x.w = -(WORD)act->spd_x.w;
	} else if (act->x > (256-16)) {
		act->x = (256-16);
		act->spd_x.w = -(WORD)act->spd_x.w;
	} else if (((WORD)act->spd_x.w > 0) && (act->x > (128-16)) && (act->x < (128-8))) {
		// Collision on center wall from the left
		if ((act->y < (wall_y-2)) || (act->y > (wall_y+(48-16+2)))) { // Didn't pass through the hole
			act->x = (128-16);
			act->spd_x.w = -(WORD)act->spd_x.w;
		}
	} else if (((WORD)act->spd_x.w < 0) && (act->x > (128-8)) && (act->x < 128)) {
		// Collision on center wall from the right
		if ((act->y < (wall_y-2)) || (act->y > (wall_y+(48-16+2)))) { // Didn't pass through the hole
			act->x = 128;
			act->spd_x.w = -(WORD)act->spd_x.w;
		}
	}

	act->frame_no++;
}

void draw_actor(actor *act, int *curr_spr) {
	int x, y, tile;
	int i, j, y2;

	if (*curr_spr > 63) {
		return;
	}

	if (!act->tile_no) {
		return;
	}

	x = act->x;
	y = act->y;
	tile = act->tile_no + ((act->frame_no >> 1) & 0x0C);

	if ((x < -16) || (x > 255) ||
	    (y < -16) || (y > 192)) {
		return;
	}

	for (i = act->w; i; i--, x += 8) {
		for (j = act->h, y2 = y; j; j--, y2 += 16, tile += 2, (*curr_spr)++) {
			set_sprite(*curr_spr, x, y2, tile);
		}
	}
}

void scroll_wall(int wall_y) {
	wall_y = (224+48) - wall_y;
	if (wall_y > 224) {
		wall_y -= 224;
	}

	scroll_bkg(0, wall_y);
}

void main() {
	int i;
	int joy;
	int curr_spr;
	actor actors[32];
	actor *act;
	int wall_y;
	fixed wall_step_y, wall_spd_y;

	load_palette(pal_main, 0, 16);
	load_palette(pal_main, 16, 16);
	load_main_tileset();
	draw_main_background()
	set_sprite(0, 208, 208, 0);
	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_CHANGE);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN | VDP_REG_FLAGS1_8x16);

	for (i = 0, act = actors; i != 16; i++, act++) {
		if (i & 0x01) {
			act->x = 16 + (i << 4) + (rand() & 0x07);
			act->y = 16;
			act->w = 2;
			act->h = 1;
			act->step_x.w = 0;
			act->step_y.w = 0;
			act->spd_x.w = 0x150;
			act->spd_y.w = 0x100;
			act->tile_no = 16;
			act->frame_no = 0;
		} else {
			act->x = 16 + (i << 2) + (rand() & 0x07);
			act->y = 16;
			act->w = 2;
			act->h = 1;
			act->step_x.w = 0;
			act->step_y.w = 0;
			act->spd_x.w = 0x100;
			act->spd_y.w = -0x150;
			act->tile_no = 32;
			act->frame_no = 0;
		}
	}

	for (i = 0, act = actors+16; i != 16; i++, act++) {
	}

	wall_y = 0;
	wall_step_y.w = 0;
	wall_spd_y.w = 0;

	for (;;) {
		joy = read_joypad1();

		if (joy & JOY_UP) {
			if ((WORD)wall_spd_y.w > -0x400) {
				(WORD)wall_spd_y.w -= 0x50;
			}
		} else if (joy & JOY_DOWN) {
			if ((WORD)wall_spd_y.w < 0x400) {
				(WORD)wall_spd_y.w += 0x50;
			}
		} else {
			if ((BYTE)wall_spd_y.b.h < 0) {
				(WORD)wall_spd_y.w += 0x50;
			} else if ((BYTE)wall_spd_y.b.h > 0) {
				(WORD)wall_spd_y.w -= 0x50;
			} else {
				wall_spd_y.w = 0;
			}
		}

		(WORD)wall_step_y.w += (WORD)wall_spd_y.w;
		wall_y += (BYTE)wall_step_y.b.h;
		if (wall_y < 0) {
			wall_y = 0;
		} else if (wall_y > (192-48)) {
			wall_y = (192-48);
		}
		wall_step_y.b.h = 0;

		for (i = 0, act = actors; i != 4; i++, act++) {
			move_actor(act, wall_y);
		}

		wait_vblank_noint();

		scroll_wall(wall_y);

		curr_spr = 0;
		for (i = 0, act = actors; i != 4; i++, act++) {
			draw_actor(act, &curr_spr);
		}
		if (curr_spr < 64) {
			set_sprite(curr_spr, 208, 208, 0);
		}
	}

}

#asm
._sortem_tileset_apk
	BINARY	"sortem.apk"
._sortem_background_bg2
	BINARY	"sortem.bg2"
#endasm
