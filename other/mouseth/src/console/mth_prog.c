#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

void mth_loadprog(mth_process *proc, MOUSETH_MEMORY_CELL id) {
    char filename[16];
    FILE *f;

    sprintf(filename, "prog%d.mth", id);

    f = fopen(filename, "rb");
    fread(proc->prog, 1, MOUSETH_PROGRAM_SIZE, f);
    fclose(f);
}
