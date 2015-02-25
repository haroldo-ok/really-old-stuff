	.data
	.globl	__brflag_pal
__brflag_pal:
	.dc.w	3808
	.dc.w	0
	.dc.w	96
	.dc.w	160
	.dc.w	192
	.dc.w	704
	.dc.w	224
	.dc.w	224
	.dc.w	512
	.dc.w	1056
	.dc.w	1602
	.dc.w	226
	.dc.w	2116
	.dc.w	164
	.dc.w	2182
	.dc.w	232
	.globl	__usflag_pal
__usflag_pal:
	.dc.w	3808
	.dc.w	1058
	.dc.w	2
	.dc.w	2
	.dc.w	1092
	.dc.w	2116
	.dc.w	2660
	.dc.w	2660
	.dc.w	1094
	.dc.w	6
	.dc.w	550
	.dc.w	1094
	.dc.w	1638
	.dc.w	8
	.dc.w	8
	.dc.w	3822
	.bss
	.globl	_curr_language
	.comm	_curr_language,2
	.data
	.globl	__press_start
__press_start:
	.dc.l	L0
	.dc.l	L1
	.globl	__game_modes
__game_modes:
	.dc.l	L2
	.dc.l	L3
	.dc.l	L4
	.dc.l	L5
	.dc.l	L6
	.dc.l	L7
	.dc.l	L8
	.dc.l	L9
	.dc.l	L10
	.dc.l	L11
	.dc.l	L12
	.dc.l	L13
	.globl	__wh_settings
__wh_settings:
	.dc.l	L14
	.dc.l	L15
	.dc.l	L16
	.dc.l	L17
	.dc.l	L18
	.dc.l	L19
	.dc.l	L20
	.dc.l	L21
	.globl	__bomb_settings
__bomb_settings:
	.dc.l	L22
	.dc.l	L23
	.dc.l	L24
	.dc.l	L25
	.globl	__extmode_settings
__extmode_settings:
	.dc.l	L26
	.dc.l	L27
	.dc.l	L28
	.dc.l	L29
	.globl	__game_over_str
__game_over_str:
	.dc.l	L30
	.dc.l	L31
	.dc.l	L32
	.dc.l	L33
	.globl	__survival_stbar
__survival_stbar:
	.dc.l	L34
	.dc.l	L35
	.dc.l	L36
	.dc.l	L37
	.dc.l	L38
	.dc.l	L39
	.dc.l	L40
	.dc.l	L41
	.dc.l	L42
	.dc.l	L43
	.dc.l	L44
	.dc.l	L45
	.globl	__mission_stbar
__mission_stbar:
	.dc.l	L46
	.dc.l	L47
	.dc.l	L48
	.dc.l	L49
	.dc.l	L50
	.dc.l	L51
	.dc.l	L52
	.dc.l	L53
	.dc.l	L54
	.dc.l	L55
	.dc.l	L56
	.dc.l	L57
	.dc.l	L58
	.dc.l	L59
	.dc.l	L60
	.dc.l	L61
	.globl	__mission_briefing
__mission_briefing:
	.dc.l	L62
	.dc.l	L63
	.dc.l	L64
	.dc.l	L65
	.dc.l	L66
	.dc.l	L67
	.dc.l	L68
	.dc.l	L69
	.dc.l	L70
	.dc.l	L71
	.globl	__mission_ending
__mission_ending:
	.dc.l	L72
	.dc.l	L73
	.dc.l	L74
	.dc.l	L75
	.dc.l	L76
	.dc.l	L77
	.dc.l	L78
	.dc.l	L79
	.dc.l	L80
	.dc.l	L81
	.dc.l	L82
	.dc.l	L83
	.globl	__credits_caption
__credits_caption:
	.dc.l	L84
	.dc.l	L85
	.globl	__pause_opts
__pause_opts:
	.dc.l	L86
	.dc.l	L87
	.dc.l	L88
	.dc.l	L89
	.globl	__credits_text_ptr_prt
