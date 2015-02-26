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

SET WLAPATH=C:\Program Files\WLA DX\

rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Do not edit anything below here unless you know what    ::
rem :: you're doing!                                           ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

rem Cleanup to avoid confusion
if exist object.o del object.o

rem Compile
"%WLAPATH%wla-z80.exe" -o %1 object.o

rem Make linkfile
echo [objects]>linkfile
echo object.o>>linkfile

rem Link
"%WLAPATH%wlalink.exe" -drvs linkfile output.sms

rem Fixup for eSMS
if exist output.sms.sym del output.sms.sym
ren output.sym output.sms.sym

rem Cleanup to avoid mess
if exist linkfile del linkfile
if exist object.o del object.o
