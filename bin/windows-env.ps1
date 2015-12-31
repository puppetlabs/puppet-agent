
$ErrorActionPreference = 'Stop'

# Ensure TEMP directory is set and exists. Git.install can fail otherwise.
if ($env:TEMP -eq $null) {
  $env:TEMP = Join-Path $env:SystemDrive 'temp'
  Write-Host "TEMP is null, setting to $env:TEMP"
}
if (!(Test-Path $env:TEMP)) {
  mkdir -Path $env:TEMP
  Write-Host "Created Temp Directory $env:TEMP"
}

if ($env:Path -eq $null) {
    Write-Host "Path is null?"
}

### Configuration
## Setup the working directory
$sourceDir=$pwd

$toolsDir="${sourceDir}\deps"

$mingwVerNum = "4.8.3"
$mingwVerChoco = $mingwVerNum
$mingwThreads = "win32"
if ($arch -eq 64) {
  $mingwExceptions = "seh"
  $mingwArch = "x86_64"
  $opensslArch = "x64"
  $rubyArch = "x64"
} else {
  $mingwExceptions = "sjlj"
  $mingwArch = "i686"
  $opensslArch = "x86"
  $rubyArch = "i386"
}
$mingwVer = "${mingwArch}_mingw-w64_${mingwVerNum}_${mingwThreads}_${mingwExceptions}"

$rubyPkg = "ruby-2.1.7-${rubyArch}-mingw32"

$opensslPkg = "openssl-1.0.2e-${opensslArch}-windows"

$boostVer = "boost_1_58_0"
$boostPkg = "${boostVer}-${mingwVer}"

$yamlCppVer = "yaml-cpp-0.5.1"
$yamlPkg = "${yamlCppVer}-${mingwVer}"

$curlVer = "curl-7.42.1"
$curlPkg = "${curlVer}-${mingwVer}"

$Wix35_VERSION = '3.5.2519.20130612'

$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:PATH = "C:\tools\mingw$arch\bin;" + $env:PATH
@([Environment]::GetFolderPath('ProgramFiles') + "\Git\cmd",
"$toolsDir\$rubyPkg\bin",
"$toolsDir\$opensslPkg\bin") |
 % { $Env:PATH += ";$($_)" }
Write-Host "Updated Path to $env:PATH"
