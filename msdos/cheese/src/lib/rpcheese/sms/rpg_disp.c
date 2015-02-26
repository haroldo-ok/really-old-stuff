#include <stdio.h>
#include "rpg_conf.h"
#include "rpg_defs.h"

unsigned char pal1[] = {0x00, 0xFF, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F};

rpg_display_init(rpg_display_data *data) {
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN);
	load_tiles(standard_font, 0, 255, 1);
	load_palette(pal1, 0, 16);
	load_palette(pal1, 16, 16);
	gotoxy(1, 1);
	puts("Teste");
}

rpg_display_map(rpg_display_data *data, rpg_map *map) {
    UWORD buffer[32];
    int i, j;
    char *p;
    UWORD *b;

    for (i = 0; i != map->height; i++) {
        p = map->line_ptrs[i];
        for (j = 0, p = map->line_ptrs[i], b = buffer; j != map->width; j++, p++, b++) {
            *b = *p;
        }
        set_bkg_map(buffer, 0, i, map->width, 1);
    }
}
