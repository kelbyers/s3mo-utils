@echo off

set MODS=%~dp0
if %MODS:~-1%==\ SET MODS=%MODS:~0,-1%
@echo Mods Location '%MODS%'

for %%G in (%*) do (
	rem extract next archive in list
	call :ONE %%G
)

rem done, so exit (skip over subroutine definitions)
goto EXIT

rem subroutine :ONE
rem extract one archive
:ONE
set SRC=%~1
set NAME=%~n1
set NAME=%NAME:.=_%
set MODDIR=%MODS%\%NAME%
"C:\Users\kel\scoop\shims\7z.exe" e "%SRC%" -o"%MODDIR%"
if ERRORLEVEL 1 goto ERROR
rem open window to folder
%SystemRoot%\explorer.exe "%MODDIR%"
goto :EOF

:ERROR
@echo =================================================
@echo Unexpected error!
@echo =================================================
pause

:EXIT