
all: lorez.sms

lorez.sms: lorez.c apa.o sincos.o cube.o
	zcc +sms lorez.c apa.o sincos.o cube.o -o lorez.sms -m
	map2sym lorez.map lorez.sym

apa.o: apa.c
	zcc +sms -c apa.c

sincos.o: sincos.c
	zcc +sms -c sincos.c

cube.o: cube.c
	zcc +sms -c cube.c

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
