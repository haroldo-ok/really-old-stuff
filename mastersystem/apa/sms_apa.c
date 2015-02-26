#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sms.h>
#include "apa.h"
#include "sincos.h"
#include "cube.h"

#define Sar(a,b) (((a)<0) ? -(-(a)>>(b)) : ((a)>>(b))) // shift ar. right
#define Mul(a,b) ((a)*(b))

unsigned char polydata[] = {3,67,33,94,34,94,37,240,3,67,33,94,37,90,41,240,3,67,33,90,41,82,43,240,3,67,33,82,43,71,44,240,3,67,33,59,43,71,44,240,3,67,33,49,40,59,43,240,3,67,33,42,37,49,40,240,3,40,32,67,33,42,37,240,3,42,29,40,32,67,33,240,3,47,26,42,29,67,33,240,3,55,24,47,26,67,33,240,3,64,24,74,25,67,33,240,3,74,25,83,27,67,33,240,3,83,27,89,30,67,33,240,3,89,30,67,33,94,34,240,0,94,37,90,41,88,93,240,1,90,41,82,43,85,98,240,3,82,43,71,44,77,103,240,5,59,43,71,44,67,104,240,6,49,40,59,43,57,103,240,6,42,37,49,40,48,100,240,4,40,32,42,37,42,94,240,1,90,41,88,93,85,98,240,2,82,43,85,98,77,103,240,4,71,44,77,103,67,104,240,5,59,43,57,103,67,104,240,6,49,40,48,100,57,103,240,5,42,37,42,94,48,100,240,3,40,32,40,88,42,94,240,254,255};

extern unsigned char pal_terrain[];
extern unsigned char texture_bin[];

int adjust_y(int y) {
	return (y >> 1) + (y >> 3);
}

void test_apa() {
    int i;
    unsigned char charset[16*10*32];
    unsigned char *coltable[16];
    unsigned int map[16*10];
    apa_canvas canvas;

    unsigned char *o, *c;
    int color, count;
    int x1, y1, x2, y2, x3, y3;

	apa_init_canvas(&canvas, 16, 10, 256, charset, coltable, map);
	apa_show_canvas(&canvas, 2, 2);

	o = polydata;
	c = NULL;
	while (*o != 255) {
		if (*o == 240) {
			color = *c;
			c++;

			/*
			pt = points;
			count = 0;
			while (c != o) {
				pt->x = *c;
				c++;
				pt->y = *c;
				c++;

				pt++;
				count++;
			}

			drawPolygone(points, count, color, 0);
			*/

			x1 = *c; c++;
			y1 = adjust_y(*c); c++;
			x2 = *c; c++;
			y2 = adjust_y(*c); c++;
			x3 = *c; c++;
			y3 = adjust_y(*c); c++;

			apa_draw_poly(&canvas, x1, y1, x2, y2, x3, y3, x3, y3, color);
			apa_refresh_canvas(&canvas);

			c = NULL;
		} else {
			if (!c) {
				c = o;
			}
		}
		o++;
	}

/*    for (i = 0; i != 80; i++) {
    	apa_put_pixel(&canvas, i, i, i & 0x0F);
    	if (!(i & 0x07)) {
			apa_refresh_canvas(&canvas);
		}
	}

	for (i = 0; i != 30; i++) {
		apa_vert_line(&canvas, i, 35-i, (i * 2)+1, 6);
	}
	apa_refresh_canvas(&canvas);

	for (i = 0; i != 40; i++) {
		apa_hor_line(&canvas, 40-i, i, (i * 2)+1, 5);
	}
	apa_refresh_canvas(&canvas);

	apa_draw_circle(&canvas, 40, 40, 25, 4);
	apa_refresh_canvas(&canvas);

	apa_draw_line(&canvas, 0, 79, 127, 0, 3);
	apa_refresh_canvas(&canvas);

	apa_draw_poly(&canvas, 10, 10, 50, 15, 40, 60, 5, 17, 1);
	apa_draw_poly(&canvas, 10, 10, 30, 5, 50, 60, 15, 40, 2);
	apa_refresh_canvas(&canvas);

	for (i = 0; i != 20; i++) {
		apa_textured_hor_line(&canvas, 20-i, i+50, (i * 2)+1, texture_bin);
	}
	apa_refresh_canvas(&canvas);

	apa_draw_textured_poly(&canvas, 35, 20, 65, 15, 120, 50, 25, 40, texture_bin);
	apa_refresh_canvas(&canvas);

	for (i = 0; i != 140; i++) {
		wait_vblank_noint();
	}*/
}

/*******************************************************
 * Rotating cube, based on an old demo for the GBC.
 * (Couldn't find the original author's name)
 */

