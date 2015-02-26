#include <stdlib.h>
#include <sms.h>

#define BLK_MOVE_LEFT 0x01
#define BLK_MOVE_RIGHT 0x02
#define BLK_MOVE_TOP 0x04
#define BLK_MOVE_BOTTOM 0x08

#define STATUS_NONE 0
#define STATUS_STAGE_CLEAR 1
#define STATUS_LOST_LIFE 2

typedef struct _meter {
	unsigned char x;
	unsigned char y;
	int value;
	int prev_value;
	int target_value;
} meter;

typedef struct _enemy {
	int x, y;
	int spd_x, spd_y;
	char active;
	int respawn;
	int top, left;
	int bottom, right;
} enemy;

typedef struct _envyronment {
	unsigned char game_status;
	int ply_x, ply_y;
	int ply_blk_x, ply_blk_y;
	int ply_last_x, ply_last_y;
	unsigned char ply_frame;
	meter meters[3];
	enemy enemies[8];
	unsigned char curr_tile;
	unsigned char prev_tile;
	unsigned char next_spr;
	unsigned int msg_ptr;
	int msg_timer;
	unsigned char *map;
} envyronment;

typedef struct _tile_attr {
	unsigned char movement;
} tile_attr;

tile_attr tile_attrs[] = {
	{0x00},		// 0
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},		// 8
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},		// 16
	{0x08},
	{0x01},
	{0x0C},
	{0x03},
	{0x0A},
	{0x0B},
	{0x0D},
	{0x0F},		// 24
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x00},
	{0x08},		// 32
	{0x01},
	{0x08},
	{0x01},
	{0x08},
	{0x01},
	{0x00},
	{0x00}		// 40
};

unsigned char pal1[] = {0x00, 0x20, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1E, 0x3E, 0x17, 0x37, 0x0F, 0x3F};

unsigned char pal_white[] = {0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
				0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F};

