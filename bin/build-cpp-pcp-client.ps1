### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
param (
[int] $arch=64,
[int] $cores=2
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. $scriptDirectory\build-helpers.ps1
. $scriptDirectory\windows-env.ps1

Write-Host "arch=$arch, cores=$cores"

# assumes source has already been rsync'd here since its a private repo
cd $sourceDir\cpp-pcp-client

Write-Host "Starting cpp-pcp-client build"

mkdir -Force release
cd release

## Build pxp_agent
$cmake_args = @(
  '-G',
  "MinGW Makefiles",
  "-DCMAKE_TOOLCHAIN_FILE=C:/tools/pl-build-tools/pl-build-toolchain.cmake",
  "-DBOOST_STATIC=ON",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\pcp-client;$toolsDir\$opensslPkg`"",
  "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\pcp-client`"",
  "-DCURL_STATIC=ON",
  ".."
)
Invoke-External { cmake $cmake_args }
Invoke-External { mingw32-make -j $cores }
Invoke-External { mingw32-make install }

Write-Host "cpp-pcp-client Build completed."
## Write out the version that was just built.
#git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
Write-Host "Starting Tests"
Invoke-External { mingw32-make test ARGS=-V }
