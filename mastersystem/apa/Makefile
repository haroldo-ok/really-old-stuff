
all: sms_apa.sms

sms_apa.sms: sms_apa.c apa.o sincos.o cube.o
	zcc +sms sms_apa.c apa.o sincos.o cube.o -o sms_apa.sms -m
	map2sym sms_apa.map sms_apa.sym

apa.o: apa.c
	zcc +sms -c apa.c

sincos.o: sincos.c
	zcc +sms -c sincos.c

cube.o: cube.c
	zcc +sms -c cube.c

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