__credits_text_ptr_prt:
	.dc.l	L90
	.dc.l	L91
	.dc.l	L92
	.dc.l	L93
	.dc.l	L94
	.dc.l	L95
	.dc.l	L96
	.dc.l	L97
	.dc.l	L98
	.dc.l	L99
	.dc.l	L100
	.dc.l	L101
	.dc.l	L102
	.dc.l	L103
	.dc.l	L104
	.dc.l	L105
	.dc.l	L106
	.dc.l	L107
	.dc.l	L108
	.dc.l	L109
	.dc.l	L110
	.dc.l	0
	.globl	__credits_text_ptr_eng
__credits_text_ptr_eng:
	.dc.l	L111
	.dc.l	L112
	.dc.l	L113
	.dc.l	L114
	.dc.l	L115
	.dc.l	L116
	.dc.l	L117
	.dc.l	L118
	.dc.l	L119
	.dc.l	L120
	.dc.l	L121
	.dc.l	L122
	.dc.l	L123
	.dc.l	L124
	.dc.l	L125
	.dc.l	L126
	.dc.l	L127
	.dc.l	L128
	.dc.l	L129
	.dc.l	L130
	.dc.l	L131
	.dc.l	0
	.data
L150:	.dc.b	$45,$6e,$67,$6c,$69,$73,$68
	.dc.b	0
L148:	.dc.b	$50,$6f,$72,$74,$75,$67,$75,$7e,$38,$38,$73
	.dc.b	0
L143:	.dc.b	$50,$6f,$72,$74,$75,$67,$75,$7e,$38,$38,$73
	.dc.b	0
L142:	.dc.b	$53,$65,$6c,$65,$63,$74,$20,$6c,$61,$6e,$67
	.dc.b	$75,$61,$67,$65
	.dc.b	0
L141:	.dc.b	$45,$73,$63,$6f,$6c,$68,$61,$20,$61,$20,$6c
	.dc.b	$69,$6e,$67,$75,$61,$67,$65,$6d
	.dc.b	0
L131:	.dc.b	$9,$9,$62,$79,$20,$74,$68,$65,$20,$50,$4f
	.dc.b	$56,$2d,$54,$65,$61,$6d
	.dc.b	0
L130:	.dc.b	$9,$50,$4f,$56,$2d,$52,$61,$79,$28,$74,$6d
	.dc.b	$29,$20,$76,$33,$2e,$31
	.dc.b	0
L129:	.dc.b	$9,$9,$62,$79,$20,$48,$61,$72,$6f,$6c,$64
	.dc.b	$6f,$20,$4f,$2e,$20,$50,$69,$6e,$68,$65,$69,$72,$6f
	.dc.b	0
L128:	.dc.b	$9,$50,$41,$54,$43,$48,$44,$41,$54
	.dc.b	0
L127:	.dc.b	$9,$4d,$41,$4b,$45,$44,$41,$54,$2c
	.dc.b	0
L126:	.dc.b	$9,$50,$43,$58,$47,$32,$47,$45,$4e,$2c
	.dc.b	0
L125:	.dc.b	$9,$50,$43,$58,$32,$47,$45,$4e,$2c
	.dc.b	0
L124:	.dc.b	$9,$9,$62,$79,$20,$53,$6e,$6f,$77,$42,$72
	.dc.b	$6f
	.dc.b	0
L123:	.dc.b	$9,$54,$69,$6c,$65,$20,$4c,$61,$79,$65,$72
	.dc.b	$20,$76,$30,$2e,$35,$30,$62
	.dc.b	0
L122:	.dc.b	$9,$9,$62,$79,$20,$50,$61,$75,$6c,$20,$57
	.dc.b	$2e,$20,$4c,$65,$65
	.dc.b	0
L121:	.dc.b	$9,$53,$65,$67,$61,$20,$47,$65,$6e,$65,$73
	.dc.b	$69,$73,$20,$43,$20,$43,$6f,$6d,$70,$69,$6c,$65,$72
	.dc.b	0
L120:	.dc.b	$c,$54,$6f,$6f,$6c,$73,$20,$75,$73,$65,$64
	.dc.b	0
L119:	.dc.b	0
L118:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L117:	.dc.b	$c,$56,$6f,$69,$63,$65,$73
	.dc.b	0
