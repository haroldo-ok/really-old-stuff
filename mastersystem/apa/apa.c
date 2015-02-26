#include <string.h>
#include <stdlib.h>
#include <sms.h>
#include <apa.h>

/**
 * Sega Master System APA Library
 * by Haroldo O. Pinheiro
 */

unsigned char apa_bit_mask[] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01};
unsigned char apa_hline_bit_mask[] = {0xFF, 0x7F, 0x3F, 0x1F, 0x0F, 0x07, 0x03, 0x01};

void apa_init_charset(int w, int h, unsigned char *charset, unsigned char **coltable) {
	int i;
	int colsize = (h << 5);
	unsigned char **p, *b;

	for (i = 0, p = coltable, b = charset; i != w; i++, p++, b += colsize) {
		*p = b;
		memset(b, 0, colsize);
	}
}

void apa_init_map(int w, int h, unsigned int basetile, unsigned int *map) {
	int i, j;
	unsigned int tile;
	unsigned int *p, *colp;

	tile = basetile;
	for (i = 0, colp = map; i != w; i++, colp++) {
		for (j = 0, p = colp; j != h; j++, p += w) {
			*p = tile;
			tile++;
		}
	}
}

extern void apa_init_canvas(apa_canvas *canvas, int w, int h, unsigned int basetile, unsigned char *charset, unsigned char **coltable, unsigned int *map) {
	canvas->charset = charset;
	canvas->coltable = coltable;
	canvas->map = map;

	canvas->basetile = basetile;
	canvas->char_w = w;
	canvas->char_h = h;
	canvas->char_count = w * h;
	canvas->pixel_w = w << 3;
	canvas->pixel_h = h << 3;

	apa_init_charset(canvas->char_w, canvas->char_h, canvas->charset, canvas->coltable);
	apa_init_map(canvas->char_w, canvas->char_h, canvas->basetile, canvas->map);
}

extern void apa_show_canvas(apa_canvas *canvas, int x, int y) {
	set_bkg_map(canvas->map, x, y, canvas->char_w, canvas->char_h);
	apa_refresh_canvas(canvas);
}

extern void apa_refresh_canvas(apa_canvas *canvas) {
	load_tiles(canvas->charset, canvas->basetile, canvas->char_count, 4);
}

extern void apa_clear_canvas(apa_canvas *canvas) {
	memset(canvas->charset, 0, canvas->char_count << 5);
}

void apply_octet(unsigned char *octet, unsigned char color) {
	int i;

	for (i = 4; i; i--, color >>= 1, octet++) {
		if (color & 0x01) {
			*octet = 0xFF;
		} else {
			*octet = 0;
		}
	}
}

void apply_octet_mask(unsigned char *octet, unsigned char mask, unsigned char color) {
	int i;

	for (i = 4; i; i--, color >>= 1, octet++) {
		if (color & 0x01) {
			*octet |= mask;
		} else {
			*octet &= ~mask;
		}
	}
}

void apply_octet_texture(unsigned char *octet, unsigned char *tex) {
	int i;

	memcpy(octet, tex, 4);
/*	for (i = 4; i; i--, octet++, tex++) {
		*octet = *tex;
	}*/
}

void apply_octet_mask_texture(unsigned char *octet, unsigned char mask, unsigned char *tex) {
	int i;

	for (i = 4; i; i--, octet++, tex++) {
		*octet &= ~mask;
		*octet |= (*tex & mask);
	}
}

extern void apa_put_pixel(apa_canvas *canvas, int x, int y, int color) {
	int xo = x & 0x07;
	int xc = x >> 3;
	int yo = y << 2;
	unsigned char *col = canvas->coltable[xc];
	unsigned char *octet = col + yo;
	unsigned char mask = apa_bit_mask[xo];

	apply_octet_mask(octet, mask, color);
}

extern void apa_hor_line(apa_canvas *canvas, int x, int y, int w, unsigned char color) {
	int x2 = x + w - 1;
	int xo = x & 0x07;
	int xc = x >> 3;
	int xo2 = x2 & 0x07;
	int xc2 = x2 >> 3;
	int yo = y << 2;
	unsigned char **coltable = canvas->coltable;
	unsigned char mask;
	unsigned char *col = coltable[xc];
	unsigned char *octet = col + yo;
	int i;

	if (xc == xc2) {
		mask = apa_hline_bit_mask[xo] & ~apa_hline_bit_mask[xo2];
		apply_octet_mask(octet, mask, color);
	} else {
		mask = apa_hline_bit_mask[xo];
		apply_octet_mask(octet, mask, color);

		for (i = xc + 1; i != xc2; i++) {
			col = coltable[i];
			octet = col + yo;
			apply_octet(octet, color);
		}

		col = coltable[xc2];
		octet = col + yo;
		mask = ~apa_hline_bit_mask[xo2];
		apply_octet_mask(octet, mask, color);
	}

}

