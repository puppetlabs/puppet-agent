@ECHO OFF
REM This is the parent directory of the directory containing this script.
SET "PL_BASEDIR=%~dp0.."
REM Avoid the nasty \..\ littering the paths.
SET "PL_BASEDIR=%PL_BASEDIR:\bin\..=%"

REM Set a fact so we can easily source the environment.bat file in the future.
SET "FACTER_env_windows_installdir=%PL_BASEDIR%"
SET "FACTERDIR=%PL_BASEDIR%"

SET "PATH=%PL_BASEDIR%\bin;%PATH%"

REM Enable rubygems support
SET RUBYOPT=rubygems
REM Now return to the caller.

REM Set SSL variables to ensure trusted locations are used
SET "SSL_CERT_FILE=%PL_BASEDIR%\ssl\cert.pem"
SET "SSL_CERT_DIR=%PL_BASEDIR%\ssl\certs"
