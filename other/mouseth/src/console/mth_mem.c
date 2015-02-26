#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

MOUSETH_INSTRUCTION mth_code_read(mth_process *proc, MOUSETH_MEMORY_CELL addr) {
    if (addr < MOUSETH_PROGRAM_BASE) {
        return proc->runtime[addr-MOUSETH_RUNTIME_BASE];
    } else {
        return proc->prog[addr-MOUSETH_PROGRAM_BASE];
    }
}

MOUSETH_MEMORY_CELL mth_mem_read(mth_process *proc, MOUSETH_MEMORY_CELL addr) {
    switch (addr) {
        case MTH_MEM_AUXCODE:
            return mth_code_read(proc, mth_mem_read(proc, MTH_MEM_APC));
        case MTH_MEM_IO:
            return getch();
    }
    return proc->memory[addr];
}

void mth_mem_write(mth_process *proc, MOUSETH_MEMORY_CELL addr, MOUSETH_MEMORY_CELL data) {
    switch (addr) {
    case MTH_MEM_IO:
        putch(data);
    }
    proc->memory[addr] = data;
}
