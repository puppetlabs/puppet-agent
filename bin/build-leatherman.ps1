### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
# $leathermanRef => the git repository to build from
# $leathermanFork => the git ref to build from
param (
[int] $arch=64,
[int] $cores=2,
[string] $leathermanRef='origin/master',
[string] $leathermanFork='git://github.com/puppetlabs/leatherman'
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. $scriptDirectory\build-helpers.ps1
. $scriptDirectory\windows-env.ps1

Write-Host "arch=$arch, cores=$cores"

Write-Host "Starting leatherman build"

cd $sourceDir

## Download leatherman and setup build directories
Invoke-External { git clone $leathermanFork leatherman }
cd leatherman
Invoke-External { git checkout $leathermanRef }
mkdir -Force release
cd release

## Build leatherman
$cmake_args = @(
  '-G',
  "MinGW Makefiles",
  "-DCMAKE_TOOLCHAIN_FILE=C:/tools/pl-build-tools/pl-build-toolchain.cmake",
  "-DBOOST_STATIC=ON",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\$curlPkg;$toolsDir\$opensslPkg;$toolsDir\$rubyPkg`"",
  "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\leatherman`"",
  "-DCURL_STATIC=ON",
  ".."
)
Invoke-External { cmake $cmake_args }
Invoke-External { mingw32-make -j $cores }
Invoke-External { mingw32-make install }

Write-Host "leatherman Build completed."
## Write out the version that was just built.
#git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
Write-Host "Starting Tests"
Invoke-External { mingw32-make test ARGS=-V }
