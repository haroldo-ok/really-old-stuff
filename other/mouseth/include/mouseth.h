#include "mth_conf.h"

#define MTH_INS_INVALID (0)
#define MTH_INS_NOP (1)
#define MTH_INS_ENDPROGRAM (2)
#define MTH_INS_CALL (3)
#define MTH_INS_RETURN (4)
#define MTH_INS_BRANCHZ (5)
#define MTH_INS_LOAD (6)
#define MTH_INS_STORE (7)
#define MTH_INS_ADD (8)
#define MTH_INS_SUB (9)
#define MTH_INS_SHIFTL (10)
#define MTH_INS_SHIFTR (11)
#define MTH_INS_OR (12)
#define MTH_INS_AND (13)
#define MTH_INS_NOT (14)
#define MTH_INS_EQUALS (15)
#define MTH_INS_LESS (16)
#define MTH_INS_GREATER (17)
#define MTH_INS_SYSCALL (18)

#define MTH_INS_NUMBER_MASK (0x80)
#define MTH_INS_NUMBER_UNMASK (0x7F)
#define MTH_INS_NUMBER_DECODE(h, l) (((MOUSETH_MEMORY_CELL)(h) & MTH_INS_NUMBER_UNMASK) << 8 | ((l) & 0xFF))
#define MTH_INS_NUMBER_ENCODE(n) (((n) >> 8) & 0x7F | MTH_INS_NUMBER_MASK), (n & 0xFF)

#define MTH_MEM_EXITCODE (0)
#define MTH_MEM_MEMSIZE (1)
#define MTH_MEM_PC (2)
#define MTH_MEM_CURRENTCODE (3)
#define MTH_MEM_APC (4)
#define MTH_MEM_AUXCODE (5)
#define MTH_MEM_CODESP (6)
#define MTH_MEM_CODESP_BASE (7)
#define MTH_MEM_DATASP (8)
#define MTH_MEM_DATASP_BASE (9)

#define MTH_MEM_IO (16)
#define MTH_MEM_IO1 (17)
#define MTH_MEM_IO2 (18)
#define MTH_MEM_IO3 (19)
#define MTH_MEM_IO4 (20)
#define MTH_MEM_IO5 (21)
#define MTH_MEM_IO6 (22)
#define MTH_MEM_IO7 (23)

#define MTH_MEM_SYS (24)
#define MTH_MEM_SYS1 (25)
#define MTH_MEM_SYS2 (26)
#define MTH_MEM_SYS3 (27)
#define MTH_MEM_SYS4 (28)
#define MTH_MEM_SYS5 (29)
#define MTH_MEM_SYS6 (30)
#define MTH_MEM_SYS7 (31)

#define MTH_SYSCALL_AVAILABLE (0)
#define MTH_SYSCALL_MUL (2)
#define MTH_SYSCALL_DIV (3)
#define MTH_SYSCALL_READNUM (4)

#define MTH_EXIT_NONE 0
#define MTH_EXIT_NORMAL 1
#define MTH_EXIT_INVALID_INS 2
#define MTH_EXIT_DIV0 3
#define MTH_EXIT_LOADPROG 16

#define MTH_PC_SET(data) (mth_mem_write(proc, MTH_MEM_PC, data))
#define MTH_PC_GET (mth_mem_read(proc, MTH_MEM_PC))

#define MTH_CODESP_SET(data) (mth_mem_write(proc, MTH_MEM_CODESP, data))
#define MTH_CODESP_GET (mth_mem_read(proc, MTH_MEM_CODESP))

#define MTH_DATASP_SET(data) (mth_mem_write(proc, MTH_MEM_DATASP, data))
#define MTH_DATASP_GET (mth_mem_read(proc, MTH_MEM_DATASP))

#define MTH_DATA_POP (mth_data_pop(proc))
#define MTH_DATA_PUSH(data) (mth_data_push(proc, data))

#define MTH_CODE_POP (mth_code_pop(proc))
#define MTH_CODE_PUSH(data) (mth_code_push(proc, data))
