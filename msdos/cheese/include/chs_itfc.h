#ifndef _CHS_ITFC_H_
#define _CHS_ITFC_H_

#define SCREEN_MODE_TEXT 0
#define SCREEN_MODE_SPLIT 1
#define SCREEN_MODE_IMAGE 2

extern void chs_interface_init(cheese_envyro *envyro);
extern void chs_interface_setscreenmode(cheese_envyro *envyro, int mode);
extern void chs_interface_setwrap(cheese_envyro *envyro, int mode);
extern void chs_interface_setautopause(cheese_envyro *envyro, int mode);
extern void chs_interface_setautoscroll(cheese_envyro *envyro, int mode);
extern int chs_interface_clrimg(cheese_envyro *envyro);
extern void chs_interface_setimg(cheese_envyro *envyro, int imgnum);
extern int chs_interface_clrtxt(cheese_envyro *envyro);
extern void chs_interface_gotoxy(cheese_envyro *envyro, int x, int y);
extern int chs_interface_getx(cheese_envyro *envyro);
extern int chs_interface_gety(cheese_envyro *envyro);
extern int chs_interface_getw(cheese_envyro *envyro);
extern int chs_interface_geth(cheese_envyro *envyro);
extern void chs_interface_outputchar(cheese_envyro *envyro, char c);
extern char chs_interface_inputchar(cheese_envyro *envyro);
extern int chs_interface_inputint(cheese_envyro *envyro);
extern int chs_interface_inputcursor(cheese_envyro *envyro);

#endif /*_CHS_ITFC_H_*/
