#include "genesis.h"

#include "tranceS.h"
#include "vangelisS.h"

#include "z80.h"
#include "rsc_s.h"

#define USE_FRAMEBUFFER

#define WORK_W      BITMAP_WIDTH
#define WORK_H      BITMAP_HEIGHT
//#define WORK_W      24
//#define WORK_H      16
#define MAX_PARTIC  256
#define TAIL_LEN    6

const unsigned char polydata[] = {3,67,33,94,34,94,37,240,3,67,33,94,37,90,41,240,3,67,33,90,41,82,43,240,3,67,33,82,43,71,44,240,3,67,33,59,43,71,44,240,3,67,33,49,40,59,43,240,3,67,33,42,37,49,40,240,3,40,32,67,33,42,37,240,3,42,29,40,32,67,33,240,3,47,26,42,29,67,33,240,3,55,24,47,26,67,33,240,3,64,24,74,25,67,33,240,3,74,25,83,27,67,33,240,3,83,27,89,30,67,33,240,3,89,30,67,33,94,34,240,0,94,37,90,41,88,93,240,1,90,41,82,43,85,98,240,3,82,43,71,44,77,103,240,5,59,43,71,44,67,104,240,6,49,40,59,43,57,103,240,6,42,37,49,40,48,100,240,4,40,32,42,37,42,94,240,1,90,41,88,93,85,98,240,2,82,43,85,98,77,103,240,4,71,44,77,103,67,104,240,5,59,43,57,103,67,104,240,6,49,40,48,100,57,103,240,5,42,37,42,94,48,100,240,3,40,32,40,88,42,94,240,254,255};
vect2D_s16 points[16];

int main()
{

    VDP_setHInterrupt(0);
    VDP_setHilightShadow(0);

    setBitmapMode(WORK_W, WORK_H);

    /* Do main job here */
    while(1) {
        int i;
        unsigned char *o, *c;
        int color, count;
        vect2D_s16 *pt;

        o = polydata;
        c = NULL;
        while (*o != 255) {
            if (*o == 240) {
                color = *c;
                c++;

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

                c = NULL;
            } else {
                if (!c) {
                    c = o;
                }
            }
            o++;
        }

/*
        points[0].x = 84;
        points[0].y = 33;
        points[1].x = 117;
        points[1].y = 34;
        points[2].x = 118;
        points[2].y = 37;

        drawPolygone(points, 3, 1, 0);
        /*
        BITMAP_SETPIXEL(10, 10, 15);
        while (*o != 254) {
            if (*o > 239) {
                BITMAP_SETPIXEL(1, 1, 15);
                if (cmd) {
                    drawPolygone(points, 3, 15, 0);
                    blitBitmap(0, 0, WORK_W, WORK_H);
                }
                cmd = *o;
                o++;

                pt = points;
            } else {
                pt->x = (*o) << 1;
                o++;
                pt->y = *o;
                o++;

                pt++;
            }
        }
/*        if (cmd && (cmd == 240)) {
            drawPolygone(points, 3, 15, 0);
        } */

/*
        points[0].x = 84;
        points[0].y = 63;
        points[1].x = 117;
        points[1].y = 64;
        points[2].x = 118;
        points[2].y = 117;

        drawPolygone(points, 3, 1, 0);
/*
        points[0].x = FIX16(0.0);
        points[0].y = FIX16(0.0);
        points[1].x = FIX16(32.0);
        points[1].y = FIX16(0.0);
        points[1].x = FIX16(16.0);
        points[1].y = FIX16(16.0);
*/

/*
        for (i = 128; i; i -= 4) {
            points[0].x = 0;
            points[0].y = 0;
            points[1].x = 32;
            points[1].y = 0;
            points[2].x = 16 + i;
            points[2].y = 16 + i;

            drawPolygone(points, 3, i, 0);
            blitBitmap(0, 0, WORK_W, WORK_H);
        }
*/
        blitBitmap(0, 0, WORK_W, WORK_H);
    }
}
