$ErrorActionPreference = 'Stop'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

function Lint-Dockerfile($Path)
{
  hadolint --ignore DL3008 --ignore DL3018 --ignore DL4000 --ignore DL4001 $Path
}

function Build-Container($Namespace = 'puppet', $Vcs_ref = $(git rev-parse HEAD), $Base = 'ubuntu')
{
  Push-Location (Join-Path (Get-CurrentDirectory) '..')

  $build_date = (Get-Date).ToUniversalTime().ToString('o')
  $docker_args = @(
    '--pull',
    '--build-arg', "vcs_ref=$Vcs_ref",
    '--build-arg', "build_date=$build_date",
    '--file', "puppet-agent-$Base/Dockerfile",
    '--tag', "$Namespace/puppet-agent-${Base}:latest"
  )
  if ($Base -eq 'ubuntu')
  {
    $docker_args += @(
      '--tag', "$Namespace/puppet-agent:latest"
    )
  }

  docker build $docker_args puppet-agent-$Base

  Pop-Location
}
