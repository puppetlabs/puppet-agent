@echo off
SETLOCAL

call "%~dp0environment.bat" %0 %*

"%PUPPET_DIR%\bin\ruby.exe" -S -- "%PUPPET_DIR%\bin\facter" %*
