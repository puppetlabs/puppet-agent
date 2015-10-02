### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
# $buildSource => Choose whether to download pre-built libraries or build from source
# $facterRef => the git repository to build from
# $facterFork => the git ref to build from
param (
[int] $arch=64,
[int] $cores=2,
[bool] $buildSource=$FALSE,
[string] $facterRef='origin/master',
[string] $facterFork='git://github.com/puppetlabs/facter'
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition)
. $scriptDirectory\windows-env.ps1

echo $arch
echo $cores
echo $buildSource

### Setup, build, and install
## Install Chocolatey, then use it to install required tools.
Function Install-Choco ($pkg, $ver, $opts = "") {
    echo "Installing $pkg $ver from https://www.myget.org/F/puppetlabs"
    try {
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    } catch {
        echo "Error: $_, trying again."
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    }
}

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
Install-Choco 7zip.commandline 9.20.0.20150210
Install-Choco cmake 3.2.2
Install-Choco git.install 1.9.5.20150320

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

cd $sourceDir

## Download facter and setup build directories
git clone $facterFork facter
cd facter
git checkout $facterRef
git submodule update --init --recursive
mkdir -Force release
cd release
$buildDir=$pwd
$toolsDir="${sourceDir}\deps"
mkdir -Force $toolsDir
cd $toolsDir

if ($buildSource) {
  ## Download, build, and install Boost
  (New-Object net.webclient).DownloadFile("http://downloads.sourceforge.net/boost/$boostVer.7z", "$toolsDir\$boostVer.7z")
  & 7za x "${boostVer}.7z" | FIND /V "ing "
  cd $boostVer

  .\bootstrap mingw
  $args = @(
    'toolset=gcc',
    "--build-type=minimal",
    "install",
    "--with-program_options",
    "--with-system",
    "--with-filesystem",
    "--with-date_time",
    "--with-thread",
    "--with-regex",
    "--with-log",
    "--with-locale",
    "--with-chrono",
    "--prefix=`"$toolsDir\$boostPkg`"",
    "boost.locale.iconv=off"
    "-j$cores"
  )
  .\b2 $args
  cd $toolsDir

  ## Download, build, and install yaml-cpp
  (New-Object net.webclient).DownloadFile("https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz", "$toolsDir\${yamlCppVer}.tar.gz")
  & 7za x "${yamlCppVer}.tar.gz"
  & 7za x "${yamlCppVer}.tar" | FIND /V "ing "
  cd $yamlCppVer
  mkdir build
  cd build

  $args = @(
    '-G',
    "MinGW Makefiles",
    "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
    "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\$yamlPkg`"",
    ".."
  )
  cmake $args
  mingw32-make install -j $cores
  cd $toolsDir

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
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z", "$toolsDir\${boostPkg}.7z")
  & 7za x "${boostPkg}.7z" | FIND /V "ing "

  ## Download and unpack yaml-cpp from a pre-built package in S3
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z", "$toolsDir\${yamlPkg}.7z")
  & 7za x "${yamlPkg}.7z" | FIND /V "ing "

  ## Download and unpack curl from a pre-built package in S3
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${curlPkg}.7z", "$toolsDir\${curlPkg}.7z")
  & 7za x "${curlPkg}.7z" | FIND /V "ing "
}

## Build Facter
cd $buildDir
$args = @(
  '-G',
  "MinGW Makefiles",
  "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
  "-DBOOST_STATIC=ON",
  "-DYAMLCPP_ROOT=`"$toolsDir\$yamlPkg`"",
  "-DCMAKE_PREFIX_PATH=`"$toolsDir\$curlPkg`"",
  "-DCURL_STATIC=ON",
  ".."
)
cmake $args
mingw32-make -j $cores

## Write out the version that was just built.
git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
mingw32-make test ARGS=-V
