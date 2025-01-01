@echo off

set MODS=%~dp0
if %MODS:~-1%==\ SET MODS=%MODS:~0,-1%
@echo Mods Location '%MODS%'

set /A COUNT = 0
for %%G in (%*) do set /A COUNT += 1
@echo Mods provided: %COUNT%

for %%G in (%*) do (
	call :ONE %%G
)

goto EXIT

:ONE
set SRC=%~1
set NAME=%~n1
set NAME=%NAME:.=_%

set MODDIR=%MODS%\%NAME%

if EXIST "%MODDIR%" (
	echo "Directory '%NAME%' already exists
	goto EXISTS
)
mkdir "%MODDIR%" || (
	echo "Cannot create mods directory '%NAME%'"
	goto ERROR
)
:EXISTS

move /-Y "%SRC%" "%MODDIR%"
if ERRORLEVEL 1 goto ERROR
rem open window to folder
if %COUNT% LEQ 5 %SystemRoot%\explorer.exe "%MODDIR%"
goto :EOF

:ERROR
@echo =================================================
@echo Unexpected error!
@echo =================================================
pause

:EXIT
pause