L116:	.dc.b	0
L115:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L114:	.dc.b	$c,$43,$6f,$64,$65
	.dc.b	0
L113:	.dc.b	0
L112:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L111:	.dc.b	$c,$47,$72,$61,$70,$68,$69,$63,$73
	.dc.b	0
L110:	.dc.b	$9,$9,$70,$65,$6c,$6f,$20,$50,$4f,$56,$2d
	.dc.b	$54,$65,$61,$6d
	.dc.b	0
L109:	.dc.b	$9,$50,$4f,$56,$2d,$52,$61,$79,$28,$74,$6d
	.dc.b	$29,$20,$76,$33,$2e,$31
	.dc.b	0
L108:	.dc.b	$9,$9,$70,$6f,$72,$20,$48,$61,$72,$6f,$6c
	.dc.b	$64,$6f,$20,$4f,$2e,$20,$50,$69,$6e,$68,$65,$69,$72,$6f
	.dc.b	0
L107:	.dc.b	$9,$50,$41,$54,$43,$48,$44,$41,$54
	.dc.b	0
L106:	.dc.b	$9,$4d,$41,$4b,$45,$44,$41,$54,$2c
	.dc.b	0
L105:	.dc.b	$9,$50,$43,$58,$47,$32,$47,$45,$4e,$2c
	.dc.b	0
L104:	.dc.b	$9,$50,$43,$58,$32,$47,$45,$4e,$2c
	.dc.b	0
L103:	.dc.b	$9,$9,$70,$6f,$72,$20,$53,$6e,$6f,$77,$42
	.dc.b	$72,$6f
	.dc.b	0
L102:	.dc.b	$9,$54,$69,$6c,$65,$20,$4c,$61,$79,$65,$72
	.dc.b	$20,$76,$30,$2e,$35,$30,$62
	.dc.b	0
L101:	.dc.b	$9,$9,$70,$6f,$72,$20,$50,$61,$75,$6c,$20
	.dc.b	$57,$2e,$20,$4c,$65,$65
	.dc.b	0
L100:	.dc.b	$9,$53,$65,$67,$61,$20,$47,$65,$6e,$65,$73
	.dc.b	$69,$73,$20,$43,$20,$43,$6f,$6d,$70,$69,$6c,$65,$72
	.dc.b	0
L99:	.dc.b	$c,$46,$65,$72,$72,$61,$6d,$65,$6e,$74,$61
	.dc.b	$73,$20,$75,$73,$61,$64,$61,$73
	.dc.b	0
L98:	.dc.b	0
L97:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L96:	.dc.b	$c,$56,$6f,$7a,$65,$73
	.dc.b	0
L95:	.dc.b	0
L94:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L93:	.dc.b	$c,$43,$7e,$41,$32,$64,$69,$67,$6f
	.dc.b	0
L92:	.dc.b	0
L91:	.dc.b	$9,$48,$61,$72,$6f,$6c,$64,$6f,$20,$64,$65
	.dc.b	$20,$4f,$6c,$69,$76,$65,$69,$72,$61,$20,$50,$69,$6e,$68,$65,$69
	.dc.b	$72,$6f
	.dc.b	0
L90:	.dc.b	$c,$47,$72,$7e,$41,$30,$66,$69,$63,$6f,$73
	.dc.b	0
L89:	.dc.b	$51,$75,$69,$74
	.dc.b	0
L88:	.dc.b	$43,$6f,$6e,$74,$69,$6e,$75,$65
	.dc.b	0
L87:	.dc.b	$44,$65,$73,$69,$73,$74,$65
	.dc.b	0
L86:	.dc.b	$43,$6f,$6e,$74,$69,$6e,$75,$61,$72
	.dc.b	0
L85:	.dc.b	$2a,$2a,$2a,$20,$43,$72,$65,$64,$69,$74,$73
	.dc.b	$20,$2a,$2a,$2a
	.dc.b	0
L84:	.dc.b	$2a,$2a,$2a,$20,$43,$72,$7e,$38,$32,$64,$69
	.dc.b	$74,$6f,$73,$20,$2a,$2a,$2a
	.dc.b	0