extern void apa_vert_line(apa_canvas *canvas, int x, int y, int h, unsigned char color) {
	int xo = x & 0x07;
	int xc = x >> 3;
	int yo = y << 2;
	unsigned char *col = canvas->coltable[xc];
	unsigned char *octet = col + yo;
	unsigned char mask = apa_bit_mask[xo];
	unsigned char colormask;
	int i, j;

	for (i = h; i; i--) {
		colormask = 1;
		for (j = 4; j; j--) {
			if (color & colormask) {
				*octet |= mask;
			} else {
				*octet &= ~mask;
			}
			colormask <<= 1;
			octet++;
		}
	}
}

/**
 * Line drawing routine.
 * Original code by Brian Dessent
 * Adapted to Sega Master System by Haroldo O. Pinheiro
 */
extern void apa_draw_line(apa_canvas *canvas, int x, int y, int x2, int y2, unsigned char c) {
      int i, steep = 0, sx, sy, dx, dy, e, dx2, dy2;

      dx = abs(x2 - x);
      sx = ((x2 - x) > 0) ? 1 : -1;
      dy = abs(y2 - y);
      sy = ((y2 - y) > 0) ? 1 : -1;

      if(dy > dx)
      {
            steep =  x;   x =  y;   y = steep;  /* swap  x and  y */
            steep = dx;  dx = dy;  dy = steep;  /* swap dx and dy */
            steep = sx;  sx = sy;  sy = steep;  /* swap sx and sy */
            steep = 1;
      }

	  dx2 = dx << 1;
	  dy2 = dy << 1;
      e = dy2 - dx;
      for(i = 0; i < dx; i++)
      {
            if(steep)
                  apa_put_pixel(canvas, y, x, c);
            else  apa_put_pixel(canvas, x, y, c);
            while(e >= 0)
            {
                  y += sy;
                  e -= dx2;
            }
            x += sx;
            e += dy2;
      }
      apa_put_pixel(canvas, x2, y2, c);
}

/**
 * Circle drawing routine.
 * Original code by Brian Dessent
 * Adapted to the Sega Master System by Haroldo O. Pinheiro
 */
extern void apa_draw_circle(apa_canvas *canvas, int xc, int yc, int r, unsigned char c) {
      int x = 0, d = 2 * (1 - r), w = 2; // * APA_SCREEN_WIDTH / APA_SCREEN_HEIGHT;

      while(r >= 0)
      {
            apa_put_pixel(canvas, xc + x, yc + r, c);
            apa_put_pixel(canvas, xc + x, yc - r, c);
            apa_put_pixel(canvas, xc - x, yc + r, c);
            apa_put_pixel(canvas, xc - x, yc - r, c);
            if (d + r > 0)
                  d -= (w * --r) - 1;
            if (x > d)
                  d += (2 * ++x) + 1;
      }
}

extern void apa_textured_hor_line(apa_canvas *canvas, int x, int y, int w, unsigned char *texture) {
	int x2 = x + w - 1;
	int xo = x & 0x07;
	int xc = x >> 3;
	int xo2 = x2 & 0x07;
	int xc2 = x2 >> 3;
	int yo = y << 2;
	unsigned char **coltable = canvas->coltable;
	unsigned char mask;
	unsigned char *col = coltable[xc];
	unsigned char *octet = col + yo;
	unsigned char *tex = texture + (yo & 0x1C);
	int i;

	if (xc == xc2) {
		mask = apa_hline_bit_mask[xo] & ~apa_hline_bit_mask[xo2];
		apply_octet_mask_texture(octet, mask, tex);
	} else {
		mask = apa_hline_bit_mask[xo];
		apply_octet_mask_texture(octet, mask, tex);

		for (i = xc + 1; i != xc2; i++) {
			col = coltable[i];
			octet = col + yo;
			apply_octet_texture(octet, tex);
		}

		col = coltable[xc2];
		octet = col + yo;
		mask = ~apa_hline_bit_mask[xo2];
		apply_octet_mask_texture(octet, mask, tex);
}

}

/* Auxiliary function for polygon drawing. By Haroldo O. Pinheiro */
void sweep_poly_pixel(int x, int y, int *poly_buffer) {
	register int *p;

/*	if((y < 0) || (y > APA_SCREEN_WIDTH-1)) {
		return;
	}*/

	p = poly_buffer+(y << 1);

	if(x < *p) {
		*p = x;
	}

	p++;

	if(x > *p) {
		*p = x;
	}
}

