#include <stdlib.h>
#include <string.h>
#include <sms.h>

#define FROM_FP(n) ((n) >> 4)
#define TO_FP(n) ((n) << 4)

#define BKG_HEIGHT 28
#define BKG_VERT_RANGE (BKG_HEIGHT << 3)
#define MAX_TERRAIN_SLICES BKG_HEIGHT
#define VISIBLE_SLICES 24
#define TERRAIN_WIDTH 24
#define RIVERBANK_L_MIN_X 1
#define RIVERBANK_L_MAX_X 10
#define RIVERBANK_MIN_W 5
#define RIVERBANK_MAX_W 10
#define MAX_STEEPNESS 0x14
#define STAGE_LENGTH 128
//#define STAGE_LENGTH 28
#define BRIDGE_CORRIDOR_START_LENGTH (RIVERBANK_L_MAX_X-RIVERBANK_L_MIN_X)
#define BRIDGE_ROAD_LENGTH 5
#define BRIDGE_CORRIDOR_LENGTH (7 + BRIDGE_CORRIDOR_START_LENGTH)
#define STAGE_PIXEL_LENGTH (STAGE_LENGTH << 3)
#define TERRAIN_ACTOR_MASK 0x07
#define TERRAIN_ACTOR_SHIFT 3
#define TERRAIN_ACTOR_COUNT (MAX_TERRAIN_SLICES >> TERRAIN_ACTOR_SHIFT)
#define NUMBER_0_TILE 0x01
#define RIVER_TILE 0x10
#define GROUND_TILE 0x11
#define RIVERBANK_TILE 0x12
#define RIVERBANK_TILE_45 0x13
#define RIVERBANK_TILE_30_1 0x14
#define RIVERBANK_TILE_30_2 0x15
#define RIVERBANK_TILE_135 0x16
#define RIVERBANK_TILE_150_1 0x17
#define RIVERBANK_TILE_150_2 0x18
#define ROAD_TILE 0x1B
#define ROAD_TILE_BOTTOM 0x1C
#define ROAD_TILE_CENTER 0x1D
#define ENM_HELICOPTER_TILE 0x44
#define FUELING_TILE 0x48
#define MISSILE_TILE 0x4C
#define AIRPLANE_TILE 0x40
#define AIRPLANE_Y 170
#define SCORE_X 26
#define SCORE_Y 1
#define MAX_VISIBLE_SPRITES 10

typedef struct _river_bank {
	char l, r;
} river_bank;

typedef struct _terrain_slice {
	river_bank river_banks[2];
} terrain_slice;

typedef struct _actor {
	int x, y;
	char w, h;
	int spd_x, spd_y;
	int min_x, max_x;
	unsigned int tile_no;
} actor;

typedef struct _terrain_data {
	terrain_slice slices[MAX_TERRAIN_SLICES];
	actor actors[TERRAIN_ACTOR_COUNT];
	// Terrain generation data
	int curr_x;
	int curr_row;
	int x_inc;
	int width;
	int redraw_row;
	int scroll_y;
	int remaining_slices;
	unsigned int slice_buffer[TERRAIN_WIDTH];
} terrain_data;

typedef struct _envyronment {
	terrain_data terrain;
	unsigned char bkg_pal[16];
	unsigned int score, prev_score;
	unsigned int timer;
} envyronment;

unsigned int road_pattern[] = {ROAD_TILE_BOTTOM, ROAD_TILE, ROAD_TILE_CENTER, ROAD_TILE, ROAD_TILE_BOTTOM | BKG_ATTR_VFLIP};

extern unsigned char terrain_tileset_apk[];
extern unsigned char sprite_tileset_apk[];
extern unsigned char pal_terrain[];
extern unsigned char pal_sprite[];

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

void find_margins(int a, int b, int c, int d, int *l, int *r) {
	int mx = a;
	int mn = a;

	mx = max(mx, b);
	mn = min(mn, b);

	mx = max(mx, c);
	mn = min(mn, c);

	mx = max(mx, d);
	mn = min(mn, d);

	*l = mn;
	*r = mx;
}

void draw_l_margin(unsigned int *buffer, int x, int x2) {
	unsigned int *p = buffer + x;

	if (x != x2) {
		if (x < x2) {
			*p = GROUND_TILE;
			p++;
			if (x2-x < 2) {
				*p = RIVERBANK_TILE_45 | BKG_ATTR_HFLIP;
			} else {
				*p = RIVERBANK_TILE_30_2 | BKG_ATTR_HFLIP;
				p++;
				*p = RIVERBANK_TILE_30_1 | BKG_ATTR_HFLIP;
			}
		} else {
			if (x-x2 < 2) {
				*p = RIVERBANK_TILE_135 | BKG_ATTR_HFLIP;
			} else {
				*p = RIVERBANK_TILE_150_1 | BKG_ATTR_HFLIP;
				p--;
				*p = RIVERBANK_TILE_150_2 | BKG_ATTR_HFLIP;
			}
		}
	} else {
		*p = RIVERBANK_TILE | BKG_ATTR_HFLIP;
	}
}