L83:	.dc.b	$30,$20,$6c,$69,$76,$65,$73
	.dc.b	0
L82:	.dc.b	$58,$58,$58,$58,$58,$58,$58,$20,$70,$6f,$69
	.dc.b	$6e,$74,$73
	.dc.b	0
L81:	.dc.b	$59,$6f,$75,$72,$20,$66,$69,$6e,$61,$6c,$20
	.dc.b	$73,$63,$6f,$72,$65,$3a
	.dc.b	0
L80:	.dc.b	$59,$6f,$75,$20,$73,$75,$72,$76,$69,$76,$65
	.dc.b	$64,$20,$66,$72,$6f,$6d,$20,$74,$68,$65,$20,$6d,$69,$73,$73,$69
	.dc.b	$6f,$6e,$73,$2e
	.dc.b	0
L79:	.dc.b	0
L78:	.dc.b	$43,$6f,$6e,$67,$72,$61,$74,$75,$6c,$61,$74
	.dc.b	$69,$6f,$6e,$73,$21,$21
	.dc.b	0
L77:	.dc.b	$30,$20,$76,$69,$64,$61,$73
	.dc.b	0
L76:	.dc.b	$58,$58,$58,$58,$58,$58,$58,$20,$70,$6f,$6e
	.dc.b	$74,$6f,$73
	.dc.b	0
L75:	.dc.b	$53,$65,$75,$20,$73,$63,$6f,$72,$65,$20,$66
	.dc.b	$69,$6e,$61,$6c,$3a
	.dc.b	0
L74:	.dc.b	$56,$6f,$63,$7e,$38,$38,$20,$73,$6f,$62,$72
	.dc.b	$65,$76,$69,$76,$65,$75,$20,$7e,$38,$35,$73,$20,$6d,$69,$73,$73
	.dc.b	$7e,$45,$34,$65,$73,$2e
	.dc.b	0
L73:	.dc.b	0
L72:	.dc.b	$50,$61,$72,$61,$62,$7e,$38,$32,$6e,$73,$21
	.dc.b	$21
	.dc.b	0
L71:	.dc.b	$30,$20,$6c,$69,$76,$65,$73,$20,$6c,$65,$66
	.dc.b	$74
	.dc.b	0
L70:	.dc.b	$53,$75,$72,$76,$69,$76,$65,$20,$30,$30,$30
	.dc.b	$20,$73,$65,$63,$6f,$6e,$64,$73
	.dc.b	0
L69:	.dc.b	$44,$65,$73,$74,$72,$6f,$79,$20,$74,$68,$65
	.dc.b	$20,$73,$70,$65,$63,$69,$61,$6c,$20,$62,$6c,$6f,$63,$6b,$73
	.dc.b	0
L68:	.dc.b	$46,$75,$6c,$6c,$66,$69,$6c,$6c,$20,$79,$6f
	.dc.b	$75,$72,$20,$6d,$65,$74,$61
	.dc.b	0
L67:	.dc.b	$4d,$69,$73,$73,$69,$6f,$6e,$20,$30,$30,$30
	.dc.b	0
L66:	.dc.b	$30,$20,$76,$69,$64,$61,$73,$20,$72,$65,$73
	.dc.b	$74,$61,$6e,$74,$65,$73
	.dc.b	0
L65:	.dc.b	$53,$6f,$62,$72,$65,$76,$69,$76,$61,$20,$30
	.dc.b	$30,$30,$20,$73,$65,$67,$75,$6e,$64,$6f,$73
	.dc.b	0
L64:	.dc.b	$44,$65,$73,$74,$72,$75,$61,$20,$6f,$73,$20
	.dc.b	$62,$6c,$6f,$63,$6f,$73,$20,$65,$73,$70,$65,$63,$69,$61,$69,$73
	.dc.b	0
L63:	.dc.b	$43,$75,$6d,$70,$72,$61,$20,$61,$20,$6d,$65
	.dc.b	$74,$61
	.dc.b	0
L62:	.dc.b	$4d,$69,$73,$73,$7e,$43,$36,$6f,$20,$30,$30
	.dc.b	$30
	.dc.b	0
