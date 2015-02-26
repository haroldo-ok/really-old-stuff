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
	unlk	a6
	rts
