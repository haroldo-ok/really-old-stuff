
all: river.sms

river.sms: river.c terrain.apk sprite.apk
	zcc +sms river.c -o river.sms -m
	map2sym river.map river.sym
	
terrain.apk: terrain.til
	cutbin terrain.til terrain.cut 2048
	apack terrain.cut terrain.apk

sprite.apk: sprite.til
	cutbin sprite.til sprite.cut 2048
	apack sprite.cut sprite.apk

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
