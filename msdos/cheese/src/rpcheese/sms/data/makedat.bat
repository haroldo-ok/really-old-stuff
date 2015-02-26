del *.pmp
del *.cho

call convmap map0
call convmap map1

call convchs prog2
call convchs prog3
call convchs prog4
call convchs prog5

dir/b *.pmp > datalist.txt
dir/b *.cho >> datalist.txt

makemfs datalist.txt data.mfs

del *.pmp
del *.cho
del datalist.txt