	.bss
	.globl	_frame_ctrl
	.comm	_frame_ctrl,2
	.text
	.globl	_init_interr
_init_interr:
	link	a6,#0
	unlk	a6
	rts
	.data
	.text
	.globl	_poll_interr
_poll_interr:
	link	a6,#0
	addq.w	#1,_frame_ctrl
	unlk	a6
	rts
