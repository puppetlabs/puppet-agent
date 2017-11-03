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
Function Install-Choco ($pkg, $ver, $source = "http://nexus.delivery.puppetlabs.net/service/local/nuget/nuget-pl-build-tools/", $opts = "") {
    Write-Host "Installing $pkg $ver from $source"
    try {
        Invoke-External { choco install -y $pkg -version $ver -source $source -debug $opts }
    } catch {
        Write-Host "Error: $_, trying again."
        Invoke-External { choco install -y $pkg -version $ver -source $source -debug $opts }
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

$nugetTempFeed = 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/'

Install-Choco 7zip.commandline 9.20.0.20150210 $nugetTempFeed

Install-Choco cmake 3.2.2 $nugetTempFeed
Install-Choco git.install 2.6.2.20151028 $nugetTempFeed
Install-Choco Wix310 $WIX_VERSION $nugetTempFeed

# For MinGW, we expect specific project defaults
# - win32 threads, as the libpthread library is buggy
# - seh exceptions on 64-bit, to work around an obscure bug loading Ruby in Facter
if ($arch -eq 64) {
  Install-Choco mingw-w64 $mingwVerChoco $nugetTempFeed
  Install-Choco pl-boost-x64 1.58.0.2
  Install-Choco pl-toolchain-x64 2015.12.01.1
  Install-Choco pl-yaml-cpp-x64 0.5.1.2
} else {
  Install-Choco mingw-w32 $mingwVerChoco  $nugetTempFeed @('-x86')
  Install-Choco pl-boost-x86 1.58.0.2
  Install-Choco pl-toolchain-x86 2015.12.01.1
  Install-Choco pl-yaml-cpp-x86 0.5.1.2
}

cd $toolsDir

Verify-Tool '7za' ''

$buildSourcesURL = "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows"
$s3URL = "https://s3.amazonaws.com/kylo-pl-bucket"

if ($buildSource) {
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
  ## Download and unpack curl from a pre-built package in S3
  Write-Host "Downloading $s3URL/${curlPkg}.7z"
  (New-Object net.webclient).DownloadFile("$s3URL/${curlPkg}.7z", "$toolsDir\${curlPkg}.7z")
  Invoke-External { & 7za x "${curlPkg}.7z" | FIND /V "ing " }
}
cd $toolsDir

# Download openssl
Write-Host "Downloading $buildSourcesURL/openssl/${opensslPkg}.tar.lzma"
(New-Object net.webclient).DownloadFile("$buildSourcesURL/openssl/${opensslPkg}.tar.lzma", "$toolsDir\${opensslPkg}.tar.lzma")
Invoke-External { & 7za x "$toolsDir\${opensslPkg}.tar.lzma" }
mkdir $toolsDir\${opensslPkg}
cd $toolsDir\${opensslPkg}
Invoke-External { & 7za x "$toolsDir\${opensslPkg}.tar" }

cd $toolsDir
# Download ruby
Write-Host "Downloading $buildSourcesURL/ruby/${rubyPkg}.7z"
(New-Object net.webclient).DownloadFile("$buildSourcesURL/ruby/${rubyPkg}.7z", "$toolsDir\${rubyPkg}.7z")
Invoke-External { & 7za x "$toolsDir\${rubyPkg}.7z" | FIND /V "ing " }

Set-Path

Write-Host "Tool Versions Installed:`n`n"
$PSVersionTable.Keys | % { Write-Host "$_ : $($PSVersionTable[$_])" }
@('git', 'cmake', 'mingw32-make', 'ruby', 'rake', 'openssl') |
  % { Verify-Tool $_ }
