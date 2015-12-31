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
. $scriptDirectory\build-helpers.ps1
. $scriptDirectory\windows-env.ps1

mkdir -Force $toolsDir

Write-Host "arch=$arch, cores=$cores, buildsource=$buildsource"

### Setup, build, and install
## Install Chocolatey, then use it to install required tools.
Function Install-Choco ($pkg, $ver, $opts = "") {
    Write-Host "Installing $pkg $ver from https://www.myget.org/F/puppetlabs"
    try {
        Invoke-External { choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts }
    } catch {
        Write-Host "Error: $_, trying again."
        Invoke-External { choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts }
    }
}

Function Verify-Tool ($name, $versionSwitch = '--version') {
  $path = Get-Command -Name $name | Select -ExpandProperty Path
  Write-Host "`n$name - Path : $path"
  Invoke-External { & $name $versionSwitch }
}

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    & $scriptDirectory\install-chocolatey.ps1
}

Install-Choco 7zip.commandline 9.20.0.20150210

Install-Choco cmake 3.2.2
Install-Choco git.install 2.6.2.20151028
Install-Choco Wix35 $Wix35_VERSION

# For MinGW, we expect specific project defaults
# - win32 threads, as the libpthread library is buggy
# - seh exceptions on 64-bit, to work around an obscure bug loading Ruby in Facter
# These are the defaults on our myget feed.
if ($arch -eq 64) {
  Install-Choco mingw-w64 $mingwVerChoco
} else {
  Install-Choco mingw-w32 $mingwVerChoco @('-x86')
}

cd $toolsDir

Verify-Tool '7za' ''

if ($buildSource) {
  ## Download, build, and install Boost
  Write-Host "Downloading http://downloads.sourceforge.net/boost/$boostVer.7z"
  (New-Object net.webclient).DownloadFile("http://downloads.sourceforge.net/boost/$boostVer.7z", "$toolsDir\$boostVer.7z")
  Invoke-External { & 7za x "${boostVer}.7z" | FIND /V "ing " }
  cd $boostVer

  Invoke-External { .\bootstrap mingw }
  $boost_args = @(
    'toolset=gcc',
    "--build-type=minimal",
    "install",
    '--with-atomic',
    "--with-chrono",
    '--with-container',
    "--with-date_time",
    '--with-exception',
    "--with-filesystem",
    '--with-graph',
    '--with-graph_parallel',
    '--with-iostreams',
    "--with-locale",
    "--with-log",
    '--with-math',
    "--with-program_options",
    "--with-random",
    "--with-regex",
    '--with-serialization',
    '--with-signals',
    "--with-system",
    '--with-test',
    "--with-thread",
    '--with-timer',
    '--with-wave',
    "--prefix=`"$toolsDir\$boostPkg`"",
    "boost.locale.iconv=off"
    "-j$cores"
  )
  Invoke-External { .\b2 $boost_args }
  cd $toolsDir

  ## Download, build, and install yaml-cpp
  Write-Host "Downloading https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz"
  (New-Object net.webclient).DownloadFile("https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz", "$toolsDir\${yamlCppVer}.tar.gz")
  Invoke-External { & 7za x "${yamlCppVer}.tar.gz" }
  Invoke-External { & 7za x "${yamlCppVer}.tar" | FIND /V "ing " }
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
  Invoke-External { cmake $cmake_args }
  Invoke-External { mingw32-make install -j $cores }
  cd $toolsDir

  Write-Host "Downloading http://curl.haxx.se/download/${curlVer}.zip"
  (New-Object net.webclient).DownloadFile("http://curl.haxx.se/download/${curlVer}.zip", "$toolsDir\${curlVer}.zip")
  Invoke-External { & 7za x "${curlVer}.zip" | FIND /V "ing " }
  cd $curlVer

  Invoke-External { mingw32-make mingw32 }
  mkdir -Path $toolsDir\$curlPkg\include
  cp -r include\curl $toolsDir\$curlPkg\include
  mkdir -Path $toolsDir\$curlPkg\lib
  cp lib\libcurl.a $toolsDir\$curlPkg\lib
  cd $toolsDir
} else {
  ## Download and unpack Boost from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z", "$toolsDir\${boostPkg}.7z")
  Invoke-External { & 7za x "${boostPkg}.7z" | FIND /V "ing " }

  ## Download and unpack yaml-cpp from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z", "$toolsDir\${yamlPkg}.7z")
  Invoke-External { & 7za x "${yamlPkg}.7z" | FIND /V "ing " }

  ## Download and unpack curl from a pre-built package in S3
  Write-Host "Downloading https://s3.amazonaws.com/kylo-pl-bucket/${curlPkg}.7z"
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${curlPkg}.7z", "$toolsDir\${curlPkg}.7z")
  Invoke-External { & 7za x "${curlPkg}.7z" | FIND /V "ing " }
}
cd $toolsDir

# Download openssl
Write-Host "Downloading http://buildsources.delivery.puppetlabs.net/windows/openssl/${opensslPkg}.tar.lzma"
(New-Object net.webclient).DownloadFile("http://buildsources.delivery.puppetlabs.net/windows/openssl/${opensslPkg}.tar.lzma", "$toolsDir\${opensslPkg}.tar.lzma")
Invoke-External { & 7za x "$toolsDir\${opensslPkg}.tar.lzma" }
mkdir $toolsDir\${opensslPkg}
cd $toolsDir\${opensslPkg}
Invoke-External { & 7za x "$toolsDir\${opensslPkg}.tar" }

cd $toolsDir
# Download ruby
Write-Host "Downloading http://buildsources.delivery.puppetlabs.net/windows/ruby/${rubyPkg}.7z"
(New-Object net.webclient).DownloadFile("http://buildsources.delivery.puppetlabs.net/windows/ruby/${rubyPkg}.7z", "$toolsDir\${rubyPkg}.7z")
Invoke-External { & 7za x "$toolsDir\${rubyPkg}.7z" | FIND /V "ing " }

$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:PATH = "C:\tools\mingw$arch\bin;" + $env:PATH
@([Environment]::GetFolderPath('ProgramFiles') + "\Git\cmd",
"$toolsDir\$rubyPkg\bin",
"$toolsDir\$opensslPkg\bin") |
  % { $Env:PATH += ";$($_)" }
Write-Host "Updated Path to $env:PATH"

Write-Host "Tool Versions Installed:`n`n"
$PSVersionTable.Keys | % { Write-Host "$_ : $($PSVersionTable[$_])" }
@('git', 'cmake', 'mingw32-make', 'ruby', 'rake', 'openssl') |
  % { Verify-Tool $_ }
