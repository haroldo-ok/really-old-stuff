@echo off

SET WLAPATH=%SAMBINPATH%wla\
SET BMP2TILEPATH=%SAMBINPATH%bmp2tile\

del "*(tiles).pscompr"
del "*(tile numbers).bin"
del "*(palette).bin"

for %%f in (*.png) do %BMP2TILEPATH%bmp2tile %%f -4bit -tileoffset128 -palsms -savetilespscompr -savetilemapbin -savepalettebin -exit 
