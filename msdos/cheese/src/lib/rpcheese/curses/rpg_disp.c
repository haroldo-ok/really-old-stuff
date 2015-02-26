#include <curses.h>
#include "rpg_conf.h"
#include "rpg_defs.h"

rpg_display_init(rpg_display_data *data) {
	initscr();
	start_color();	
	noecho();
	clear();
	refresh();
	
	data->mapwin = newwin(LINES-7, COLS, 0, 0);
	if (data->mapwin == NULL) {
        printf("error!.............................."); 
    }
	data->textwin = newwin(6, COLS, LINES-6, 0);
    
	init_pair(1, COLOR_WHITE, COLOR_BLACK);
	init_pair(2, COLOR_WHITE, COLOR_BLUE);
	
	wbkgd(data->mapwin, COLOR_PAIR(1));
	werase(data->mapwin);
	wrefresh(data->mapwin);
	
	wbkgd(data->textwin, COLOR_PAIR(2));
	werase(data->textwin);
	wrefresh(data->textwin);
}

rpg_display_map(rpg_display_data *data, rpg_map *map) {
    int i, j;
    char *p;

	werase(data->mapwin);
    for (i = 0; i != map->height; i++) { 
        wmove(data->mapwin, i, 0);       
        for (j = 0, p = map->line_ptrs[i]; (*p != 0x0A) && (*p != 0x0D) && (j != map->width); j++, p++) {
            waddch(data->mapwin, *p);
        }
    }
    wrefresh(data->mapwin);
}