void RotateAndProject(int cx, int cy, int cz, int sx, int sy, int sz, int dist, Point *projected)
{
  int v;

  for (v=0; v<VERTICES; v++) {
	int x1,y1,z1;
	int xx,yy;
	int zz;

    x1 = Mul(cy, vertices(v, 0)) - Mul(sy, vertices(v, 2));
    x1 = Sar(x1,7);
    z1 = Mul(sy, vertices(v, 0)) + Mul(cy, vertices(v, 2));
    z1 = Sar(z1,7);
    xx = Mul(cz, x1            ) + Mul(sz, vertices(v, 1));
    xx = Sar(xx,7);
    y1 = Mul(cz, vertices(v, 1)) - Mul(sz, x1            );
	y1 = Sar(y1,7);
    yy = Mul(sx, z1            ) + Mul(cx, y1            );
    yy = Sar(yy,7);
    zz = Mul(cx, z1            ) - Mul(sx, y1            );
    zz = Sar(zz,7) + 256;
    zz += dist;

    xx = Sar((xx * zz), 8) + 64;
    yy = Sar((yy * zz), 8) + 40;
    projected[v].coord[0] = xx;
    projected[v].coord[1] = yy;
  }
}

void DrawLines(apa_canvas *canvas, Point *projected)
{
  int l;
  for (l=0; l<LINES-0; l++) {
  	int x1 = projected[lines(l,0)].coord[0];
  	int y1 = projected[lines(l,0)].coord[1];
  	int x2 = projected[lines(l,1)].coord[0];
  	int y2 = projected[lines(l,1)].coord[1];
  	if (y2<y1) { // swap points
  		int t;
  		t = x1; x1 = x2; x2 = t;
  		t = y1; y1 = y2; y2 = t;
  	}
    apa_draw_line(canvas,x1,y1,x2,y2,1);
  }
}

void DrawFaces(apa_canvas *canvas, Point *projected)
{
  int l;
  for (l=0; l<FACES; l++) {
  	int x1 = projected[faces(l,0)].coord[0];
  	int y1 = projected[faces(l,0)].coord[1];
  	int x2 = projected[faces(l,1)].coord[0];
  	int y2 = projected[faces(l,1)].coord[1];
  	int x3 = projected[faces(l,2)].coord[0];
  	int y3 = projected[faces(l,2)].coord[1];
  	int x4 = projected[faces(l,3)].coord[0];
  	int y4 = projected[faces(l,3)].coord[1];
    apa_draw_poly(canvas, x1, y1, x2, y2, x3, y3, x4, y4, l);
  }
}

void rot_cube() {
    unsigned char charset[16*10*32];
    unsigned char *coltable[16];
    unsigned int map[16*10];
    apa_canvas canvas;

    Point projected[VERTICES];
    int cx,cy,cz,sx,sy,sz;
    int dist = -128;
  	int rx=0, ry=0, rz=0;
  	int filled = 0;
  	int joy;

	load_tiles(standard_font, 0, 255, 1);

	apa_init_canvas(&canvas, 16, 10, 256, charset, coltable, map);
	apa_show_canvas(&canvas, 2, 2);

	while (1) {
  		joy = read_joypad1();
	  	if (joy & JOY_UP) rx-=3;
	  	if (joy & JOY_DOWN) rx+=3;
	  	if (joy & JOY_LEFT) ry+=3;
	  	if (joy & JOY_RIGHT) ry-=3;
	  	if ((joy & JOY_FIREA) && (joy & JOY_FIREB)) {
	  		filled = !filled;
		} else if (joy & JOY_FIREA)  {
			dist-=3;
	  	} else if (joy & JOY_FIREB) {
	  		dist+=3;
		}

	  	ry++;

	    cx = ctab[rx]; cy = ctab[ry]; cz = ctab[rz];
	    sx = stab[rx]; sy = stab[ry]; sz = stab[rz];
	    RotateAndProject(cx, cy, cz, sx, sy, sz, dist, projected);

		if (!filled) {
	    	DrawLines(&canvas, projected);
		} else {
	    	DrawFaces(&canvas, projected);
		}

		wait_vblank_noint();
		apa_refresh_canvas(&canvas);
		apa_clear_canvas(&canvas);
  	}
}

/*******************************************************/

void main() {
	load_palette(pal_terrain, 0, 16);
	load_palette(pal_terrain, 16, 16);

	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_CHANGE | VDP_REG_FLAGS0_LOCKRIGHT);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN /*| VDP_REG_FLAGS1_8x16*/);

    for (;;) {
		test_apa();
		//rot_cube();
    }
}

#asm
._pal_terrain
	BINARY	"terrain2.pal"
._texture_bin
	BINARY	"texture.bin"
#endasm
