&about&&ok&
"This is a test\x21\n"
0 A: ~ A = 0
( A. 10 < ^ ~ while(A < 10)
	"\n" ~ Line break
	A. ! ~ Output A
	
	A. 2 \ [ ~ A mod 2 != 0?
		" is odd"
	| ~ else
		" is even"
	]
	
	A. 1 + A: ~ A = A + 1
)
$