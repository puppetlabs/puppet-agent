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

Install-Choco 7zip.commandline 9.20.0.20150210 'https://www.myget.org/F/puppetlabs'

Install-Choco cmake 3.2.2 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/'
Install-Choco git.install 2.6.2.20151028 'https://www.myget.org/F/puppetlabs'
Install-Choco Wix35 $Wix35_VERSION 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/'

# For MinGW, we expect specific project defaults
# - win32 threads, as the libpthread library is buggy
# - seh exceptions on 64-bit, to work around an obscure bug loading Ruby in Facter
# These are the defaults on our myget feed.
if ($arch -eq 64) {
  Install-Choco ruby 2.1.6 'https://www.myget.org/F/puppetlabs'
  Install-Choco mingw-w64 $mingwVerChoco 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/'
  Install-Choco pl-boost-x64 1.58.0.2
  Install-Choco pl-toolchain-x64 2015.12.01.1
  Install-Choco pl-yaml-cpp-x64 0.5.1.2
} else {
  Install-Choco ruby 2.1.6 'https://www.myget.org/F/puppetlabs' @('-x86')
  Install-Choco mingw-w32 $mingwVerChoco 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/' @('-x86')
  Install-Choco pl-boost-x86 1.58.0.2
  Install-Choco pl-toolchain-x86 2015.12.01.1
  Install-Choco pl-yaml-cpp-x86 0.5.1.2
}
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
if ($arch -eq 32) {
  $env:PATH = "C:\tools\mingw32\bin;" + $env:PATH
}
$env:PATH += [Environment]::GetFolderPath('ProgramFiles') + "\Git\cmd"
Write-Host "Updated Path to $env:PATH"

cd $toolsDir

Write-Host "Tool Versions Installed:`n`n"
$PSVersionTable.Keys | % { Write-Host "$_ : $($PSVersionTable[$_])" }
@('git', 'cmake', 'mingw32-make', 'ruby', 'rake') |
  % { Verify-Tool $_ }
Verify-Tool '7za' ''

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
