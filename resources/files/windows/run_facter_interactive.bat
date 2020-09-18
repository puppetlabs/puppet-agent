@echo Running puppet on demand ...
@echo off
SETLOCAL
call "%~dp0environment.bat" %0 %*
@"%PUPPET_DIR%\bin\elevate.exe" "%~dp0facter_interactive.bat"
