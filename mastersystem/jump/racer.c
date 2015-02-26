#include <stdlib.h>
#include <string.h>
#include <sms.h>

#define FROM_FP(n) ((n) >> 4)
#define TO_FP(n) ((n) << 4)

#define NUMBER_0_TILE 0x01
#define AIRPLANE_TILE 0x40
#define SCORE_X 26
#define SCORE_Y 1
#define MAX_VISIBLE_SPRITES 10
#define VISIBLE_BKG_WIDTH 32
#define FULL_BKG_WIDTH 32
#define VISIBLE_BKG_HEIGHT 24
#define FULL_BKG_HEIGHT 28
#define FULL_PLAYFIELD_HEIGHT 40

typedef struct _actor {
	int x, y;
	char w, h;
	fixed step_x, step_y;
	fixed spd_x, spd_y;
	int top, left, width, height;
	unsigned int tile_no;
	char on_ground;
} actor;

typedef struct _scroll_data {
	int x, y;
	int max_x, max_y;
	int prev_x, prev_y;
} scroll_data;

typedef struct _envyronment {
	unsigned char bkg_pal[16];
	unsigned int score, prev_score;
	unsigned int timer;
} envyronment;

extern unsigned char terrain_tileset_apk[];
extern unsigned char sprite_tileset_apk[];
extern unsigned char pal_terrain[];
extern unsigned char pal_sprite[];

unsigned char map[] = {0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x04,0x04,0x04,0x04,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x04,0x04,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x04,0x04,0x04,0x04,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x00,0x04,0x04,0x04,0x00,0x04,
                       0x04,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x04,
                       0x04,0x04,0x04,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x04,0x04,0x04,0x04,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,
                       0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,};

void load_main_tileset() {
	unsigned char buffer[4096];
	aplib_depack(terrain_tileset_apk, buffer);
	load_tiles(buffer, 0, 64, 4);
	aplib_depack(sprite_tileset_apk, buffer);
	load_tiles(buffer, 64, 64, 4);
}

int from_fp(int n) {
	return FROM_FP(n);
}

int to_fp(int n) {
	return TO_FP(n);
}

int asr(int n, int cnt) {
	if (n < 0) {
		return -((-n) >> cnt);
	} else {
		return n >> cnt;
	}
}

void memsetw(unsigned int *p, unsigned int value, int count) {
	for (; count; count--, p++) {
		*p = value;
	}
}

int max(int a, int b) {
	return (a > b ? a : b);
}

int min(int a, int b) {
	return (a < b ? a : b);
}

char collide_rect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2) {

    int left1, left2;
    int right1, right2;
    int top1, top2;
    int bottom1, bottom2;

    left1 = x1;
    left2 = x2;
    right1 = x1 + w1;
    right2 = x2 + w2;
    top1 = y1;
    top2 = y2;
    bottom1 = y1 + h1;
    bottom2 = y2 + h2;

    if (bottom1 < top2) return(0);
    if (top1 > bottom2) return(0);

    if (right1 < left2) return(0);
    if (left1 > right2) return(0);

    return(1);

}

/**
 * x and y are given in map coordinates
 **/
char get_map_tile(unsigned char *map, int mx, int my) {
	mx >>= 1;
	return *(map + (my << 4) + mx);
}

/**
 * x, y, w and h are given in screen pixel coordinates
 **/
char collide_rect_map(unsigned char *map, int x, int y, int w, int h) {
	int left = x >> 4;
	int right = ((x+w+15) >> 4) + 1;
	int top = y >> 4;
	int bottom = ((y+h+15) >> 4) + 1;
	int i, j;

	for (i = left; i != right; i++) {
		for (j = top; j != bottom; j++) {
			if (get_map_tile(map, i, j)) {
				if (collide_rect(x, y, w, h, i << 4, j << 4, 16, 16)) {
					return 1;
				}
			}
		}
	}
	return 0;
}

char collide_actor_map(unsigned char *map, actor *act) {
	return collide_rect_map(map, act->x + act->left, act->y + act->top, act->width, act->height);
}

char shakeoff_actor_horiz(actor *act) {
	int x = act->x;
	int y = act->y;
	UWORD spd_x_cnt = abs(act->spd_x.w);

	if (act->spd_x.w == 0) {
		return;
	}

	while (spd_x_cnt > 0) {
		if ((WORD)act->spd_x.w < 0) {
			x++;
		} else {
			x--;
		}

		if (!collide_rect_map(map, x + act->left, y + act->top, act->width, act->height)) {
			act->x = x;
			act->spd_x.w = 0;
			return 1;
		}

		spd_x_cnt -= 0x100;
	}

	return 0;
}

