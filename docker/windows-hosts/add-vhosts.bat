:: Copier la liste des vhosts configurée dans hosts
@echo off
set ip=127.0.0.1
set host=pop.loc

echo Inserting vhosts...

call >nul find /C "%host%" %SystemRoot%\system32\drivers\etc\hosts && (
	call echo vhost %host% was found. Nothing to insert
) || (
	call echo vhost %host% was not found. It will be inserted to hosts
	echo. >> %SystemRoot%\system32\drivers\etc\hosts
	call echo %ip% %host% >> %SystemRoot%\system32\drivers\etc\hosts
)

echo Done. Press any key to exit.
pause >nul