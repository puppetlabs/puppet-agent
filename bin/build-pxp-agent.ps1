### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
param (
[int] $arch=64,
[int] $cores=2,
[string] $pxpagentRef='origin/master'
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. $scriptDirectory\windows-env.ps1

Write-Host "arch=$arch, cores=$cores"

cd $sourceDir

Write-Host "Starting pxp-agent build"

cd pxp-agent
git checkout $pxpagentRef
mkdir -Force release
cd release

$env:PATH += ";" + $toolsDir + "\pcp-client\bin"
Write-Host "Updated Path to $env:PATH"

## Build pxp_agent
$args = @(
  '-G',
  "MinGW Makefiles",
  "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
  "-DBOOST_STATIC=ON",
  "-DYAMLCPP_ROOT=`"$toolsDir\$yamlPkg`"",
  "-DCMAKE_INSTALL_PREFIX=`"$sourceDir`""
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\$curlPkg;$toolsDir\pcp-client`"",
  "-DCURL_STATIC=ON",
  ".."
)
cmake $args
mingw32-make -j $cores
Write-Host "pxp-agent Build completed."

## Write out the version that was just built.
git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
Write-Host "Starting Tests"
mingw32-make test ARGS=-V
