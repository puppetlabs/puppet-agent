$ErrorActionPreference = 'Stop'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

function Get-ContainerVersion
{
  # shallow repositories need to pull remaining code to `git describe` correctly
  if (Test-Path "$(git rev-parse --git-dir)/shallow")
  {
    git fetch --unshallow
  }

  # tags required for versioning
  git fetch origin 'refs/tags/*:refs/tags/*'
  (git describe) -replace '-.*', ''
}

function Build-Container(
  $Namespace = 'puppet',
  $Version = (Get-ContainerVersion),
  $Vcs_ref = $(git rev-parse HEAD),
  $Base = 'ubuntu')
{
  Push-Location (Join-Path (Get-CurrentDirectory) '..')

  $build_date = (Get-Date).ToUniversalTime().ToString('o')
  $docker_args = @(
    '--pull',
    '--build-arg', "vcs_ref=$Vcs_ref",
    '--build-arg', "build_date=$build_date",
    '--build-arg', "version=$Version",
    '--file', "puppet-agent-$Base/Dockerfile",
    '--tag', "$Namespace/puppet-agent-${Base}:$Version",
    '--memory', '3g'
  )

  $target = "$pwd/.." # default for alpine
  if ($Base -eq 'ubuntu')
  {
    $docker_args += @(
      '--tag', "$Namespace/puppet-agent:$Version"
    )
    $target = 'puppet-agent-ubuntu'
  }

  Write-Host "docker build $docker_args $target"

  docker build $docker_args $target

  Pop-Location
}
