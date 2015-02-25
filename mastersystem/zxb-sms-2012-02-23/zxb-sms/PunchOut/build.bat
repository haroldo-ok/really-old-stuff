@echo off

..\bin\zxb-sms.exe test.zxb


REM Pastes images at end of ROM
copy/b test.sms + "punchout_miketyson_sheet_2a (tiles).bin" test.sms