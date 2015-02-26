#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

void mth_error_display(mth_process *proc, MOUSETH_MEMORY_CELL errcode) {
    switch (errcode) {
    case MTH_EXIT_NONE:
    case MTH_EXIT_NORMAL:
        break;

    case MTH_EXIT_INVALID_INS:
        fprintf(stderr, "\nerror %d: Invalid instruction at 0x%x\n", errcode, MTH_PC_GET-1);
        break;

    case MTH_EXIT_DIV0:
        fprintf(stderr, "\nerror %d: Integer division by zero at 0x%x\n", errcode, MTH_PC_GET-1);
        break;

    default:
        fprintf(stderr, "\nerror %d: Unknown error at 0x%x\n", errcode, MTH_PC_GET-1);
    }
}
