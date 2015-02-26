
all: nanowars.sms

nanowars.sms: nanowars.c circuit.apk map1.apk
	zcc +sms nanowars.c -o nanowars.sms -m
	map2sym nanowars.map nanowars.sym
	
circuit.apk: circuit.til
	cutbin circuit.til circuit.cut 4096
	apack circuit.cut circuit.apk

map1.apk: map1.bkg
	apack map1.bkg map1.apk

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
