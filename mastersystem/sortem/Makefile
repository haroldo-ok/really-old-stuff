
all: sortem.sms

sortem.sms: sortem.c sortem.apk sortem.bg2
	zcc +sms sortem.c -o sortem.sms -m
	map2sym sortem.map sortem.sym
	
sortem.apk: sortem.til
	cutbin sortem.til sortem.cut 2048
	apack sortem.cut sortem.apk
	
sortem.bg2: sortem.bkg
	cutbin sortem.bkg sortem.bg2 512

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
