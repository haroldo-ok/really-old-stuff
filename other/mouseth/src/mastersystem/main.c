#include <sms.h>
#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

unsigned char pal1[] = {0x00, 0x3F, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F};

unsigned char pal2[] = {0x00, 0x03, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F};

extern char mth_runtime[];

int main()
{
    MOUSETH_MEMORY_CELL cells[MOUSETH_MEMORY_SIZE];

    mth_process proc;

	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN);
	load_tiles(standard_font, 0, 255, 1);
	load_palette(pal1, 0, 16);
	load_palette(pal2, 16, 16);

	printf("MousethVM 0.03 for Master System\n");

	proc.char_buffer[0] = 0;
	proc.char_pos = 0;

    proc.memory = cells;
    proc.runtime = mth_runtime;

    mth_process_init(&proc, MOUSETH_MEMORY_SIZE);

    mth_process_run(&proc);

	for (;;);
	return 0;
}

#asm
._mth_runtime
	BINARY	"runtime.mth"
#endasm
