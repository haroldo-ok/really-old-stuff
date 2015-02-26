#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

int main()
{
    MOUSETH_MEMORY_CELL cells[MOUSETH_MEMORY_SIZE];
    MOUSETH_INSTRUCTION runtime[MOUSETH_PROGRAM_BASE];
    MOUSETH_INSTRUCTION prog[MOUSETH_PROGRAM_SIZE];

    mth_process proc;

    FILE *f;
    MOUSETH_INSTRUCTION *p;

    proc.memory = cells;
    proc.runtime = runtime;
    proc.prog = prog;

    f = fopen("runtime.mth", "rb");
    fread(runtime, 1, sizeof(runtime), f);
    fclose(f);

//    mth_loadprog(&proc, 0);

    mth_process_init(&proc, MOUSETH_MEMORY_SIZE);

    mth_process_run(&proc);

	return 0;
}
