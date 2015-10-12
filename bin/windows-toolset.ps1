### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
# $buildSource => Choose whether to download pre-built libraries or build from source
param (
[int] $arch=64,
[int] $cores=2,
[bool] $buildSource=$FALSE
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. $scriptDirectory\windows-env.ps1

mkdir -Force $toolsDir

Write-Host "arch=$arch, cores=$cores, buildsource=$buildsource"

### Setup, build, and install
## Install Chocolatey, then use it to install required tools.
Function Install-Choco ($pkg, $ver, $opts = "") {
    Write-Host "Installing $pkg $ver from https://www.myget.org/F/puppetlabs"
    try {
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    } catch {
        Write-Host "Error: $_, trying again."
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    }
}

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

Install-Choco 7zip.commandline 9.20.0.20150210

Install-Choco cmake 3.2.2
Install-Choco git.install 1.9.5.20150320
Install-Choco Wix35 $Wix35_VERSION

# For MinGW, we expect specific project defaults
# - win32 threads, for Windows Server 2003 support
# - seh exceptions on 64-bit, to work around an obscure bug loading Ruby in Facter
# These are the defaults on our myget feed.
if ($arch -eq 64) {
  Install-Choco ruby 2.1.6
  Install-Choco mingw-w64 $mingwVerChoco
} else {
  Install-Choco ruby 2.1.6 @('-x86')
  Install-Choco mingw-w32 $mingwVerChoco @('-x86')
}
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
if ($arch -eq 32) {
  $env:PATH = "C:\tools\mingw32\bin;" + $env:PATH
}
$env:PATH += [Environment]::GetFolderPath('ProgramFilesX86') + "\Git\cmd"
Write-Host "Updated Path to $env:PATH"

cd $toolsDir

if ($buildSource) {
  ## Download, build, and install Boost
  Write-Host "Downloading http://downloads.sourceforge.net/boost/$boostVer.7z"
  (New-Object net.webclient).DownloadFile("http://downloads.sourceforge.net/boost/$boostVer.7z", "$toolsDir\$boostVer.7z")
  & 7za x "${boostVer}.7z" | FIND /V "ing "
  cd $boostVer

  .\bootstrap mingw
  $boost_args = @(
    'toolset=gcc',
    "--build-type=minimal",
    "install",
    "--with-program_options",
    "--with-system",
    "--with-filesystem",
    "--with-date_time",
    "--with-thread",
    "--with-regex",
    "--with-random",
    "--with-log",
    "--with-locale",
    "--with-chrono",
    '--with-atomic',
    '--with-container',
    '--with-exception',
    '--with-graph',
    '--with-graph_parallel',
    '--with-iostreams',
    '--with-math',
    '--with-serialization',
    '--with-signals',
    '--with-test',
    '--with-timer',
    '--with-wave',
    "--prefix=`"$toolsDir\$boostPkg`"",
    "boost.locale.iconv=off"
    "-j$cores"
  )
  .\b2 $boost_args
  cd $toolsDir

  ## Download, build, and install yaml-cpp
  Write-Host "Downloading https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz"
  (New-Object net.webclient).DownloadFile("https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz", "$toolsDir\${yamlCppVer}.tar.gz")
  & 7za x "${yamlCppVer}.tar.gz"
  & 7za x "${yamlCppVer}.tar" | FIND /V "ing "
  cd $yamlCppVer
  mkdir build
  cd build

  $cmake_args = @(
    '-G',
    "MinGW Makefiles",
    "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
    "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\$yamlPkg`"",
    ".."
  )
  cmake $cmake_args
  mingw32-make install -j $cores
  cd $toolsDir

  Write-Host "Downloading http://curl.haxx.se/download/${curlVer}.zip"
  (New-Object net.webclient).DownloadFile("http://curl.haxx.se/download/${curlVer}.zip", "$toolsDir\${curlVer}.zip")
  & 7za x "${curlVer}.zip" | FIND /V "ing "
  cd $curlVer

  mingw32-make mingw32
  mkdir -Path $toolsDir\$curlPkg\include
  cp -r include\curl $toolsDir\$curlPkg\include
  mkdir -Path $toolsDir\$curlPkg\lib
  cp lib\libcurl.a $toolsDir\$curlPkg\lib
  cd $toolsDir
} else {
  ## Download and unpack Boost from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z", "$toolsDir\${boostPkg}.7z")
  & 7za x "${boostPkg}.7z" | FIND /V "ing "

  ## Download and unpack yaml-cpp from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z", "$toolsDir\${yamlPkg}.7z")
  & 7za x "${yamlPkg}.7z" | FIND /V "ing "

  ## Download and unpack curl from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${curlPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${curlPkg}.7z", "$toolsDir\${curlPkg}.7z")
  & 7za x "${curlPkg}.7z" | FIND /V "ing "
}
cd $toolsDir

# Download openssl
Write-Host "Downloading http://buildsources.delivery.puppetlabs.net/windows/openssl/${opensslPkg}.tar.lzma"
(New-Object net.webclient).DownloadFile("http://buildsources.delivery.puppetlabs.net/windows/openssl/${opensslPkg}.tar.lzma", "$toolsDir\${opensslPkg}.tar.lzma")
& 7za x "$toolsDir\${opensslPkg}.tar.lzma"
mkdir $toolsDir\${opensslPkg}
cd $toolsDir\${opensslPkg}
& 7za x "$toolsDir\${opensslPkg}.tar"

cd $toolsDir