void draw_r_margin(unsigned int *buffer, int x, int x2) {
	unsigned int *p = buffer + x;

	if (x != x2) {
		if (x > x2) {
			*p = GROUND_TILE;
			p--;
			if (x-x2 < 2) {
				*p = RIVERBANK_TILE_45;
			} else {
				*p = RIVERBANK_TILE_30_2;
				p--;
				*p = RIVERBANK_TILE_30_1;
			}
		} else {
			if (x2-x < 2) {
				*p = RIVERBANK_TILE_135;
			} else {
				*p = RIVERBANK_TILE_150_1;
				p++;
				*p = RIVERBANK_TILE_150_2;
			}
		}
	} else {
		*p = RIVERBANK_TILE;
	}
}

void build_terrain_slice(terrain_data *td, terrain_slice *ts, int y) {
	char i;
	unsigned int *buffer = td->slice_buffer;
	unsigned int *p;
	river_bank *rb, *rb2;
	terrain_slice *tsb; // Previous terrain slice
	river_bank *rbb, *rbb2;
	int l, r;
	int l2, r2;

	// Draws grass
	memsetw(buffer, GROUND_TILE, TERRAIN_WIDTH);

	// Left river bank's water
	rb = ts->river_banks;
	memsetw(buffer + rb->l, RIVER_TILE, rb->r - rb->l + 1);

	// Right river bank's water
	rb2 = rb + 1;
	memsetw(buffer + rb2->l, RIVER_TILE, rb2->r - rb2->l + 1);

	// Gets info about prev. slice
	if (y == MAX_TERRAIN_SLICES-1) {
		tsb = td->slices;
	} else {
		tsb = ts+1;
	}
	rbb = tsb->river_banks;
	rbb2 = rbb + 1;

	// Draws the river's margins.
	if (rb->r < rb2->l) {
		draw_l_margin(buffer, rb->l, rbb->l);
		draw_r_margin(buffer, rb->r, rbb->r);
		draw_l_margin(buffer, rb2->l, rbb2->l);
		draw_r_margin(buffer, rb2->r, rbb2->r);
	} else {
		find_margins(rb->l, rb->r, rb2->l, rb2->r, &l, &r);
		find_margins(rbb->l, rbb->r, rbb2->l, rbb2->r, &l2, &r2);
		draw_l_margin(buffer, l, l2);
		draw_r_margin(buffer, r, r2);
	}
}

void build_terrain_road_slice(terrain_data *td, terrain_slice *ts, int y, unsigned int ofs) {
	char i;
	unsigned int *buffer = td->slice_buffer;
	river_bank *rb, *rb2;

	// Draws the road
	ofs %= 5;
	memsetw(buffer, road_pattern[ofs], TERRAIN_WIDTH);
//	memsetw(buffer, road_pattern[0], TERRAIN_WIDTH);

	// Left river bank's water
	rb = ts->river_banks;
	memsetw(buffer + rb->l, RIVER_TILE, rb->r - rb->l + 1);

	// Right river bank's water
	rb2 = rb + 1;
	memsetw(buffer + rb2->l, RIVER_TILE, rb2->r - rb2->l + 1);
}

void generate_terrain_slice_banks(terrain_data *t, terrain_slice *sl) {
	river_bank *rb, *rb2;

	rb = sl->river_banks;
	rb->l = FROM_FP(t->curr_x);
	rb->r = rb->l + t->width;

	rb2 = rb;
	rb++;
	rb->l = TERRAIN_WIDTH - rb2->r - 1;
	rb->r = TERRAIN_WIDTH - rb2->l - 1;
}

void init_terrain(terrain_data *t) {
	char i;
	terrain_slice *sl;
	actor *act;

	t->curr_x = TO_FP((TERRAIN_WIDTH-RIVERBANK_MIN_W) >> 1);
	t->curr_row = VISIBLE_SLICES-1;
	t->x_inc = TO_FP(-1);
	t->width = RIVERBANK_MIN_W;
	t->redraw_row = -1;
	t->remaining_slices = STAGE_LENGTH;

	for (i = 0, sl = t->slices; i != MAX_TERRAIN_SLICES; i++, sl++) {
		generate_terrain_slice_banks(t, sl);
	}

	for (i = 0, act = t->actors; i != TERRAIN_ACTOR_COUNT; i++, act++) {
		act->tile_no = 0;
	}
}

