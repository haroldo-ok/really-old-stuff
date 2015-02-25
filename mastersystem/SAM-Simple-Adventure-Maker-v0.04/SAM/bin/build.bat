@echo off
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem ::             SAM Build Script              ::
rem :: Set SAMBINPATH before using ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET WLAPATH=%SAMBINPATH%wla\
SET BMP2TILEPATH=%SAMBINPATH%bmp2tile\

rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Do not edit anything below here unless you know what    ::
rem :: you're doing!                                           ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

rem Cleanup to avoid confusion
if exist object.o del object.o
del *.txt.inc

rem Generate script data
%SAMBINPATH%RestableBuilder.exe Script.list.txt 1
%SAMBINPATH%RestableBuilder.exe Music.list.txt 2

rem Generate image data
%SAMBINPATH%SImResBuilder.exe

rem Compile
"%WLAPATH%wla-z80.exe" -o game.asm object.o

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
del *.txt.inc
