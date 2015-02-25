..\..\bin\lcc -Wa-l -c -o cosin.o cosin.c
..\..\bin\lcc -Wa-l -c -o melee.o melee.c
pause
..\..\bin\lcc -Wa-l -c -o urq_data.o urq_data.c
pause
..\..\bin\lcc -Wa-l -c -o testship.o testship.c
pause
dir *.o /b/s > obj_files
rem ..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-yp0x143=0x80 -o testship.gb @obj_files
..\..\bin\lcc -Wl-m -Wl-yt2 -Wl-yo4 -Wl-j -o testship.gb @obj_files
del *.o
del *.lst
del *.map
del obj_files
