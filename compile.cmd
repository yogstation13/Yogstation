@echo off

IF DEFINED ProgramFiles(x86) (
	SET "_dmexec=C:\Program Files (x86)\BYOND\bin\dm.exe"
) ELSE (
	SET "_dmexec=C:\Program Files\BYOND\bin\dm.exe"
)

ECHO Attempting to look for %_dmexec%
if exist "%_dmexec%" (
	ECHO DM executable found!
) else (
	ECHO DM executable not found.Exiting.....
	GOTO end
)

"%_dmexec%" yogstation.dme

:end
pause