unsigned char pal_black[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
				0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

unsigned int meter_error[] = {0x000B, 0x000C, 0x000C, 0x000D, 0x000C};

unsigned int msg_none[]     = {0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000};
							//                 -       2       5       0
unsigned int msg_less_250[] = {0x0000, 0x0000, 0x000E, 0x0003, 0x0006, 0x0001, 0x0000, 0x0000};
							// O       V       E       R       L       O       A       D
unsigned int msg_overload[] = {0x0001, 0x0050, 0x000B, 0x000C, 0x0051, 0x000D, 0x0052, 0x0053};
                            // I       N       T       R       U       D       E       R
unsigned int msg_intruder[] = {0x0002, 0x0054, 0x0055, 0x000C, 0x0056, 0x0053, 0x000B, 0x000C};

extern unsigned char circuit_tileset_apk[];
extern unsigned char map1_apk[];

void get_tile_attr(envyronment *envyro, int x, int y, tile_attr *attr) {
	unsigned char *p = envyro->map + (y << 6) + (x << 1);
	tile_attr *atr2 = tile_attrs + (*p);
	unsigned char movement;

//	load_palette(p, 16, 1);
//	load_palette(atr2, 17, 1);

	movement = atr2->movement;

	p++;
	if ((*p) & 0x02) { // Horizontal flip
		movement = (movement & 0xFC) | ((movement & BLK_MOVE_LEFT) << 1) | ((movement & BLK_MOVE_RIGHT) >> 1);
	}
	if ((*p) & 0x04) { // Vertical flip
		movement = (movement & 0xF3) | ((movement & BLK_MOVE_TOP) << 1) | ((movement & BLK_MOVE_BOTTOM) >> 1);
	}

	attr->movement = movement;

//	load_palette(attr, 18, 1);
}

void clip_player_movement(envyronment *envyro, int *x, int *y) {
	int tx = (*x) >> 3;
	int ty = (*y) >> 3;
	int dx = (*x) & 0x07;
	int dy = (*y) & 0x07;
	tile_attr attr;

	get_tile_attr(envyro, tx, ty, &attr);

	if (!attr.movement) {
		*x = -1;
		return;
	}

	if (dx < 4) {
		if (!(attr.movement & BLK_MOVE_LEFT)) {
			dx++;
		}
	} else if (dx != 4) {
		if (!(attr.movement & BLK_MOVE_RIGHT)) {
			dx--;
		}
	}

	if (dy < 4) {
		if (!(attr.movement & BLK_MOVE_TOP)) {
			dy++;
		}
	} else if (dy != 4) {
		if (!(attr.movement & BLK_MOVE_BOTTOM)) {
			dy--;
		}
	}

	*x = (tx << 3) + dx;
	*y = (ty << 3) + dy;
}

void check_player_movement(envyronment *envyro) {
	unsigned char i;
	unsigned char *maptile;
	meter *mt1 = 0;
	meter *mt2 = envyro->meters;

	clip_player_movement(envyro, &(envyro->ply_x), &(envyro->ply_y));

	if (envyro->ply_x < 0) {
		envyro->ply_x = envyro->ply_last_x;
		envyro->ply_y = envyro->ply_last_y;
	}
	envyro->ply_last_x = envyro->ply_x;
	envyro->ply_last_y = envyro->ply_y;

	envyro->ply_blk_x = envyro->ply_x >> 3;
	envyro->ply_blk_y = envyro->ply_y >> 3;

	maptile = envyro->map + (envyro->ply_blk_y << 6) + (envyro->ply_blk_x << 1);
	envyro->curr_tile = *maptile;
	if (envyro->curr_tile != envyro->prev_tile) {
		switch (envyro->curr_tile) {
			case 32:
			case 33:
				mt1 = envyro->meters;
			break;

			case 34:
			case 35:
				mt1 = envyro->meters + 1;
			break;

			case 36:
			case 37:
				mt1 = envyro->meters + 2;
			break;
		}

		if (mt1 != 0) {
			for (i = 0, mt2 = envyro->meters; i != 3; i++, mt2++) {
				if (mt2 != mt1) {
					mt2->target_value += mt1->target_value;
				}
			}
			mt1->target_value = 0;
		}

		envyro->prev_tile = envyro->curr_tile;
	}
}

void decrease_energy(envyronment *envyro, int amount) {
	meter *max = envyro->meters;
	meter *mt = envyro->meters + 1;
	unsigned char i;

	for (i = 1; i != 3; i++, mt++) {
		if (mt->target_value > max->target_value) {
			max = mt;
		}
	}

	max->target_value -= amount;
	if (max->target_value < 0) {
		max->target_value = 0;
	}
}

void show_message(envyronment *envyro, unsigned int *msg) {
	envyro->msg_ptr = msg;
	envyro->msg_timer = 0x200;
}

void draw_status_bar(envyronment *envyro) {
	if (envyro->msg_timer) {
		envyro->msg_timer--;
		if (!envyro->msg_timer) {
			envyro->msg_ptr = msg_none;
		}
	}
	if (envyro->msg_ptr) {
		set_bkg_map(envyro->msg_ptr, 12, 22, 8, 1);
		envyro->msg_ptr = 0;
	}
}

void move_enemies(envyronment *envyro) {
	unsigned char i;
	unsigned char n;
	unsigned char x, y;
	unsigned char ply_x = envyro->ply_x;
	unsigned char ply_y = envyro->ply_y;
	enemy *enm = envyro->enemies;

	for (i = 0; i != 8; i++, enm++) {
		if (enm->active) {
			enm->x += enm->spd_x;
			enm->y += enm->spd_y;

			if (enm->x < enm->left) {
				enm->x = enm->left;
				enm->spd_x = -enm->spd_x;
			} else if (enm->x > enm->right) {
				enm->x = enm->right;
				enm->spd_x = -enm->spd_x;
			}

			if (enm->y < enm->top) {
				enm->y = enm->top;
				enm->spd_y = -enm->spd_y;
			} else if (enm->y > enm->bottom) {
				enm->y = enm->bottom;
				enm->spd_y = -enm->spd_y
			}

			x = enm->x >> 4;
			y = enm->y >> 4;

			if ((x > ply_x-3) && (x < ply_x + 3)) {
				if ((y > ply_y-3) && (y < ply_y + 3)) {
					enm->active = 0;
					enm->respawn = 0x400;
					decrease_energy(envyro, 250);
					show_message(envyro, msg_less_250);
				}
			}
		}
	}
}

void check_meters(envyronment *envyro) {
	unsigned char i;
	unsigned char over, allzero;
	meter *mt = envyro->meters;

	over = 0;
	allzero = 1;
	for (i = 0; i != 3; i++, mt++) {
		if (mt->value) {
			allzero = 0;

			if (mt->value > 999) {
				over++;
			}
		}
	}

	if (allzero) {
		show_message(envyro, msg_intruder);
		envyro->game_status = STATUS_LOST_LIFE;
	} else if (over > 1) {
		show_message(envyro, msg_overload);
		envyro->game_status = STATUS_STAGE_CLEAR;
	}
}

void draw_meters(envyronment *envyro) {
	unsigned char i, j;
	meter *mt = envyro->meters;
	unsigned int buf[5], *p;
	unsigned int n;

	for (i = 0; i != 3; i++, mt++) {
		if (mt->value != mt->prev_value) {
			if (mt->value > 999) {
				set_bkg_map(meter_error, mt->x, mt->y, 5, 1);
			} else {
				p = buf+4;
				*p = 0;
				p--;
				for (j = 3, n = mt->value; j != 0; n /= 10, p--, j--) {
					*p = 0x01 + (n % 10);
				}
				*p = 0;

				set_bkg_map(buf, mt->x, mt->y, 5, 1);
			}
			mt->prev_value = mt->value;
		}

		if (mt->value != mt->target_value) {
			if (mt->value < mt->target_value) {
				if (mt->target_value - mt->value > 50) {
					mt->value += 4;
				} else {
					mt->value++;
				}
			} else {
				if (mt->value - mt->target_value > 50) {
					mt->value -= 4;
				} else {
					mt->value--;
				}
			}
		}
	}
}

void draw_enemies(envyronment *envyro) {
	unsigned char i;
	unsigned char n;
	enemy *enm = envyro->enemies;

	for (i = 0; i != 8; i++, enm++) {
		if (enm->respawn) {
			enm->respawn--;
			if (!enm->respawn) {
				enm->active = 1;
			}
		}
		if (enm->active) {
			n = envyro->next_spr;
			envyro->next_spr++;

			set_sprite(n, (enm->x >> 4)-4, (enm->y >> 4)-4, ((envyro->ply_frame >> 2) & 0x07) + 64);
		}
	}
}

void set_sound_freq_max_volume(char channel, unsigned int freq) {
	set_sound_freq(channel, freq);
	set_sound_volume(channel, 0x0F);
}

void do_sound(envyronment *envyro) {
	unsigned char i;
	unsigned char n;
	meter *mt = envyro->meters;

	n = envyro->ply_frame & 0x03;

	if (!n) {
		set_sound_freq(0, 200+(rand(400)));
		set_sound_volume(0, 0x06);
	}

	if (n != 3) {
		mt += n;
		if (mt->value != mt->target_value) {
			set_sound_freq_max_volume(2, 200+(mt->value >> 1));
		} else {
			set_sound_volume(2, 0x00);
		}
	} else {
		set_sound_volume(2, 0x00);
	}
}

void sound_off() {
	unsigned char i;
	for (i = 0; i != 4; i++) {
		set_sound_volume(i, 0x00);
	}
}

char get_pal_red(char e) {
	return e & 0x03;
}

char get_pal_green(char e) {
	return (e >> 2) & 0x03;
}

char get_pal_blue(char e) {
	return (e >> 4) & 0x03;
}

char encode_pal(char red, char green, char blue) {
	return (((blue << 2) | green) << 2) | red;
}

void interpolate_pal_color(char color1, char color2, char amount) {
	return ((color1 * (0x04-amount)) + (color2 * amount)) >> 2;
}

void interpolate_pal(char *pal1, char *pal2, char *dest, char amount) {
	int i;
	char r, g, b;

	amount &= 0x03;
	for (i = 0; i != 16; i++, pal1++, pal2++, dest++) {
		r = interpolate_pal_color(get_pal_red(*pal1), get_pal_red(*pal2), amount);
		g = interpolate_pal_color(get_pal_green(*pal1), get_pal_green(*pal2), amount);
		b = interpolate_pal_color(get_pal_blue(*pal1), get_pal_blue(*pal2), amount);

		*dest = encode_pal(r, g, b);
	}
}

void level_end_effect() {
	int i, j;
	char pal[16];

	sound_off();
	for (i = 0; i != 0x80; i++) {
		if (i & 0x10) {
			*pal = (0x03 - ((i >> 2) & 0x03)) | (0x0C - (i & 0x0C));
		} else {
			*pal = ((i >> 2) & 0x03) | (i & 0x0C);
		}

		set_sound_freq_max_volume(0, 150-((i & 0x1F) << 2));

		wait_vblank_noint();
		load_palette(pal, 0, 1);
	}

	sound_off();
	for (i = 0; i != 0x10; i++) {
		interpolate_pal(pal1, pal_white, pal, i >> 2);
		wait_vblank_noint();
		load_palette(pal, 0, 16);
		load_palette(pal, 16, 16);
		set_sound_freq_max_volume(3, rand() & 0x0F);
	}

	load_palette(pal_white, 0, 16);
	load_palette(pal_white, 16, 16);
	for (i = 0; i != 0x10; i++) {
		wait_vblank_noint();
		set_sound_freq_max_volume(3, rand() & 0x0F);
	}

	sound_off();
}

void lost_life_effect() {
	int i, j;
	char pal[16];

	sound_off();
	for (i = 0; i != 0x80; i++) {
		if (i & 0x10) {
			*pal = 0x03 - ((i >> 2) & 0x03);
		} else {
			*pal = (i >> 2) & 0x03;
		}

		set_sound_freq_max_volume(0, 200+((i & 0x0F) << 2));

		wait_vblank_noint();
		load_palette(pal, 0, 1);
	}

	sound_off();
	for (i = 0; i != 0x10; i++) {
		interpolate_pal(pal1, pal_black, pal, i >> 2);
		wait_vblank_noint();
		load_palette(pal, 0, 16);
		load_palette(pal, 16, 16);
		set_sound_freq_max_volume(0, 200 + (i << 4));
	}

	load_palette(pal_black, 0, 16);
	load_palette(pal_black, 16, 16);
	for (i = 0x10; i != 0x20; i++) {
		wait_vblank_noint();
		set_sound_freq_max_volume(0, 200 + (i << 4));
	}

	sound_off();
}

void place_enemy(int x, int y, int width, int height, enemy *enm) {
	enm->x = x << 4;
	enm->y = y << 4;
	enm->spd_x = 0;
	enm->spd_y = 0;
	if (width) {
		enm->spd_x = 0x08;
	}
	if (height) {
		enm->spd_y = 0x08;
	}
	enm->top = enm->y;
	enm->left = enm->x;
	enm->bottom = enm->y + (height << 4);
	enm->right = enm->x + (width << 4);
	enm->active = 1;
}

void initialize_map(envyronment *envyro, unsigned char *map) {
	unsigned char i;
	unsigned char x, y;
	unsigned char *tile = map;
	unsigned char *attr = map+1;
	unsigned char tilenum;
	meter *mt;
	enemy *enm;

	for (y = 0; y != 28; y++) {
		for (x = 0; x != 32; x++, tile += 2, attr += 2) {
			tilenum = *tile;
			if ((tilenum != 0) && (tilenum < 4)) {
				mt = envyro->meters + (tilenum-1);
				mt->x = x;
				mt->y = y;
				mt->value = 100;
				mt->prev_value = 0;
				mt->target_value = 100;
			}
		}
	}

	enm = envyro->enemies;
	for (i = 0; i != 8; i++, enm++) {
		enm->active = 0;
		enm->respawn = 0;
	}

	// Place the enemies. Hardcoded, for now.
	enm = envyro->enemies;

/*	enm->x = 52 << 4;
	enm->y = 52 << 4;
	enm->spd_x = 0;
	enm->spd_y = 0x08;
	enm->top = enm->y;
	enm->left = enm->x;
	enm->bottom = enm->y + (44 << 4);
	enm->right = enm->x;
	enm->active = 1;
	enm++;

	enm->x = 104 << 4;
	enm->y = 52 << 4;
	enm->spd_x = 0x08;
	enm->spd_y = 0;
	enm->top = enm->y;
	enm->left = enm->x;
	enm->bottom = enm->y;
	enm->right = enm->x + (74 << 4);
	enm->active = 1;
	enm++;

	enm->x = 124 << 4;
	enm->y = 52 << 4;
	enm->spd_x = 0;
	enm->spd_y = 0x08;
	enm->top = enm->y;
	enm->left = enm->x;
	enm->bottom = enm->y + (52 << 4);
	enm->right = enm->x;
	enm->active = 1;
	enm++;*/

    place_enemy(52, 52, 0, 44, enm);
    enm++;
    place_enemy(104, 52, 74, 0, enm);
    enm++;
    place_enemy(124, 52, 0, 52, enm);
    enm++;
}

void load_main_tileset() {
	unsigned char buffer[4096];
	aplib_depack(circuit_tileset_apk, buffer);
	load_tiles(buffer, 0, 128, 4);
}

void main() {
	int joy;
	envyronment envyro;
	unsigned char map[32*2*32];

	for (;;) {
		envyro.game_status = STATUS_NONE;
		envyro.ply_x = 20;
		envyro.ply_y = 36;
		envyro.prev_tile = 0;

		set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN);
		load_palette(pal1, 0, 16);
		load_palette(pal1, 16, 16);
		load_main_tileset();

		aplib_depack(map1_apk, map);
		envyro->map = map;
		set_bkg_map(envyro->map, 0, 0, 32, 28);

		initialize_map(&envyro, envyro->map);

//		envyro.game_status = STATUS_LOST_LIFE; // *** DEBUG *** //

		// Level loop
		while (!envyro.game_status) {
			joy = read_joypad1();
			if (joy & JOY_UP) {
				envyro.ply_y--;
			}
			if (joy & JOY_DOWN) {
				envyro.ply_y++;
			}
			if (joy & JOY_LEFT) {
				envyro.ply_x--;
			}
			if (joy & JOY_RIGHT) {
				envyro.ply_x++;
			}

			check_player_movement(&envyro);
			move_enemies(&envyro);
			check_meters(&envyro)

			do_sound(&envyro);

			wait_vblank_noint();
			envyro.next_spr = 1;
			draw_status_bar(&envyro);
			draw_meters(&envyro);
			set_sprite(0, envyro.ply_x-4, envyro.ply_y-4, ((envyro.ply_frame >> 2) & 0x07) + 48);
			draw_enemies(&envyro);

			while (envyro->next_spr < 16) {
				set_sprite(envyro->next_spr, -16, -16, 0);
				envyro->next_spr++;
			}

			envyro.ply_frame++;
		}

		if (envyro.game_status == STATUS_LOST_LIFE) {
			lost_life_effect();
		} else if (envyro.game_status == STATUS_STAGE_CLEAR) {
			level_end_effect();
		}
	}
}

#asm
._circuit_tileset_apk
	BINARY	"circuit.apk"
._map1_apk
	BINARY	"map1.apk"
#endasm
