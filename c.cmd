	@echo off
	if '%1' == '' goto noarg

:loop
	if not exist %1 goto failed
	cd /d %1
	if errorlevel 1 goto failed
:next
	shift
	if '%1' == '' goto end
	goto loop

:failed
	cd /d %1*
	if errorlevel 1 goto end
	goto next

:noarg
	cd ..
	goto end

:end
