#ifndef _RDT_ITFC_H_
#define _RDT_ITFC_H_

#define SCREEN_MODE_TEXT 0
#define SCREEN_MODE_SPLIT 1
#define SCREEN_MODE_IMAGE 2

extern void rdt_interface_init(cheese_envyro *envyro);
extern void rdt_interface_runprog(cheese_envyro *envyro, char *name);
extern void rdt_interface_setscreenmode(cheese_envyro *envyro, int mode);
extern void rdt_interface_setwrap(cheese_envyro *envyro, int mode);
extern void rdt_interface_setautopause(cheese_envyro *envyro, int mode);
extern void rdt_interface_setautoscroll(cheese_envyro *envyro, int mode);
extern int rdt_interface_clrimg(cheese_envyro *envyro);
extern void rdt_interface_setimg(cheese_envyro *envyro, int imgnum);
extern int rdt_interface_clrtxt(cheese_envyro *envyro);
extern void rdt_interface_gotoxy(cheese_envyro *envyro, int x, int y);
extern int rdt_interface_getx(cheese_envyro *envyro);
extern int rdt_interface_gety(cheese_envyro *envyro);
extern int rdt_interface_getw(cheese_envyro *envyro);
extern int rdt_interface_geth(cheese_envyro *envyro);
extern void rdt_interface_outputchar(cheese_envyro *envyro, char c);
extern char rdt_interface_inputchar(cheese_envyro *envyro);
extern int rdt_interface_inputint(cheese_envyro *envyro);
extern int rdt_interface_inputcursor(cheese_envyro *envyro);

#endif /*_RDT_ITFC_H_*/
