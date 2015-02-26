#ifndef _APA_H_
#define _APA_H_

typedef struct _apa_canvas {
	unsigned char *charset;
	unsigned char **coltable;
	unsigned int *map;
	unsigned int basetile;
	unsigned int char_w;
	unsigned int char_h;
	unsigned int char_count;
	unsigned int pixel_w;
	unsigned int pixel_h;
} apa_canvas;

extern void apa_init_canvas(apa_canvas *canvas, int w, int h, unsigned int basetile, unsigned char *charset, unsigned char **coltable, unsigned int *map);
extern void apa_show_canvas(apa_canvas *canvas, int x, int y);
extern void apa_refresh_canvas(apa_canvas *canvas);
extern void apa_clear_canvas(apa_canvas *canvas);

extern void apa_put_pixel(apa_canvas *canvas, int x, int y, int color);
extern void apa_hor_line(apa_canvas *canvas, int x, int y, int w, unsigned char color);
extern void apa_vert_line(apa_canvas *canvas, int x, int y, int h, unsigned char color);
extern void apa_draw_line(apa_canvas *canvas, int x, int y, int x2, int y2, unsigned char c);
extern void apa_draw_circle(apa_canvas *canvas, int xc, int yc, int r, unsigned char c);
extern void apa_textured_hor_line(apa_canvas *canvas, int x, int y, int w, unsigned char *texture);
extern void apa_draw_poly(apa_canvas *canvas, int X1, int Y1, int X2, int Y2, int X3, int Y3, int X4, int Y4, unsigned char color);
extern void apa_draw_textured_poly(apa_canvas *canvas, int X1, int Y1, int X2, int Y2, int X3, int Y3, int X4, int Y4, unsigned char *texture);

#endif /* _APA_H_ */