L61:	.dc.b	$54,$69,$6d,$65,$20,$20,$20,$20,$78
	.dc.b	0
L60:	.dc.b	$54,$65,$74,$72,$69,$73,$20,$20,$78
	.dc.b	0
L59:	.dc.b	$54,$72,$69,$70,$6c,$65,$20,$20,$78
	.dc.b	0
L58:	.dc.b	$44,$6f,$75,$62,$6c,$65,$20,$20,$78
	.dc.b	0
L57:	.dc.b	$53,$69,$6e,$67,$6c,$65,$20,$20,$78
	.dc.b	0
L56:	.dc.b	$53,$70,$65,$63,$69,$61,$6c,$20,$78
	.dc.b	0
L55:	.dc.b	$53,$70,$65,$65,$64,$20,$20,$20,$3a
	.dc.b	0
L54:	.dc.b	$4d,$69,$73,$73,$69,$6f,$6e,$20,$3a
	.dc.b	0
L53:	.dc.b	$54,$65,$6d,$70,$6f,$20,$20,$20,$20,$78
	.dc.b	0
L52:	.dc.b	$54,$65,$74,$72,$69,$73,$20,$20,$20,$78
	.dc.b	0
L51:	.dc.b	$54,$72,$69,$70,$6c,$6f,$20,$20,$20,$78
	.dc.b	0
L50:	.dc.b	$44,$75,$70,$6c,$6f,$20,$20,$20,$20,$78
	.dc.b	0
L49:	.dc.b	$53,$69,$6d,$70,$6c,$65,$73,$20,$20,$78
	.dc.b	0
L48:	.dc.b	$45,$73,$70,$65,$63,$69,$61,$6c,$20,$78
	.dc.b	0
L47:	.dc.b	$56,$65,$6c,$2e,$20,$20,$20,$20,$20,$3a
	.dc.b	0
L46:	.dc.b	$46,$61,$73,$65,$20,$20,$20,$20,$20,$3a
	.dc.b	0
L45:	.dc.b	$54,$65,$74,$72,$69,$73,$20,$78
	.dc.b	0
L44:	.dc.b	$54,$72,$69,$70,$6c,$65,$20,$78
	.dc.b	0
L43:	.dc.b	$44,$6f,$75,$62,$6c,$65,$20,$78
	.dc.b	0
L42:	.dc.b	$53,$69,$6e,$67,$6c,$65,$20,$78
	.dc.b	0
L41:	.dc.b	$4c,$69,$6e,$65,$73,$20,$20,$78
	.dc.b	0
L40:	.dc.b	$53,$70,$65,$65,$64,$20,$20,$3a
	.dc.b	0
L39:	.dc.b	$54,$65,$74,$72,$69,$73,$20,$20,$78
	.dc.b	0
L38:	.dc.b	$54,$72,$69,$70,$6c,$6f,$20,$20,$78
	.dc.b	0
L37:	.dc.b	$44,$75,$70,$6c,$6f,$20,$20,$20,$78
	.dc.b	0
L36:	.dc.b	$53,$69,$6d,$70,$6c,$65,$73,$20,$78
	.dc.b	0
L35:	.dc.b	$4c,$69,$6e,$68,$61,$73,$20,$20,$78
	.dc.b	0
L34:	.dc.b	$56,$65,$6c,$2e,$20,$20,$20,$20,$3a
	.dc.b	0
L33:	.dc.b	$4f,$56,$45,$52
	.dc.b	0
L32:	.dc.b	$47,$41,$4d,$45
	.dc.b	0
L31:	.dc.b	$4a,$4f,$47,$4f
	.dc.b	0
L30:	.dc.b	$46,$49,$4d,$20,$44,$45
	.dc.b	0
L29:	.dc.b	$45,$78,$74,$65,$6e,$64,$65,$64,$20,$42,$6c
	.dc.b	$6f,$63,$6b,$73
	.dc.b	0
L28:	.dc.b	$4e,$6f,$72,$6d,$61,$6c,$20,$42,$6c,$6f,$63
	.dc.b	$6b,$73
	.dc.b	0
