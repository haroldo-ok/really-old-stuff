#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

void mth_error_display(mth_process *proc, MOUSETH_MEMORY_CELL errcode) {
    switch (errcode) {
    case MTH_EXIT_NONE:
    case MTH_EXIT_NORMAL:
        break;

    case MTH_EXIT_INVALID_INS:
        printf("\nerror %d: Invalid instruction at %d\n", errcode, MTH_PC_GET-1);
        break;

    case MTH_EXIT_DIV0:
        printf("\nerror %d: Integer division by zero at %d\n", errcode, MTH_PC_GET-1);
        break;

    default:
        printf("\nerror %d: Unknown error at %d\n", errcode, MTH_PC_GET-1);
    }
}