void generate_terrain_slice(terrain_data *t, int row) {
	terrain_slice *sl = t->slices + row;
	int act_row;
	actor *act;
	river_bank *rb;

	generate_terrain_slice_banks(t, sl);

	if (t->remaining_slices < 0) { // Bridge
	    if (t->curr_x < TO_FP((TERRAIN_WIDTH-RIVERBANK_MIN_W) >> 1)) {
			t->curr_x = to_fp(from_fp(t->curr_x) + 1);
		} else if (t->curr_x > TO_FP((TERRAIN_WIDTH-RIVERBANK_MIN_W) >> 1)) {
			t->curr_x = to_fp(from_fp(t->curr_x) - 1);
		}
		if (t->width > RIVERBANK_MIN_W) {
			t->width--;
		}
	} else { // Normal terrain generation
		t->curr_x += t->x_inc;
		if (t->curr_x < TO_FP(RIVERBANK_L_MIN_X)) {
			t->curr_x = TO_FP(RIVERBANK_L_MIN_X);
			t->x_inc = 0;
		} else if (t->curr_x > TO_FP(RIVERBANK_L_MAX_X)) {
			t->curr_x = TO_FP(RIVERBANK_L_MAX_X);
			t->x_inc = 0;
		}

		if (!(rand() & 0x03)) {
			t->x_inc += ((rand() % 9)-4) << 2;
			if (t->x_inc < -MAX_STEEPNESS) {
				t->x_inc = -MAX_STEEPNESS;
			} else if (t->x_inc > MAX_STEEPNESS) {
				t->x_inc = MAX_STEEPNESS;
			}
		}

		if (!(rand() & 0x03)) {
			t->width += rand() % 3 - 1;
			if (t->width < RIVERBANK_MIN_W) {
				t->width = RIVERBANK_MIN_W;
			} else if (t->width > RIVERBANK_MAX_W) {
				t->width = RIVERBANK_MAX_W;
			}
		}
	}

	if (!(row & TERRAIN_ACTOR_MASK)) {
		act_row = row >> TERRAIN_ACTOR_SHIFT;
		if (act_row < TERRAIN_ACTOR_COUNT) {
			act = t->actors + act_row;
			rb = sl->river_banks;
			if (rand() & 0x01) {
				rb++;
			}
			act->min_x = to_fp(rb->l << 3) + TO_FP(8);
			act->max_x = to_fp(rb->r << 3) - TO_FP(24);
			if (rand() & 0x01) {
				act->x = act->min_x;
			} else {
				act->x = act->max_x;
			}
			act->y = TO_FP(-16);
			if (rand() & 0x01) {
				act->w = 2;
				act->h = 1;
				act->spd_x = 0x08;
				act->tile_no = ENM_HELICOPTER_TILE;
			} else {
				act->w = 1;
				act->h = 2;
				act->spd_x = 0;
				act->tile_no = FUELING_TILE;
			}
		}
	}

	t->curr_row = row;
	t->redraw_row = row;
}

void generate_terrain(terrain_data *t) {
	int i;
	for (i = 0; i != MAX_TERRAIN_SLICES; i++) {
		generate_terrain_slice(t, i);
	}
}

void draw_full_terrain(terrain_data *t) {
	char i;
	terrain_slice *ts;

	for (i = 0, ts = t->slices; i != VISIBLE_SLICES; i++, ts++) {
		build_terrain_slice(t, ts, i);
		wait_vblank_noint();
		set_bkg_map(t->slice_buffer, 0, i, TERRAIN_WIDTH, 1);
	}
}

void scroll_terrain(terrain_data *t, int y_spd) {
	int i, row;
	actor *act;

	t->scroll_y -= y_spd;
	if (t->scroll_y < 0) {
		t->scroll_y += TO_FP(BKG_VERT_RANGE);
	}

	row = from_fp(t->scroll_y) >> 3;
	if (t->curr_row != row) {
		generate_terrain_slice(t, row);
		t->remaining_slices--;
		if (t->remaining_slices < -BRIDGE_CORRIDOR_LENGTH) {
			t->remaining_slices = STAGE_LENGTH;
		}
	}

	if (t->redraw_row != -1) {
		if ((t->remaining_slices < -BRIDGE_CORRIDOR_START_LENGTH) &&
		    (t->remaining_slices >= -(BRIDGE_CORRIDOR_START_LENGTH+BRIDGE_ROAD_LENGTH))) {
			build_terrain_road_slice(t, t->slices + t->redraw_row, t->redraw_row,
			                         abs(t->remaining_slices + BRIDGE_CORRIDOR_START_LENGTH + 1));
		} else {
			build_terrain_slice(t, t->slices + t->redraw_row, t->redraw_row);
		}
	}

	for (i = 0, act = t->actors; i != TERRAIN_ACTOR_COUNT; i++, act++) {
		act->y += y_spd;
		if (act->y > TO_FP(192)) {
			act->tile_no = 0;
		}
	}
}

