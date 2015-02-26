#include "mouseth.h"

MOUSETH_MEMORY_CELL mth_data_pop(mth_process *proc) {
    MOUSETH_MEMORY_CELL dp = MTH_DATASP_GET;
    MOUSETH_MEMORY_CELL data = mth_mem_read(proc, dp-1);
    MTH_DATASP_SET(dp-1);

    return data;
}

MOUSETH_MEMORY_CELL mth_data_push(mth_process *proc, MOUSETH_MEMORY_CELL data) {
    MOUSETH_MEMORY_CELL dp = MTH_DATASP_GET;
    mth_mem_write(proc, dp, data);
    MTH_DATASP_SET(dp+1);
}

MOUSETH_MEMORY_CELL mth_code_pop(mth_process *proc) {
    MOUSETH_MEMORY_CELL dp = MTH_CODESP_GET;
    MOUSETH_MEMORY_CELL data = mth_mem_read(proc, dp-1);
    MTH_CODESP_SET(dp-1);

    return data;
}

MOUSETH_MEMORY_CELL mth_code_push(mth_process *proc, MOUSETH_MEMORY_CELL data) {
    MOUSETH_MEMORY_CELL dp = MTH_CODESP_GET;
    mth_mem_write(proc, dp, data);
    MTH_CODESP_SET(dp+1);
}

MOUSETH_INSTRUCTION mth_instruction_fetch(mth_process *proc) {
    MOUSETH_MEMORY_CELL pc = MTH_PC_GET;
    MOUSETH_INSTRUCTION ins = mth_code_read(proc, pc);

    MTH_PC_SET(pc+1);

    return ins;
}

void mth_instruction_exec_pushnumber(mth_process *proc, MOUSETH_INSTRUCTION ins) {
        mth_data_push(proc, MTH_INS_NUMBER_DECODE(ins, mth_instruction_fetch(proc)));
}

void mth_instruction_exec_builtin(mth_process *proc, MOUSETH_INSTRUCTION ins) {
    MOUSETH_MEMORY_CELL temp1, temp2;

    switch (ins) {
        case MTH_INS_INVALID:
            mth_mem_write(proc, MTH_MEM_EXITCODE, MTH_EXIT_INVALID_INS);
            break;

        case MTH_INS_NOP:
             break;

        case MTH_INS_ENDPROGRAM:
            mth_mem_write(proc, MTH_MEM_EXITCODE, MTH_EXIT_NORMAL);
            break;

        case MTH_INS_CALL:
             MTH_CODE_PUSH(MTH_PC_GET); // Push PC
             temp1 = MTH_DATA_POP; // Pop destination from data stack
             MTH_PC_SET(temp1); // Jump to destination
             break;

        case MTH_INS_RETURN:
             temp1 = MTH_CODE_POP; // Pop previous address from code stack
             MTH_PC_SET(temp1); // Jump back to destination
             break;

        case MTH_INS_BRANCHZ:
             temp1 = MTH_DATA_POP; // Pop destination address
             temp2 = MTH_DATA_POP; // Pop value to compare
             if (!temp2) {
                 MTH_PC_SET(temp1); // Jump if not zero
             }
             break;

        case MTH_INS_LOAD:
             temp1 = MTH_DATA_POP; // Pop address to load
             temp2 = mth_mem_read(proc, temp1); // Read data from memory
             MTH_DATA_PUSH(temp2); // Push to data stack
             break;

        case MTH_INS_STORE:
             temp1 = MTH_DATA_POP; // Pop destination address
             temp2 = MTH_DATA_POP; // Pop data
             mth_mem_write(proc, temp1, temp2); // Write data to memory
             break;

        case MTH_INS_ADD:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp1 + temp2);
             break;

        case MTH_INS_SUB:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 - temp1);
             break;

        case MTH_INS_SHIFTL:
             temp1 = MTH_DATA_POP; // Pop amount
             temp2 = MTH_DATA_POP; // Pop original data
             MTH_DATA_PUSH(temp2 << temp1);
             break;

        case MTH_INS_SHIFTR:
             temp1 = MTH_DATA_POP; // Pop amount
             temp2 = MTH_DATA_POP; // Pop original data
             MTH_DATA_PUSH(temp2 >> temp1);
             break;

        case MTH_INS_OR:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 | temp1);
             break;

        case MTH_INS_AND:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 & temp1);
             break;

        case MTH_INS_NOT:
             temp1 = MTH_DATA_POP; // Pop data
             MTH_DATA_PUSH(~temp1);
             break;

        case MTH_INS_EQUALS:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 == temp1);
             break;

        case MTH_INS_LESS:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 < temp1);
             break;

        case MTH_INS_GREATER:
             temp1 = MTH_DATA_POP; // Pop 2nd term
             temp2 = MTH_DATA_POP; // Pop 1st term
             MTH_DATA_PUSH(temp2 > temp1);
             break;

        case MTH_INS_SYSCALL:
             temp1 = MTH_DATA_POP; // Pop syscall id
             mth_instruction_exec_syscall(proc, temp1);
             break;

        default:
            mth_mem_write(proc, MTH_MEM_EXITCODE, MTH_EXIT_INVALID_INS);
    }
}

void mth_instruction_exec_custom(mth_process *proc, MOUSETH_INSTRUCTION ins) {
    MOUSETH_MEMORY_CELL custom = mth_mem_read(proc, ins);
    if (custom < MOUSETH_BUILTIN_INSTRUCTIONS) {
        mth_instruction_exec_builtin(proc, (MOUSETH_INSTRUCTION)custom);
    } else {
        MTH_CODE_PUSH(MTH_PC_GET); // Push PC
        MTH_PC_SET(custom); // Jump to destination
    }
}

void mth_instruction_exec(mth_process *proc) {
    MOUSETH_INSTRUCTION ins = mth_instruction_fetch(proc);

    if (ins & MTH_INS_NUMBER_MASK) {
        // Push number
        mth_instruction_exec_pushnumber(proc, ins);
    } else if (ins < MOUSETH_BUILTIN_INSTRUCTIONS) {
        // Builtin instructions
        mth_instruction_exec_builtin(proc, ins);
    } else {
        mth_instruction_exec_custom(proc, ins);
    }
}

void mth_instruction_interrupt(mth_process *proc) {
}

int mth_process_run(mth_process *proc) {
    MOUSETH_MEMORY_CELL exitcode;

    while (!mth_mem_read(proc, MTH_MEM_EXITCODE)) {
        mth_instruction_exec(proc);
    }
    exitcode = mth_mem_read(proc, MTH_MEM_EXITCODE);
    mth_error_display(proc, exitcode);
    return exitcode;
}

void mth_process_init(mth_process *proc, MOUSETH_MEMORY_CELL memsize) {
    int i;
    for (i = 0; i != MOUSETH_MEMORY_RESERVED; i++) {
        mth_mem_write(proc, i, 0);
    }
    mth_mem_write(proc, MTH_MEM_MEMSIZE, memsize);
    MTH_CODESP_SET(memsize-(MOUSETH_DEFAULT_STACK*2));
    MTH_DATASP_SET(memsize-MOUSETH_DEFAULT_STACK);
    MTH_PC_SET(MOUSETH_RUNTIME_BASE);
}
