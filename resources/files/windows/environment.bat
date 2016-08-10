@ECHO OFF
REM This is the parent directory of the directory containing this script.
SET PL_BASEDIR=%~dp0..
REM Avoid the nasty \..\ littering the paths.
SET PL_BASEDIR=%PL_BASEDIR:\bin\..=%

REM Set a fact so we can easily source the environment.bat file in the future.
SET FACTER_env_windows_installdir=%PL_BASEDIR%

SET PUPPET_DIR=%PL_BASEDIR%\puppet
REM Facter will load FACTER_ env vars as facts, so don't use FACTER_DIR
SET FACTERDIR=%PL_BASEDIR%\facter
SET HIERA_DIR=%PL_BASEDIR%\hiera
SET MCOLLECTIVE_DIR=%PL_BASEDIR%\mcollective
SET RUBY_DIR=%PL_BASEDIR%\sys\ruby

SET PATH=%PUPPET_DIR%\bin;%FACTERDIR%\bin;%HIERA_DIR%\bin;%MCOLLECTIVE_DIR%\bin;%PL_BASEDIR%\bin;%RUBY_DIR%\bin;%PL_BASEDIR%\sys\tools\bin;%PATH%

REM Set the RUBY LOAD_PATH using the RUBYLIB environment variable
SET RUBYLIB=%PUPPET_DIR%\lib;%FACTERDIR%\lib;%HIERA_DIR%\lib;%MCOLLECTIVE_DIR%\lib;%RUBYLIB%

REM Translate all slashes to / style to avoid issue #11930
SET RUBYLIB=%RUBYLIB:\=/%


REM Enable rubygems support
SET RUBYOPT=rubygems
REM Now return to the caller.

REM Set SSL variables to ensure trusted locations are used
SET SSL_CERT_FILE=%PL_BASEDIR%\ssl\cert.pem
SET SSL_CERT_DIR=%PL_BASEDIR%\ssl\certs