/* Auxiliary function for polygon drawing. Modified version of draw_line() */
void sweep_poly_line(int x, int y, int x2, int y2, int *poly_buffer) {
      int i, e, steep = 0, sx, sy, dx, dy, dx2, dy2;
	  int *p;

      dx = abs(x2 - x);
      sx = ((x2 - x) > 0) ? 1 : -1;
      dy = abs(y2 - y);
      sy = ((y2 - y) > 0) ? 1 : -1;

      if(dy > dx)
      {
            steep =  x;   x =  y;   y = steep;  /* swap  x and  y */
            steep = dx;  dx = dy;  dy = steep;  /* swap dx and dy */
            steep = sx;  sx = sy;  sy = steep;  /* swap sx and sy */
            steep = 1;
      }

	  dx2 = dx << 1;
      dy2 = dy << 1;
      e = dy2 - dx;
      for(i = 0; i < dx; i++)
      {
            if(steep) {
				sweep_poly_pixel(y, x, poly_buffer);
			}
            else {
				sweep_poly_pixel(x, y, poly_buffer);
			}
            while(e >= 0)
            {
                  y += sy;
                  e -= dx2;
            }
            x += sx;
            e += dy2;
      }

      sweep_poly_pixel(x2, y2, poly_buffer);
}

/* Polygon drawing routine. By Haroldo O. Pinheiro */
extern void apa_draw_poly(apa_canvas *canvas, int X1, int Y1, int X2, int Y2, int X3, int Y3, int X4, int Y4, unsigned char color) {
	int miny;
	int maxy;
	int i;
	int *p;
	int left, right;
	int poly_buffer[192*2];

	miny = Y1;
	maxy = Y1;

	if(Y2 < miny) miny = Y2;
	if(Y2 > maxy) maxy = Y2;
	if(Y3 < miny) miny = Y3;
	if(Y3 > maxy) maxy = Y3;
/*	if(Y4 < miny) miny = Y4;
	if(Y4 > maxy) maxy = Y4;*/

	if((maxy < 0) || (miny > canvas->pixel_h-1)) {
		return;
	}

	if(miny < 0) {
		miny = 0;
	}

	if(maxy > canvas->pixel_h-1) {
		maxy = canvas->pixel_h-1;
	}

	p = poly_buffer+(miny << 1);
	maxy++;
	for(i = miny; i != maxy; i++) {
		*p = canvas->pixel_w-1;
		p++;
		*p = 0;
		p++;
	}

	sweep_poly_line(X1, Y1, X2, Y2, poly_buffer);
	sweep_poly_line(X2, Y2, X3, Y3, poly_buffer);
	sweep_poly_line(X3, Y3, X1, Y1, poly_buffer);
//	sweep_poly_line(X3, Y3, X4, Y4, poly_buffer);
//	sweep_poly_line(X4, Y4, X1, Y1, poly_buffer);

	p = poly_buffer+(miny << 1);
	for(i = miny; i != maxy; i++) {
		left = *p;
		p++;
		right = *p;
		p++;

		apa_hor_line(canvas, left, i, right-left+1, color);
	}
}

/* Textured polygon drawing routine. By Haroldo O. Pinheiro */
extern void apa_draw_textured_poly(apa_canvas *canvas, int X1, int Y1, int X2, int Y2, int X3, int Y3, int X4, int Y4, unsigned char *texture) {
	int miny;
	int maxy;
	int i;
	int *p;
	int left, right;
	int poly_buffer[192*2];

	miny = Y1;
	maxy = Y1;

	if(Y2 < miny) miny = Y2;
	if(Y2 > maxy) maxy = Y2;
	if(Y3 < miny) miny = Y3;
	if(Y3 > maxy) maxy = Y3;
	if(Y4 < miny) miny = Y4;
	if(Y4 > maxy) maxy = Y4;

	if((maxy < 0) || (miny > canvas->pixel_h-1)) {
		return;
	}

	if(miny < 0) {
		miny = 0;
	}

	if(maxy > canvas->pixel_h-1) {
		maxy = canvas->pixel_h-1;
	}

	p = poly_buffer+(miny << 1);
	maxy++;
	for(i = miny; i != maxy; i++) {
		*p = canvas->pixel_w-1;
		p++;
		*p = 0;
		p++;
	}

	sweep_poly_line(X1, Y1, X2, Y2, poly_buffer);
	sweep_poly_line(X2, Y2, X3, Y3, poly_buffer);
	sweep_poly_line(X3, Y3, X4, Y4, poly_buffer);
	sweep_poly_line(X4, Y4, X1, Y1, poly_buffer);

	p = poly_buffer+(miny << 1);
	for(i = miny; i != maxy; i++) {
		left = *p;
		p++;
		right = *p;
		p++;

		apa_textured_hor_line(canvas, left, i, right-left+1, texture);
	}
}
