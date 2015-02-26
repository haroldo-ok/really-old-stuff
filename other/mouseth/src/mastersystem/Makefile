INCS = -I"../../include" -I"../../include/mastersystem"

all: mouseth.sms

mouseth.sms: main.c mth_err.o mth_mem.o mth_prog.o mth_sys.o mouseth.o
	zcc +sms mth_err.o mth_mem.o mth_prog.o mth_sys.o mouseth.o main.c -o mouseth.sms -m $(INCS)
	map2sym mouseth.map mouseth.sym
	
mouseth.o: ../common/mouseth.c
	copy ..\common\mouseth.c
	zcc +sms -vn -make-lib mouseth.c -o mouseth.o $(INCS)

mth_err.o: mth_err.c
	zcc +sms -vn -make-lib mth_err.c $(INCS)

mth_mem.o: mth_mem.c
	zcc +sms -vn -make-lib mth_mem.c $(INCS)

mth_prog.o: mth_prog.c
	zcc +sms -vn -make-lib mth_prog.c $(INCS)

mth_sys.o: mth_sys.c
	zcc +sms -vn -make-lib mth_sys.c $(INCS)

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
