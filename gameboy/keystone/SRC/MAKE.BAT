@echo off
echo sgbtrans.o
..\..\bin\lcc -Wa-l -Wf-bo3 -c -o sgbtrans.o sgbtrans.s
echo border.o
..\..\bin\lcc -Wa-l -Wf-bo3 -c -o border.o border.c
echo gamechar.o
..\..\bin\lcc -Wa-l -Wf-bo1 -c -o gamedata.o gamedata.c
echo title.o
..\..\bin\lcc -Wa-l -Wf-bo2 -c -o title.o title.c
echo levels.o
..\..\bin\lcc -Wa-l -Wf-bo1 -c -o levels.o levels.c
echo speedup.o
..\..\bin\lcc -Wa-l -c -o speedup.o speedup.s
echo keystone.o
..\..\bin\lcc -Wa-l -c -o keystone.o keystone.c
pause

dir *.o /b/s > obj_files

if "%1" == "sgb" goto make_sgb
if "%1" == "cgb" goto make_cgb
if "%1" == "scgb" goto make_scgb

:make_standard
echo compiling for standard gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-yo4 -Wl-j -o keystone.gb @obj_files
echo cleaning up
goto cleanup

:make_sgb
echo compiling for super gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-yo4 -Wl-yp0x146=0x03 -o keystone.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_cgb
echo compiling for color gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-yo4 -Wl-yp0x143=0x80 -o keystone.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_scgb
echo compiling for super gameboy & color gameboy
..\..\bin\lcc -Wl-m -Wl-yt3 -Wl-yo4 -Wl-yp0x143=0x80 -yp0x146=0x03 -o keystone.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:cleanup
del *.o
del *.lst
del *.map
del obj_files
