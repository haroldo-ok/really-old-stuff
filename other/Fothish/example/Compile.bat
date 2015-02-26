@echo off
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem ::             WLA DX compiling batch file v2              ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: You have to edit this file before it will work!         ::
rem :: Edit the line below, starting with "SET WLAPATH=", so   ::
rem :: the bit after the = is the directory where you've put   ::
rem :: WLA DX. It *must* have a backslash "\" at the end but   ::
rem :: *not* contain any quotes. It's not a problem to have    ::
rem :: long filenames with spaces. If you put WLA DX in        ::
rem :: C:\Program Files\WLA DX\ then of course you don't need  ::
rem :: to edit it.                                             ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET SAMBINPATH=..\bin\

call %SAMBINPATH%convtiles.bat
call %SAMBINPATH%build.bat
call %SAMBINPATH%cleanup.bat

pause