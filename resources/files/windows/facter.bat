@echo off
SETLOCAL

call "%~dp0environment.bat" %0 %*

facter.exe %*
