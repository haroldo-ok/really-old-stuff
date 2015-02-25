@echo off

..\bin\zxb-sms.exe test.zxb --prg_version=0.01 --prg_name="Road Blaster (Road Avenger) demo" --author="Haroldo de Oliveira Pinheiro"


REM Pastes images at end of ROM
copy/b test.sms + "roadblaster-lv-1n2-compressed-f.bin" test.sms