L27:	.dc.b	$50,$65,$7e,$38,$37,$61,$73,$20,$45,$78,$74
	.dc.b	$65,$6e,$64,$69,$64,$61,$73
	.dc.b	0
L26:	.dc.b	$50,$65,$7e,$38,$37,$61,$73,$20,$4e,$6f,$72
	.dc.b	$6d,$61,$69,$73
	.dc.b	0
L25:	.dc.b	$42,$6f,$6d,$62,$73,$20,$4f,$6e
	.dc.b	0
L24:	.dc.b	$42,$6f,$6d,$62,$73,$20,$4f,$66,$66
	.dc.b	0
L23:	.dc.b	$43,$6f,$6d,$20,$42,$6f,$6d,$62,$61,$73
	.dc.b	0
L22:	.dc.b	$53,$65,$6d,$20,$42,$6f,$6d,$62,$61,$73
	.dc.b	0
L21:	.dc.b	$53,$69,$7a,$65,$3a,$20,$32,$32,$78,$38,$20
	.dc.b	0
L20:	.dc.b	$53,$69,$7a,$65,$3a,$20,$32,$36,$78,$31,$32
	.dc.b	0
L19:	.dc.b	$53,$69,$7a,$65,$3a,$20,$32,$30,$78,$38,$20
	.dc.b	0
L18:	.dc.b	$53,$69,$7a,$65,$3a,$20,$32,$32,$78,$31,$30
	.dc.b	0
L17:	.dc.b	$54,$61,$6d,$61,$6e,$68,$6f,$3a,$20,$32,$32
	.dc.b	$78,$38
	.dc.b	0
L16:	.dc.b	$54,$61,$6d,$61,$6e,$68,$6f,$3a,$20,$32,$36
	.dc.b	$78,$31,$32
	.dc.b	0
L15:	.dc.b	$54,$61,$6d,$61,$6e,$68,$6f,$3a,$20,$32,$30
	.dc.b	$78,$38
	.dc.b	0
L14:	.dc.b	$54,$61,$6d,$61,$6e,$68,$6f,$3a,$20,$32,$32
	.dc.b	$78,$31,$30
	.dc.b	0
L13:	.dc.b	$43,$72,$65,$64,$69,$74,$73
	.dc.b	0
L12:	.dc.b	$54,$65,$74,$72,$69,$73,$20,$42,$61,$74,$74
	.dc.b	$6c,$65
	.dc.b	0
L11:	.dc.b	$4d,$69,$73,$73,$69,$6f,$6e,$20,$4d,$6f,$64
	.dc.b	$65
	.dc.b	0
L10:	.dc.b	$50,$6c,$61,$79,$65,$72,$20,$56,$65,$72,$73
	.dc.b	$75,$73,$20,$43,$50,$55
	.dc.b	0
L9:	.dc.b	$32,$20,$50,$6c,$61,$79,$65,$72,$20,$56,$65
	.dc.b	$72,$73,$75,$73
	.dc.b	0
L8:	.dc.b	$53,$75,$72,$76,$69,$76,$61,$6c
	.dc.b	0
L7:	.dc.b	$43,$72,$7e,$38,$32,$64,$69,$74,$6f,$73
	.dc.b	0
L6:	.dc.b	$43,$6f,$6d,$62,$61,$74,$65,$20,$54,$65,$74
	.dc.b	$72,$69,$73
	.dc.b	0
L5:	.dc.b	$4d,$6f,$64,$6f,$20,$4d,$69,$73,$73,$7e,$43
	.dc.b	$36,$6f
	.dc.b	0
L4:	.dc.b	$4a,$6f,$67,$61,$64,$6f,$72,$20,$63,$6f,$6e
	.dc.b	$74,$72,$61,$20,$43,$50,$55
	.dc.b	0
L3:	.dc.b	$44,$69,$73,$70,$75,$74,$61,$20,$64,$65,$20
	.dc.b	$64,$6f,$69,$73
	.dc.b	0
L2:	.dc.b	$53,$6f,$62,$72,$65,$76,$69,$76,$7e,$38,$38
	.dc.b	$6e,$63,$69,$61
	.dc.b	0