char shakeoff_actor_vert(actor *act) {
	int x = act->x;
	int y = act->y;
	int spd_y_cnt = abs(act->spd_y.w);

	if (act->spd_y.w == 0) {
		return;
	}

	while (spd_y_cnt > 0) {
		if ((WORD)act->spd_y.w < 0) {
			y++;
		} else {
			y--;
		}

		if (!collide_rect_map(map, x + act->left, y + act->top, act->width, act->height)) {
			act->y = y;
			act->spd_y.w = 0;
			return 1;
		}

		spd_y_cnt -= 0x100;
	}

	return 0;
}

void move_actor(actor *act) {
	unsigned int tx, ty;
	unsigned int tilenum;

	act->step_y.w += act->spd_y.w;
	act->y += (BYTE)act->step_y.b.h;
	act->step_y.b.h = 0;

	act->on_ground = 0;
	if (collide_actor_map(map, act)) {
		act->on_ground = ((WORD)act->spd_y.w > 0);
		shakeoff_actor_vert(act);
	}

	(WORD)act->step_x.w += (WORD)act->spd_x.w;
	act->x += (BYTE)act->step_x.b.h;
/*	if (((BYTE)act->step_x.b.h) < 0) {
		act->step_x.b.h = 0xFF;
	} else {
		act->step_x.b.h = 0x00;
	}*/
	act->step_x.w = 0;

	if (collide_actor_map(map, act)) {
		shakeoff_actor_horiz(act);
	}
}

