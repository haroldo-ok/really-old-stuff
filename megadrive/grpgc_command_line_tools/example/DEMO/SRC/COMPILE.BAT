cd images
call compile.bat
cd..

cd maps
call compile.bat
cd..

cd scripts
call compile.bat
cd..

cd other
call compile.bat
cd..

..\..\..\bin\makegfs gamedata.txt ..\temp\gamedata.gfs
copy ..\..\..\bin\stub.bin ..\bin\demo.bin
..\..\..\bin\applygfs ..\bin\demo.bin 65536 ..\temp\gamedata.gfs