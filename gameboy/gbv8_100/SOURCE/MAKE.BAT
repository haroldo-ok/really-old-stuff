@echo off
echo chip8.o
..\..\bin\lcc -Wa-l -c -o chip8.o chip8.c
echo toscreen.o
..\..\bin\lcc -Wa-l -Wa-g -c -o toscreen.o toscreen.s
echo desktop.o
..\..\bin\lcc -Wa-l -c -o desktop.o desktop.c
echo battery.o
..\..\bin\lcc -Wa-l -c -o battery.o battery.c
echo palette.o
..\..\bin\lcc -Wa-l -c -o palette.o palette.c
echo dblspeed.o
..\..\bin\lcc -Wa-l -Wa-g -c -o dblspeed.o dblspeed.s
echo keyboard.o
..\..\bin\lcc -Wa-l -c -o keyboard.o keyboard.c
echo comm.o
..\..\bin\lcc -Wa-l -c -o comm.o comm.c
echo gbc8.o
..\..\bin\lcc -Wa-l -c -o gbc8.o gbc8.c
pause

dir *.o /b/s > obj_files

if "%1" == "sgb" goto make_sgb
if "%1" == "cgb" goto make_cgb
if "%1" == "scgb" goto make_scgb

:make_standard
echo compiling for standard gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-ya4 -Wl-yo2 -Wl-j -o gbc8.gb @obj_files
echo cleaning up
goto cleanup

:make_sgb
echo compiling for super gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-ya4 -Wl-yo2 -Wl-j -Wl-yp0x146=0x03 -o gbc8.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_cgb
echo compiling for color gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-ya4 -Wl-yo2 -Wl-j -Wl-yp0x143=0x80 -o gbc8.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_scgb
echo compiling for super gameboy & color gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-ya4 -Wl-yo2 -Wl-j -yp0x146=0x03 -Wl-yp0x143=0x80 -o gbc8.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:cleanup
del *.o
del *.lst
del *.map
del obj_files
