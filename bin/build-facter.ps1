### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
# $facterRef => the git repository to build from
# $facterFork => the git ref to build from
param (
[int] $arch=64,
[int] $cores=2,
[string] $facterRef='origin/master',
[string] $facterFork='git://github.com/puppetlabs/facter'
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition)
. $scriptDirectory\build-helpers.ps1
. $scriptDirectory\windows-env.ps1

Write-Host "Arch=$arch, Cores=$cores"

Write-Host "Starting facter build"

cd $sourceDir

## Download facter and setup build directories
Invoke-External { git clone $facterFork facter }
cd facter
Invoke-External { git checkout $facterRef }
Invoke-External { git submodule update --init --recursive }
mkdir -Force release
cd release

## Build Facter
$cmake_args = @(
  '-G',
  "MinGW Makefiles",
  "-DCMAKE_TOOLCHAIN_FILE=C:/tools/pl-build-tools/pl-build-toolchain.cmake",
  "-DBOOST_STATIC=ON",
  "-DYAMLCPP_STATIC=ON",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\$curlPkg`"",
  "-DCURL_STATIC=ON",
  ".."
)
Invoke-External { cmake $cmake_args }
Invoke-External { mingw32-make -j $cores }
Write-Host "facter Build completed."

## Write out the version that was just built.
Invoke-External { git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force }

## Test the results.
Write-Host "Starting Tests"
Invoke-External { mingw32-make test ARGS=-V }
