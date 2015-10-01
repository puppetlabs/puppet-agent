### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
param (
[int] $arch=64,
[int] $cores=2,
[string] $cpppcpclientRef='origin/master'
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. $scriptDirectory\windows-env.ps1

Write-Host "arch=$arch, cores=$cores"

cd $sourceDir

Write-Host "Starting cpp-pcp-client build"

cd cpp-pcp-client
git checkout $cpppcpclientRef
mkdir -Force release
cd release

## Build pxp_agent
$args = @(
  '-G',
  "MinGW Makefiles",
  "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
  "-DBOOST_STATIC=ON",
  "-DYAMLCPP_ROOT=`"$toolsDir\$yamlPkg`"",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\pcp-client`"",
  "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\pcp-client`""
  "-DCURL_STATIC=ON",
  ".."
)
cmake $args
mingw32-make -j $cores
mingw32-make install

Write-Host "cpp-pcp-client Build completed."
## Write out the version that was just built.
#git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
Write-Host "Starting Tests"
mingw32-make test ARGS=-V
