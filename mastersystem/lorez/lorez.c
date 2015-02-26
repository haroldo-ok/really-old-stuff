#include <stdlib.h>
#include <string.h>
#include <sms.h>

unsigned char pal1[] = {0x00, 0x02, 0x08, 0x0A, 0x20, 0x22, 0x28, 0x2A,
      				    0x15, 0x17, 0x1D, 0x1F, 0x35, 0x37, 0x3D, 0x3F};

void make_tile(int code) {
	char buffer[16];
	char *p = buffer;
	char supermask, mask, submask;
	int i, j, k;

	supermask = code;
	for (i = 0; i != 2; i++) {
		for (j = 0; j != 4; j++) {
			mask = supermask;
			for (k = 0; k != 2; k++) {
				submask = 0;

				if (mask & 0x01) {
					submask |= 0xF0;
				}

				if (mask & 0x04) {
					submask |= 0x0F;
				}

				*p = submask;
				p++;

				mask >>= 1;
			}
		}
		supermask >>= 4;
	}

	load_tiles(buffer, code, 1, 2);
}

void load_main_tileset() {
	int i;

	for (i = 0; i != 256; i++) {
		make_tile(i);
	}
}

void main() {
	int i;

	load_palette(pal1, 0, 16);
	load_palette(pal1, 16, 16);
	load_main_tileset();

	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_CHANGE | VDP_REG_FLAGS0_LHS);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN | VDP_REG_FLAGS1_8x16);
	set_vdp_reg(0x86, 0x04); // Use the second tileset for the sprites

	for (;;) {
	}
}
