# Project: rprun
# Makefile created by Dev-C++ 4.9.9.2

CPP  = g++.exe
CC   = zcc.exe +sms
WINDRES = windres.exe
RES  = 
OBJ  = ..\..\lib\chs_func.o ..\..\lib\chs_intr.o ..\..\lib\rpcheese\chs_cons.o rprun.o ..\..\lib\rpcheese\rpg_mpar.o ..\..\lib\rpcheese\sms\rpg_disp.o ..\..\lib\rpcheese\rpg_turn.o $(RES)
#LINKOBJ  = ..\..\lib\chs_func.o ..\..\lib\chs_intr.o ..\..\lib\rpcheese\chs_cons.o rprun.o ..\..\lib\rpcheese\rpg_mpar.o ..\..\lib\rpcheese\sms\rpg_disp.o ..\..\lib\rpcheese\rpg_turn.o $(RES)
LINKOBJ  = rprun.o ..\..\lib\rpcheese\rpg_mpar.o ..\..\lib\rpcheese\sms\rpg_disp.o ..\..\lib\rpcheese\rpg_turn.o $(RES)
LIBS =  -L"C:\utils\z88dk\lib"   
INCS =  -I"C:\utils\z88dk\include"  -I"..\..\..\include"  -I"..\..\..\include\sms"  -I"..\..\..\include\rpcheese"  -I"..\..\..\include\rpcheese\sms" 
CXXINCS =  -I"C:\Dev-Cpp\lib\gcc\mingw32\3.4.2\include"  -I"C:\Dev-Cpp\include\c++\3.4.2\backward"  -I"C:\Dev-Cpp\include\c++\3.4.2\mingw32"  -I"C:\Dev-Cpp\include\c++\3.4.2"  -I"C:\Dev-Cpp\include" 
BIN  = rprun.exe
CXXFLAGS = $(CXXINCS)  
CFLAGS = $(INCS)  
RM = rm -f

.PHONY: all all-before all-after clean clean-custom

all: rprun.exe


clean: clean-custom
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CC) $(LINKOBJ) -o "rprun.sms" $(LIBS) -m
	map2sym rprun.map rprun.sym

..\..\lib\chs_func.o: ..\..\lib\chs_func.c
	$(CC) -c ..\..\lib\chs_func.c -o ..\..\lib\chs_func.o $(CFLAGS)

..\..\lib\chs_intr.o: ..\..\lib\chs_intr.c
	$(CC) -c ..\..\lib\chs_intr.c -o ..\..\lib\chs_intr.o $(CFLAGS)

..\..\lib\rpcheese\chs_cons.o: ..\..\lib\rpcheese\chs_cons.c
	$(CC) -c ..\..\lib\rpcheese\chs_cons.c -o ..\..\lib\rpcheese\chs_cons.o $(CFLAGS)

rprun.o: rprun.c
	$(CC) -c rprun.c -o rprun.o $(CFLAGS)

..\..\lib\rpcheese\rpg_mpar.o: ..\..\lib\rpcheese\rpg_mpar.c
	$(CC) -c ..\..\lib\rpcheese\rpg_mpar.c -o ..\..\lib\rpcheese\rpg_mpar.o $(CFLAGS)

..\..\lib\rpcheese\sms\rpg_disp.o: ..\..\lib\rpcheese\sms\rpg_disp.c
	$(CC) -c ..\..\lib\rpcheese\sms\rpg_disp.c -o ..\..\lib\rpcheese\sms\rpg_disp.o $(CFLAGS)

..\..\lib\rpcheese\rpg_turn.o: ..\..\lib\rpcheese\rpg_turn.c
	$(CC) -c ..\..\lib\rpcheese\rpg_turn.c -o ..\..\lib\rpcheese\rpg_turn.o $(CFLAGS)
