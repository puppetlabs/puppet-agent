@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
ECHO.This version of Ruby has not been built with support for Windows 95/98/Me.
GOTO :EOF
:WinNT
IF EXIST "%~dp0ruby.exe" (
  SET RUBY_EXE_PATH="%~dp0ruby.exe"
) ELSE (
  SET RUBY_EXE_PATH="ruby.exe"
)
@%RUBY_EXE_PATH% "%~dpn0" %*