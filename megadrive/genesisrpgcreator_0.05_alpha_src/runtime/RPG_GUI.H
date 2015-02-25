/* RPG GUI routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _RPG_GUI_H
#define _RPG_GUI_H

#define GUI_FNT_BKG 1
#define GUI_FNT_FRG 15
#define GUI_FNT_ATR 0xE0U
#define GUI_TIL_BASE 248
#define GUI_TIL_CNT 8
#define GUI_FRM_TOPLEFT GUI_TIL_BASE
#define GUI_FRM_TOPRIGHT (GUI_TIL_BASE+1)
#define GUI_FRM_BOTTOMLEFT (GUI_TIL_BASE+2)
#define GUI_FRM_BOTTOMRIGHT (GUI_TIL_BASE+3)
#define GUI_FRM_TOP (GUI_TIL_BASE+4)
#define GUI_FRM_BOTTOM (GUI_TIL_BASE+5)
#define GUI_FRM_LEFT (GUI_TIL_BASE+6)
#define GUI_FRM_RIGHT (GUI_TIL_BASE+7)
#define GUI_FRM_FILLER 32
#define GUI_FRM_MORE 31
#define GUI_FRM_CURSOR 16
#define GUI_FRM_ATR BUILD_ATTR(3, 1, 0, 0)

void gui_init();
void gui_clear();
void gui_draw_frame(x, y, w, h);
void gui_pager(x, y, w, h, text);
uint gui_menu(x, y, minw, maxw, minh, maxh, options, count, albottom);

#endif /* _RPG_GUI_H */