L1:	.dc.b	$50,$72,$65,$73,$73,$20,$53,$74,$61,$72,$74
	.dc.b	0
L0:	.dc.b	$41,$70,$65,$72,$74,$65,$20,$53,$74,$61,$72
	.dc.b	$74
	.dc.b	0
	.text
	.globl	_choose_language
_choose_language:
	link	a6,#0
	movem.l	d3-d4,-(sp)
	move.l	#483568,-(sp)
	move.w	#3840,d0
	lsr.w	#5,d0
	move.w	d0,-(sp)
	move.w	#256,-(sp)
	jsr	_set_bkg_data
	addq.w	#8,sp
	moveq.l	#0,d3
L135:
	cmp.w	#64,d3
	bcc	L137
	moveq.l	#0,d4
L138:
	cmp.w	#64,d4
	bcc	L136
	move.w	#256,-(sp)
	move.w	#57344,-(sp)
	move.l	#487408,-(sp)
	move.w	#8,-(sp)
	move.w	#16,-(sp)
	move.w	d3,-(sp)
	move.w	d4,-(sp)
	jsr	_set_bkg_tiles
	lea	16(sp),sp
	add.w	#16,d4
	bra	L138
L136:
	addq.w	#8,d3
	bra	L135
L137:
	move.l	#__back_pal,-(sp)
	clr.w	-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.w	#8192,-(sp)
	clr.w	-(sp)
	move.l	#451088,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	move.l	#_blocks_pal,-(sp)
	move.w	#3,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#L141,-(sp)
	move.w	#49152,-(sp)
	move.w	#2,-(sp)
	move.w	#4,-(sp)
	move.w	#11,-(sp)
	jsr	_out_text
	lea	12(sp),sp
	move.l	#L142,-(sp)
	move.w	#49152,-(sp)
	move.w	#2,-(sp)
	move.w	#5,-(sp)
	move.w	#13,-(sp)
	jsr	_out_text
	lea	12(sp),sp
	move.l	#487664,-(sp)
	move.w	#2624,d0
	lsr.w	#5,d0
	move.w	d0,-(sp)
	move.w	#512,-(sp)
	jsr	_set_bkg_data
	addq.w	#8,sp
	move.w	#8704,-(sp)
	move.w	#49152,-(sp)
	move.l	#490288,-(sp)
	move.w	#8,-(sp)
	move.w	#16,-(sp)
	move.w	#10,-(sp)
	move.w	#2,-(sp)
	jsr	_set_bkg_tiles
	lea	16(sp),sp
	move.l	#__brflag_pal,-(sp)
	move.w	#1,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#490544,-(sp)
	move.w	#2208,d0
	lsr.w	#5,d0
	move.w	d0,-(sp)
	move.w	#1024,-(sp)
	jsr	_set_bkg_data
	addq.w	#8,sp
	move.w	#17408,-(sp)
	move.w	#49152,-(sp)
	move.l	#492752,-(sp)
	move.w	#8,-(sp)
	move.w	#16,-(sp)
	move.w	#10,-(sp)
	move.w	#21,-(sp)
	jsr	_set_bkg_tiles
	lea	16(sp),sp
	move.l	#__usflag_pal,-(sp)
	move.w	#2,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.w	#1024,-(sp)
	move.w	#32,-(sp)
	move.l	#465408,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	move.l	#L143,-(sp)
	move.w	#49152,-(sp)
	move.w	#2,-(sp)
	move.w	#20,-(sp)
	move.w	#15,-(sp)
	jsr	_out_text
	lea	12(sp),sp
	moveq.l	#0,d3
	moveq.l	#0,d4
	move.w	#0,_curr_language
