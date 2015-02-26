// The standard memory cell is a 16-bit integer
#define MOUSETH_MEMORY_CELL short
// Default number of memory cells.
#define MOUSETH_MEMORY_SIZE (2048)
#define MOUSETH_MEMORY_RESERVED (128)
#define MOUSETH_DEFAULT_STACK (64)

// The standard instruction size is 8 bits
#define MOUSETH_INSTRUCTION char
#define MOUSETH_BUILTIN_INSTRUCTIONS (32)
#define MOUSETH_CUSTOM_INSTRUCTIONS (128-MOUSETH_BUILTIN_INSTRUCTIONS)
#define MOUSETH_RUNTIME_BASE (256)
#define MOUSETH_PROGRAM_BASE (1024)
#define MOUSETH_PROGRAM_SIZE (0xFFFF - MOUSETH_PROGRAM_BASE)

#define CHAR_BUFFER_SIZE (32)

typedef struct _mth_process {
	char char_buffer[CHAR_BUFFER_SIZE + 1];
	int char_pos;

    MOUSETH_INSTRUCTION *runtime;
    MOUSETH_INSTRUCTION *prog;
    MOUSETH_MEMORY_CELL *memory;
} mth_process;
