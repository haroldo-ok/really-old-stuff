@echo off
echo texline.o
..\..\bin\lcc -Wa-l -c -o texline.o texline.s
echo speedup.o
..\..\bin\lcc -Wa-l -c -o speedup.o speedup.s
echo textures.o
..\..\bin\lcc -Wa-l -Wf-bo2 -c -o textures.o textures.c
echo raycaste.o
..\..\bin\lcc -Wa-l -Wf-bo1 -c -o raycaste.o raycaste.c
echo example.o
..\..\bin\lcc -Wa-l -c -o example.o example.c
pause
dir *.o /b/s > obj_files
if "%1" == "sgb" goto make_sgb
if "%1" == "cgb" goto make_cgb
if "%1" == "scgb" goto make_scgb

:make_standard
echo linking for standard gameboy
..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-j -o example.gb @obj_files
echo cleaning up
goto cleanup

:make_sgb
echo linking for super gameboy
..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-yp0x146=0x03 -o example.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_cgb
echo linking for color gameboy
..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-yp0x143=0x80 -o example.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:make_cgb
echo linking for super gameboy & color gameboy
..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-yp0x143=0x80 -yp0x146=0x03 -o example.gb @obj_files
echo cleaning up
del *.sym
goto cleanup

:cleanup
del *.o
del *.lst
del *.map
del obj_files