void update_draw_terrain(terrain_data *t) {
	if (t->redraw_row != -1) {
		set_bkg_map(t->slice_buffer, 0, t->redraw_row, TERRAIN_WIDTH, 1);
		t->redraw_row = -1;
	}
	scroll_bkg(0, from_fp(t->scroll_y));
}

void move_actor(actor *act) {
	act->x += act->spd_x;
	act->y += act->spd_y;
	if (act->x > act->max_x) {
		act->spd_x = -abs(act->spd_x);
	} else if (act->x < act->min_x) {
		act->spd_x = abs(act->spd_x);
	}
}

void draw_actor(actor *act, int *curr_spr) {
	int x, y, tile;
	int i, j, y2;

/*	if (*curr_spr > 63) {
		return;
	}*/

	if (!act->tile_no) {
		return;
	}

	if ((act->x < TO_FP(-16)) || (act->x > TO_FP(255)) ||
	    (act->y < TO_FP(-16)) || (act->y > TO_FP(192))) {
		return;
	}

	x = from_fp(act->x);
	y = from_fp(act->y);
	tile = act->tile_no;

	for (i = act->w; i; i--, x += 8) {
		for (j = act->h, y2 = y; j; j--, y2 += 16, tile += 2, (*curr_spr)++) {
			set_sprite(*curr_spr, x, y2, tile);
		}
	}
}

void move_enemies(terrain_data *t) {
	int i;
	actor *act;

	for (i = 0, act = t->actors; i != TERRAIN_ACTOR_COUNT; i++, act++) {
		move_actor(act);
	}
}

void draw_enemies(terrain_data *t, int *curr_spr) {
	int i;
	actor *act;

	for (i = 0, act = t->actors; i != TERRAIN_ACTOR_COUNT; i++, act++) {
		draw_actor(act, curr_spr);
	}
}

/*
void animate_palette(envyronment *envyro) {
	unsigned char *p, *p2, c, i;

	// Water palette rotation
	if (!(envyro->timer & 0x0F)) {
		p = envyro->bkg_pal + 4;
		p2 = p + 3;
		c = *p2;
		for (; p2 != p; p2--) {
			*p2 = *(p2-1);
		}
		*p = c;
	}

	load_palette(envyro->bkg_pal, 0, 16);
}
*/


/* "fine" terrain collision checking. Will be completed later.
char is_inside_margins(int x, int delta, int l1, int r1, int r2, int l2) {
	int l, r;

    delta &= 0x07;
	l = (l1 * delta + l2 * (7-delta));
	r = (r1 * delta + r2 * (7-delta));

	return (l <= x) && (r >= x);
}

char dot_terrain_collision(terrain_data *t, int x, int y) {
	int row, delta;
	terrain_slice *sl, *slb;
	river_bank *lb, *rb;
	river_bank *lb2, *rb2;
	int l, r;
	int l2, r2;

	delta = y + from_fp(t->scroll_y);
	row = delta >> 3;
	delta -= row << 3;
	if (row > BKG_HEIGHT) {
		row -= BKG_HEIGHT;
	}

	sl = t->slices + row;

	lb = sl->river_banks;
	rb = lb + 1;

	// Gets info about prev. slice
	if (row == MAX_TERRAIN_SLICES-1) {
		slb = t->slices;
	} else {
		slb = sl+1;
	}
	lb2 = slb->river_banks;
	rb2 = lb2 + 1;

	// checks the river's margins.
	if (lb->r < rb->l) {
//		draw_l_margin(buffer, rb->l, rbb->l);
//		draw_r_margin(buffer, rb->r, rbb->r);
//		draw_l_margin(buffer, rb2->l, rbb2->l);
//		draw_r_margin(buffer, rb2->r, rbb2->r);
	} else {
		find_margins(lb->l, lb->r, rb->l, rb->r, &l, &r);
		find_margins(lb2->l, lb2->r, rb2->l, rb2->r, &l2, &r2);
		return !is_inside_margins(x, delta, l, r, l2, r2);
	}

	return FALSE;
}
*/

