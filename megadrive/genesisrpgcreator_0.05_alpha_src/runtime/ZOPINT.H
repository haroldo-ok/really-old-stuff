/* ZOP bytecode interpreter                                      */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _ZOPINT_H
#define _ZOPINT_H

		/* 32k */
#define ZOP_MAX_PROGSIZE 0x8000

#define ZOP_MAX_INSTR_PER_FRAME 50

		/* Upper six bits represent the main opcode */
#define ZOP_BTC_OP_MASK  0xFCU
#define ZOP_BTC_OP_SHIFT 2U
		/* Lower six bits represent the opcode param, but can work as part of the opcode in some cases. */
#define ZOP_BTC_PR_MASK  0x03U
#define ZOP_BTC_PR_SHIFT 0U

#define ZOP_OP_NOP       0x00U
		/* No operation */
#define ZOP_PR_NOP_NOP   0x00U
		/* Stop for a cycle */
#define ZOP_PR_NOP_DELAY 0x01U
		/* Wait for event */
#define ZOP_PR_NOP_WAIT  0x02U
		/* End program */
#define ZOP_PR_NOP_END   0x03U

		/* Walk in a direction */
#define ZOP_OP_WLK_WALK  0x20U
		/* Try walking in a direction */
#define ZOP_OP_WLK_TRY   0x24U
		/* Turn to face a direction */
#define ZOP_OP_FACE      0x28U

#define ZOP_PR_DIR_NORTH 0x00U
#define ZOP_PR_DIR_SOUTH 0x01U
#define ZOP_PR_DIR_EAST  0x02U
#define ZOP_PR_DIR_WEST  0x03U

		/* Text-related commands */
#define ZOP_OP_TXT         0x40U 
		/* Clears the current text buffer */
#define ZOP_PR_TXT_CLEAR   0x00U 
		/* Add line to the text buffer. Must be followed by a null-terminated string. */
#define ZOP_PR_TXT_WRITE   0x01U 
		/* Displays the text contained in the buffer */
#define ZOP_PR_TXT_DISPLAY 0x02U 
		/* Displays the text contained in the buffer, and then clears it */
#define ZOP_PR_TXT_DISCLR  0x03U 

		/* Menu-related commands */
#define ZOP_OP_MNU         0x44U 
		/* Clears the current menu buffer */
#define ZOP_PR_MNU_CLEAR   0x00U 
		/* Adds option to menu. Followed by a 16-bit jump address (MSB First) and a null-terminated string */
#define ZOP_PR_MNU_ADD     0x01U 
		/* Displays the menu */
#define ZOP_PR_MNU_DISPLAY 0x02U 
		/* Displays the menu, and then clears it */
#define ZOP_PR_MNU_DISCLR  0x03U 

		/* Sets a flag. Must be followed by a single byte. Flag number (Op Param shl 8) + Following byte */
#define ZOP_OP_SET 0x60U
		/* Clears a flag. Same as above. */
#define ZOP_OP_CLR 0x64U
		/* Transfers state of the flag to flag 0. Same as above. */
#define ZOP_OP_TFZ 0x68U
		/* Transfers state of flag 0 to flag. Same as above. */
#define ZOP_OP_TZF 0x6CU
		/* Inverts the state of a flag. Same as above. */
#define ZOP_OP_NOT 0x70U 

		/* Branch command. Must be followed by a 16-bit address (MSB First). Op Param defines jump condition */
#define ZOP_OP_BRA        0x80U
		/* Unconditional jump */
#define ZOP_PR_BRA_ALWAYS 0x00U
		/* Jump if flag 0 is set */
#define ZOP_PR_BRA_SET    0x01U
		/* Jump if flag 0 is not set */ 
#define ZOP_PR_BRA_NOTSET 0x02U

		/* System commands */
#define ZOP_OP_SYS     0xFCU
		/* Extended command */
#define ZOP_PR_SYS_EXT 0x01U

		/* Event codes */
#define ZOP_EVT_NONE  0
#define ZOP_EVT_TOUCH 1
#define ZOP_EVT_TALK  2
#define ZOP_EVT_THUD  3

typedef struct{
	uint code;
	uint addr;
} zop_evt_rec;

typedef struct{
	uint eventcnt;
	zop_evt_rec *eventptr;
	uchar *evtpc;
	uchar *baseaddr;
	uchar *pc;
	uint actornum;
} zop_prog_rec;

extern uint zop_instr_per_frame;
extern uchar zop_flags[];

void zop_vm_init();
void zop_load_prog(prog, fname, actornum);
uchar zop_exec_instruction(prog);
void zop_exec_frame(prog);

void zop_signal_event(prog, event);

void zop_clear_flags();
void zop_set_flag(flag, value);
uchar zop_get_flag(flag);
uchar zop_set_flag0(value);
uchar zop_get_flag0();

void zop_add_text(text);
void zop_add_text_inc(text);

void zop_display_text(clear);
void zop_display_menu(prog, clear);

#endif /* _ZOPINT_H */
