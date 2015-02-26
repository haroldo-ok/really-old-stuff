#include <stdio.h>
#include <stdlib.h>
#include "mouseth.h"

void flush_char_buffer(mth_process *proc) {
	proc->char_buffer[proc->char_pos] = 0;
	printf(proc->char_buffer);
	proc->char_pos = 0;
}

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
//            return getch(); // Not implemented, yet.
    }
    return proc->memory[addr];
}

void mth_mem_write(mth_process *proc, MOUSETH_MEMORY_CELL addr, MOUSETH_MEMORY_CELL data) {
    switch (addr) {
    case MTH_MEM_IO:
    	if (data == 10) {
//        	flush_char_buffer(proc); // Didn't make much of a difference.
			printf("\n");
		} else {
/*			proc->char_buffer[proc->char_pos] = data;
			(proc->char_pos)++;
			if (proc->char_pos >= CHAR_BUFFER_SIZE) {
        		flush_char_buffer(proc);
			} // Didn't make much of a difference. */
			putchar(data);
		}
    }
    proc->memory[addr] = data;
}
