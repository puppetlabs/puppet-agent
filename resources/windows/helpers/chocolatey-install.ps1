$ErrorActionPreference = 'Stop'

try {

# variables
$url = 'http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion'
if ($env:TEMP -eq $null) {
  $env:TEMP = Join-Path $env:SystemDrive 'temp'
}
$chocTempDir = Join-Path $env:TEMP "chocolatey"
$tempDir = Join-Path $chocTempDir "chocInstall"
if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
$file = Join-Path $tempDir "chocolatey.zip"
$chocErrorLog = Join-Path $tempDir "chocError.log"

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;

  Write-Output "Querying latest package from $url"
  [xml]$pkg = $downloader.DownloadString($url)
  $url = $pkg.feed.entry.content.src

  Write-Output "Downloading $url to $file"
  $downloader.DownloadFile($url, $file)
}

# download the package
Download-File $url $file

# Unzip the package
Write-Output "Extracting $file to $tempDir..."
$shellApplication = new-object -com shell.application
$zipPackage = $shellApplication.NameSpace($file)
$destinationFolder = $shellApplication.NameSpace($tempDir)
$destinationFolder.CopyHere($zipPackage.Items(),0x10)

# call chocolatey install
Write-Output "Installing chocolatey on this machine"
$toolsFolder = Join-Path $tempDir "tools"
$chocInstallPS1 = Join-Path $toolsFolder "chocolateyInstall.ps1"

if ($PSVersionTable.psversion.Major -gt 2) {
  & $chocInstallPS1
}
else {
  $output = Invoke-Expression $chocInstallPS1
  $output
  write-output "Any errors that occured during install or upgrade are logged here: $chocoErrorLog"
  $error | out-file $chocErrorLog
}

Write-Output 'Ensuring chocolatey commands are on the path'
$chocInstallVariableName = "ChocolateyInstall"
$chocoPath = [Environment]::GetEnvironmentVariable($chocInstallVariableName, [System.EnvironmentVariableTarget]::User)
if ($chocoPath -eq $null -or $chocoPath -eq '') {
  $chocoPath = 'C:\ProgramData\Chocolatey'
}

$chocoBinPath = Join-Path $chocoPath 'bin'

if ($($env:Path).ToLower().Contains($($chocoBinPath).ToLower()) -eq $false) {
  $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
}

Write-Output 'Ensuring chocolatey.nupkg is in the lib folder'
$chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
$nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
if (![System.IO.Directory]::Exists($chocoPkgDir)) { [System.IO.Directory]::CreateDirectory($chocoPkgDir); }
Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue

}
catch
{
  Write-Host "$($_.Exception.Message)"
  exit 1
}
