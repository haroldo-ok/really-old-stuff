#include "mouseth.h"

void mth_instruction_exec_syscall(mth_process *proc, MOUSETH_MEMORY_CELL id) {
    MOUSETH_MEMORY_CELL temp1, temp2;

    switch (id) {
        case MTH_SYSCALL_AVAILABLE:
            temp1 = MTH_DATA_POP; // Pop service # to check
            MTH_DATA_PUSH((temp1 == MTH_SYSCALL_MUL) || (temp1 == MTH_SYSCALL_DIV) || (temp1 == MTH_SYSCALL_READNUM) || (temp1 == MTH_EXIT_LOADPROG));
            break;

        case MTH_SYSCALL_MUL:
            temp1 = MTH_DATA_POP; // Pop 2nd term
            temp2 = MTH_DATA_POP; // Pop 1st term
            MTH_DATA_PUSH(temp2 * temp1);
            break;

        case MTH_SYSCALL_DIV:
            temp1 = MTH_DATA_POP; // Divisor
            temp2 = MTH_DATA_POP; // Dividend

            if (!temp1) {
                MTH_DATA_PUSH(temp2); // Push the two back
                MTH_DATA_PUSH(temp1);
                mth_mem_write(proc, MTH_MEM_EXITCODE, MTH_EXIT_DIV0);
            } else {
                MTH_DATA_PUSH(temp2 / temp1); // Push quotient
                MTH_DATA_PUSH(temp2 % temp1); // Push remainder
            }
            break;

        case MTH_SYSCALL_READNUM:
            scanf("%d", &temp1); // Read the number
            MTH_DATA_PUSH(temp1); // Push it
            break;

        case MTH_EXIT_LOADPROG:
            temp1 = MTH_DATA_POP; // Program number
            mth_loadprog(proc, temp1); // Loads it
            break;
    }
}
