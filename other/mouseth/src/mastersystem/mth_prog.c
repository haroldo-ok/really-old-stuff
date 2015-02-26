#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

extern char mth_prog0[];

void mth_loadprog(mth_process *proc, MOUSETH_MEMORY_CELL id) {
	proc->prog = mth_prog0;
}

#asm
._mth_prog0
	BINARY	"prog0.mth"
#endasm
