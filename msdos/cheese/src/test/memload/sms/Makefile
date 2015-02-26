
#all: mloadsms.sms

#mloadsms.sms: cheese_memload.c
#	zcc +sms cheese_memload.c -o mloadsms.sms -m
#	map2sym mloadsms.map mloadsms.sym

# Project: mloadsms
# Makefile created by Dev-C++ 4.9.9.2

CPP  = g++.exe
CC   = zcc.exe +sms
WINDRES = windres.exe
RES  = 
OBJ  = ..\..\..\lib\chs_func.o ..\..\..\lib\chs_intr.o ..\..\..\lib\stdio\chs_cons.o cheese_memload.c $(RES)
LINKOBJ  = ..\..\..\lib\chs_func.o ..\..\..\lib\chs_intr.o ..\..\..\lib\stdio\chs_cons.o cheese_memload.c $(RES)
LIBS =  -L"C:\utils\z88dk\lib"  
INCS =  -I"C:\utils\z88dk\include"  -I"..\..\..\..\include"  -I"..\..\..\..\include\sms" 
CXXINCS =  -I"C:/Dev-Cpp/lib\gcc/mingw32/3.4.2/include"  -I"C:/Dev-Cpp/include/c++/3.4.2/backward"  -I"C:/Dev-Cpp/include/c++/3.4.2/mingw32"  -I"C:/Dev-Cpp/include/c++/3.4.2"  -I"C:/Dev-Cpp/include"  -I"..\..\..\..\include"  -I"..\..\..\..\include/sms" 
BIN  = mloadsms.sms
CXXFLAGS = $(CXXINCS)  
CFLAGS = $(INCS)  
RM = rm -f

.PHONY: all all-before all-after clean clean-custom

all: mloadsms.sms


clean: 
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CC) $(LINKOBJ) -o "mloadsms.sms" -m $(CFLAGS)
	map2sym mloadsms.map mloadsms.sym

..\..\..\lib\chs_func.o: ..\..\..\lib\chs_func.c
	$(CC) -c ..\..\..\lib\chs_func.c -o ..\..\..\lib\chs_func.o $(CFLAGS)

..\..\..\lib\chs_intr.o: ..\..\..\lib\chs_intr.c
	$(CC) -c ..\..\..\lib\chs_intr.c -o ..\..\..\lib\chs_intr.o $(CFLAGS)

..\..\..\lib\stdio\chs_cons.o: ..\..\..\lib\stdio\chs_cons.c
	$(CC) -c ..\..\..\lib\stdio\chs_cons.c -o ..\..\..\lib\stdio\chs_cons.o $(CFLAGS)
