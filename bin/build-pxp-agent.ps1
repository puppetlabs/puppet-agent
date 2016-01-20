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
cd $sourceDir\pxp-agent

Write-Host "Starting pxp-agent build"

mkdir -Force release
cd release

$env:PATH += ";" + $toolsDir + "\pcp-client\bin"
Write-Host "Updated Path to $env:PATH"

## Build pxp_agent
$cmake_args = @(
  '-G',
  "MinGW Makefiles",
  "-DCMAKE_TOOLCHAIN_FILE=C:/tools/pl-build-tools/pl-build-toolchain.cmake",
  "-DBOOST_STATIC=ON",
  "-DCMAKE_INSTALL_PREFIX=`"$sourceDir`"",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\$curlPkg;$toolsDir\$opensslPkg;$toolsDir\$rubyPkg;$toolsDir\pcp-client;$toolsDir\leatherman`"",
  "-DCURL_STATIC=ON",
  ".."
)
Invoke-External { cmake $cmake_args }
Invoke-External { mingw32-make -j $cores }
Write-Host "pxp-agent Build completed."

## Write out the version that was just built.
Invoke-External { git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force }

## Test the results.
Write-Host "Starting Tests"
Invoke-External { mingw32-make test ARGS=-V }
