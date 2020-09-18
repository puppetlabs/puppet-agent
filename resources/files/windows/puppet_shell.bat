@ECHO OFF

call "%~dp0environment.bat" %0 %*

REM Prepend puppet's bindirs to the PATH
SET PATH=%PUPPET_DIR%\bin;%PL_BASEDIR%\bin;%PATH%

REM Display Ruby version
ruby.exe -v