void draw_actor(scroll_data *scroll, actor *act, int *curr_spr) {
	int x, y, tile;
	int i, j, y2;

	if (*curr_spr > 63) {
		return;
	}

	if (!act->tile_no) {
		return;
	}

	x = act->x - scroll->x;
	y = act->y - scroll->y;
	tile = act->tile_no;

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

void draw_number(int x, int y, unsigned int n, int width) {
	unsigned int buffer[5];
	unsigned int *p = buffer + width - 1;

	memsetw(buffer, 0x0000, 5);
	do {
		*p = NUMBER_0_TILE + (n % 10);
		p--;
		n /= 10;
	} while (n != 0);

	set_bkg_map(buffer, x, y, width, 1);
}

void refresh_score(envyronment *envyro) {
	if (envyro->score != envyro->prev_score) {
		draw_number(SCORE_X, SCORE_Y, envyro->score, 5);
		envyro->prev_score = envyro->score;
	}
}

void draw_half_tile(int bx, int by, int tile) {
	unsigned int buffer[2];
	int tle;

	bx &= 0x1F;
	by &= 0xFFFE;
	while (by >= FULL_BKG_HEIGHT) {
		by -= FULL_BKG_HEIGHT;
	}

	tle = tile + ((bx & 0x01) << 1);

	*buffer = tle;
	*(buffer+1) = tle+1;

	set_bkg_map(buffer, bx, by, 1, 2);
}

void draw_quarter_tile(int bx, int by, int tile) {
	int tle;

	bx &= 0x1F;
	while (by >= FULL_BKG_HEIGHT) {
		by -= FULL_BKG_HEIGHT;
	}

	tle = tile + (by & 0x01) + ((bx & 0x01) << 1);

	set_bkg_map(&tle, bx, by, 2, 1);
}

void draw_map_coord(int mx, int my) {
	unsigned int tile = get_map_tile(map, mx >> 1, my >> 1);

	tile <<= 2;
	draw_half_tile(mx, my, tile);
}

void draw_half_map_coord(int mx, int my) {
	unsigned int tile = get_map_tile(map, mx >> 1, my >> 1);

	tile <<= 2;
	draw_quarter_tile(mx, my, tile);
}

void draw_bkg() {
	int i, j;

	for (i = 0; i != FULL_BKG_WIDTH+1; i++) {
		for (j = 0; j != FULL_BKG_HEIGHT+1; j++) {
			draw_map_coord(i, j);
		}
	}
}

void calc_bkg_scroll(scroll_data *scroll) {
	if (scroll->x < 0) {
		scroll->x = 0;
	} else if (scroll->x > scroll->max_x) {
		scroll->x = scroll->max_x;
	}

	if (scroll->y < 0) {
		scroll->y = 0;
	} else if (scroll->y > scroll->max_y) {
		scroll->y = scroll->max_y;
	}
}

void draw_bkg_scroll(scroll_data *scroll) {
	int delta_x = asr(scroll->x, 3) - asr(scroll->prev_x, 3);
	int delta_y = asr(scroll->y, 3) - asr(scroll->prev_y, 3);
	int tx = asr(scroll->x, 3);
	int ty = asr(scroll->y, 3);
	int tx2, ty2;
	int i, j;

	scroll_bkg(-scroll->x, ((28 << 3) + scroll->y) % (28 << 3));

	if (delta_y != 0) {
		if (delta_y < 0) {
			for (j = delta_y, ty2 = ty; j; j++, ty2++) {
				for (i = VISIBLE_BKG_WIDTH, tx2 = tx + 1; i; i--, tx2++) {
					draw_half_map_coord(tx2, ty2);
				}
			}
		} else {
			for (j = delta_y, ty2 = ty + VISIBLE_BKG_HEIGHT; j; j--, ty2--) {
				for (i = VISIBLE_BKG_WIDTH, tx2 = tx + 1; i; i--, tx2++) {
					draw_half_map_coord(tx2, ty2);
				}
			}
		}
		scroll->prev_y = scroll->y;
	}

	if (delta_x != 0) {
		if (delta_x < 0) {
			for (i = delta_x, tx2 = tx + 1; i; i++, tx2++) {
				for (j = 0, ty2 = ty; j < VISIBLE_BKG_HEIGHT + 2; j += 2, ty2 += 2) {
					draw_map_coord(tx2, ty2);
				}
			}
		} else {
			for (i = delta_x, tx2 = tx + VISIBLE_BKG_WIDTH; i; i--, tx2--) {
				for (j = 0, ty2 = ty; j < VISIBLE_BKG_HEIGHT + 2; j += 2, ty2 += 2) {
					draw_map_coord(tx2, ty2);
				}
			}
		}
		scroll->prev_x = scroll->x;
	}
}

void main() {
	int i;
	actor player;
	int spd_y;
	int collision_ctr;
	int joy;
	int curr_spr;
	unsigned char ch;
	scroll_data scroll;
	envyronment envyro;
	actor shot;

	load_palette(pal_terrain, 0, 16);
	load_palette(pal_sprite, 16, 16);
	load_main_tileset();
	for (i = 0; i != 64; i++) {
		set_sprite(i, -16, -16, 0);
	}
	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_CHANGE | VDP_REG_FLAGS0_LHS);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN | VDP_REG_FLAGS1_8x16);

	memcpy(envyro.bkg_pal, pal_terrain, 16);

	envyro.score = 0;
	envyro.prev_score = 1;
	refresh_score(&envyro);

	shot.x = 0;
	shot.y = 0;
	shot.w = 1;
	shot.h = 1;
	shot.spd_x.w = 0;
	shot.spd_y.w = -0x300;
	shot.tile_no = 0;

	player.x = 160;
	player.y = 100;
	player.tile_no = AIRPLANE_TILE;
	player.w = 2;
	player.h = 1;
	player.top = 2;
	player.left = 4;
	player.width = 8;
	player.height = 14;

	scroll.x = 0;
	scroll.y = 0;
	scroll.prev_x = 0;
	scroll.prev_y = 0;
	scroll.max_x = (VISIBLE_BKG_WIDTH << 3) - 8;
	scroll.max_y = (FULL_PLAYFIELD_HEIGHT << 3) - (VISIBLE_BKG_HEIGHT << 3);

	draw_bkg();

	for (;;) {
		joy = read_joypad1();

		if (joy & JOY_LEFT) {
			if ((BYTE)player.spd_x.b.h > -0x02) {
				player.spd_x.w -= 0x50;
			}
		} else if (joy & JOY_RIGHT) {
			if ((BYTE)player.spd_x.b.h < 0x02) {
				player.spd_x.w += 0x50;
			}
		} else {
			if (!player.spd_x.b.h) {
				player.spd_x.b.l = 0;
			} else if ((BYTE)player.spd_x.b.h < 0) {
				player.spd_x.b.h++;
			} else {
				player.spd_x.b.h--;
			}
		}

		if (joy & JOY_FIREA) {
			if (player.on_ground) {
				player.spd_y.w = -0x700;
			}
		}

		player.spd_y.w += 0x50;
		move_actor(&player);

		scroll.x = player.x - 160;
		scroll.y = player.y - 100;

		calc_bkg_scroll(&scroll);

		wait_vblank_noint();

		draw_bkg_scroll(&scroll);

		curr_spr = 0;
		draw_actor(&scroll, &player, &curr_spr);

		if (curr_spr < MAX_VISIBLE_SPRITES) {
			for (; curr_spr != MAX_VISIBLE_SPRITES; curr_spr++) {
				set_sprite(curr_spr, -16, -16, 0);
			}
		}

		envyro.timer++;
	}
}

#asm
._terrain_tileset_apk
	BINARY	"terrain.apk"
._sprite_tileset_apk
	BINARY	"sprite.apk"
._pal_terrain
	BINARY	"terrain2.pal"
._pal_sprite
	BINARY	"sprite.pal"
#endasm