L144:
	jsr	_read_joypad1
	and.w	#128,d0
	bne	L145
	move.w	_wallpaper_y,-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	move.w	_wallpaper_x,-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	move.w	#1,-(sp)
	jsr	_random
	addq.w	#2,sp
	subq.w	#1,_wallpaper_x
	addq.w	#1,_wallpaper_y
	jsr	_read_joypad1
	move.w	d0,d3
	cmp.w	d4,d3
	beq	L146
	move.w	d3,d0
	and.w	#4,d0
	beq	L147
	move.w	#0,_curr_language
	clr.w	-(sp)
	move.w	#49152,-(sp)
	move.w	#1,-(sp)
	move.w	#40,-(sp)
	move.w	#20,-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.l	#L148,-(sp)
	move.w	#49152,-(sp)
	move.w	#2,-(sp)
	move.w	#20,-(sp)
	move.w	#15,-(sp)
	jsr	_out_text
	lea	12(sp),sp
	move.l	#_Ding1,-(sp)
	move.w	#1,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
L147:
	move.w	d3,d0
	and.w	#8,d0
	beq	L149
	move.w	#1,_curr_language
	clr.w	-(sp)
	move.w	#49152,-(sp)
	move.w	#1,-(sp)
	move.w	#40,-(sp)
	move.w	#20,-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.l	#L150,-(sp)
	move.w	#49152,-(sp)
	move.w	#2,-(sp)
	move.w	#20,-(sp)
	move.w	#16,-(sp)
	jsr	_out_text
	lea	12(sp),sp
	move.l	#_Ding1,-(sp)
	move.w	#1,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
L149:
	move.w	d3,d4
L146:
	move.w	_menu_blink_ctrl,d0
	addq.w	#1,d0
	and.w	#15,d0
	move.w	d0,_menu_blink_ctrl
	addq.w	#1,d0
	or.w	#24576,d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	move.w	#80,-(sp)
	move.w	#152,d0
	mulu	_curr_language,d0
	add.w	#16,d0
	move.w	d0,-(sp)
	move.w	#1,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.w	_menu_blink_ctrl,d0
	addq.w	#1,d0
	or.w	#24576,d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	move.w	#144,-(sp)
	move.w	#152,d0
	mulu	_curr_language,d0
	add.w	#16,d0
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.w	_menu_blink_ctrl,d0
	addq.w	#1,d0
	or.w	#24576,d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	move.w	#80,-(sp)
	move.w	#152,d0
	mulu	_curr_language,d0
	add.w	#146,d0
	move.w	d0,-(sp)
	move.w	#3,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.w	_menu_blink_ctrl,d0
	addq.w	#1,d0
	or.w	#24576,d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	move.w	#144,-(sp)
	move.w	#152,d0
	mulu	_curr_language,d0
	add.w	#146,d0
	move.w	d0,-(sp)
	move.w	#4,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.w	#4,-(sp)
	move.w	#1,-(sp)
	jsr	_show_sprite
	addq.w	#4,sp
	jsr	_generate_sound
	jsr	_wait_sync
	bra	L144
L145:
	tst.w	_curr_language
	beq	L151
	move.l	#7226,-(sp)
	move.l	#830630,-(sp)
	jsr	_play_sample
	addq.w	#8,sp
L152:
	moveq.l	#0,d3
L153:
	cmp.w	#40,d3
	beq	L156
	move.w	_wallpaper_y,-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	move.w	_wallpaper_x,-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	move.w	#1,-(sp)
	jsr	_random
	addq.w	#2,sp
	subq.w	#1,_wallpaper_x
	addq.w	#1,_wallpaper_y
	jsr	_generate_sound
	jsr	_wait_sync
	addq.w	#1,d3
	bra	L153
L156:
	jsr	_read_joypad1
	and.w	#128,d0
	beq	L157
	move.w	_wallpaper_y,-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	move.w	_wallpaper_x,-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	move.w	#1,-(sp)
	jsr	_random
	addq.w	#2,sp
	subq.w	#1,_wallpaper_x
	addq.w	#1,_wallpaper_y
	jsr	_generate_sound
	jsr	_wait_sync
	bra	L156
L157:
	clr.w	-(sp)
	move.w	#49152,-(sp)
	move.w	#28,-(sp)
	move.w	#40,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#4,-(sp)
	jsr	_reset_sprites
	addq.w	#2,sp
	movem.l	(sp)+,d3-d4
	unlk	a6
	rts
L151:
	move.l	#8079,-(sp)
	move.l	#837856,-(sp)
	jsr	_play_sample
	addq.w	#8,sp
	bra	L152
