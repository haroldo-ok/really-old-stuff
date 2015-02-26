@echo off

..\..\bin\ProjectBuilder FemtoPong.project.xml
if errorlevel 1 goto error

call generated.build.bat
if errorlevel 1 goto error

cleanup.bat