/* "coarse" terrain collision checking */
char is_inside_margins(int x, int l, int r) {
	l <<= 3;
	r <<= 3;
	return (l <= x) && (r >= x);
}

char dot_terrain_collision(terrain_data *t, int x, int y) {
	int row, delta;
	terrain_slice *sl;
	river_bank *lb, *rb;
	int l, r;

	delta = y + from_fp(t->scroll_y);
	row = delta >> 3;
	delta -= row << 3;
	if (row > BKG_HEIGHT-1) {
		row -= BKG_HEIGHT;
	}

	sl = t->slices + row;

	lb = sl->river_banks;
	rb = lb + 1;

	if (lb->r < rb->l) {
		return !is_inside_margins(x, lb->l, lb->r) &&
			   !is_inside_margins(x, rb->l, rb->r);
	} else {
		find_margins(lb->l, lb->r, rb->l, rb->r, &l, &r);
		return !is_inside_margins(x, l, r);
	}

	return FALSE;
}

char check_player_terrain_collision(terrain_data *t, int x) {
	int dot_x = from_fp(x);

	if (dot_terrain_collision(t, dot_x + 4, AIRPLANE_Y + 2)||
	    dot_terrain_collision(t, dot_x + 2, AIRPLANE_Y + 12) ||
	    dot_terrain_collision(t, dot_x + 14, AIRPLANE_Y + 12)) {
		return TRUE;
	}
	return FALSE;
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

void main() {
	int i;
	int ply_x;
	int spd_y;
	int collision_ctr;
	int joy;
	int curr_spr;
	unsigned char ch;
	envyronment envyro;
	actor shot;

	load_palette(pal_terrain, 0, 16);
	load_palette(pal_sprite, 16, 16);
	load_main_tileset();
	for (i = 0; i != 64; i++) {
		set_sprite(i, -16, -16, 0);
	}
	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_CHANGE | VDP_REG_FLAGS0_LOCKRIGHT);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN | VDP_REG_FLAGS1_8x16);

	memcpy(envyro.bkg_pal, pal_terrain, 16);

	init_terrain(&(envyro.terrain));
//	generate_terrain(&(envyro->terrain));
	draw_full_terrain(&(envyro.terrain));

	envyro.score = 0;
	envyro.prev_score = 1;
	refresh_score(&envyro);

	shot.x = 0;
	shot.y = 0;
	shot.w = 1;
	shot.h = 1;
	shot.spd_x = 0;
	shot.spd_y = -0x30;
	shot.tile_no = 0;

	ply_x = to_fp(((TERRAIN_WIDTH >> 1) - 1) << 3);

	for (;;) {
		joy = read_joypad1();

		if (joy & JOY_LEFT) {
			ply_x -= 0x10;
		}
		if (joy & JOY_RIGHT) {
			ply_x += 0x10;
		}
		if (joy & JOY_UP) {
			if (spd_y < 0x20) {
				spd_y++;
			}
		} else if (joy & JOY_DOWN) {
			if (spd_y > 0x08) {
				spd_y--;
			}
		} else {
			if (spd_y > 0x10) {
				spd_y--;
			} else if (spd_y < 0x10) {
				spd_y++;
			}
		}

		if (joy & (JOY_FIREA | JOY_FIREB)) {
			shot.x = ply_x + TO_FP(4);
			shot.y = TO_FP(AIRPLANE_Y);
			shot.tile_no = MISSILE_TILE;
		}

		scroll_terrain(&(envyro.terrain), spd_y);

		load_palette(pal_terrain, 0, 1);
		if (check_player_terrain_collision(&(envyro.terrain), ply_x)) {
			ch = 0x03;
			load_palette(&ch, 0, 1);
		}

		move_enemies(&(envyro.terrain));
		move_actor(&shot);

		wait_vblank_noint();
		update_draw_terrain(&(envyro.terrain));
		refresh_score(&envyro);

		set_sprite(0, from_fp(ply_x), AIRPLANE_Y, AIRPLANE_TILE);
		set_sprite(1, from_fp(ply_x)+8, AIRPLANE_Y, AIRPLANE_TILE+2);

		curr_spr = 2;
		draw_enemies(&(envyro.terrain), &curr_spr);
		draw_actor(&shot, &curr_spr);

		if (curr_spr < MAX_VISIBLE_SPRITES) {
			for (; curr_spr != MAX_VISIBLE_SPRITES; curr_spr++) {
				set_sprite(curr_spr, -16, -16, 0);
			}
		}

		envyro.score = curr_spr; /* *** DEBUG *** */

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
