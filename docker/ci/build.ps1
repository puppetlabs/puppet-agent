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

function Lint-Dockerfile($Path)
{
  hadolint --ignore DL3008 --ignore DL3018 --ignore DL4000 --ignore DL4001 $Path
}

function Build-Container(
  $Namespace = 'puppet',
  $Version = (Get-ContainerVersion),
  $Vcs_ref = $(git rev-parse HEAD),
  $Base = 'ubuntu')
{
  Push-Location (Join-Path (Get-CurrentDirectory) '..')

  $build_date = (Get-Date).ToUniversalTime().ToString('o')
  $subdir = if ($Base -eq 'alpine') { 'windows-build' } else { '' }
  $docker_args = @(
    '--pull',
    '--build-arg', "vcs_ref=$Vcs_ref",
    '--build-arg', "build_date=$build_date",
    '--build-arg', "version=$Version",
    '--file', "puppet-agent-$Base/$subdir/Dockerfile",
    '--tag', "$Namespace/puppet-agent-${Base}:$Version"
  )
  if ($Base -eq 'ubuntu')
  {
    $docker_args += @(
      '--tag', "$Namespace/puppet-agent:$Version"
    )
  }
  else # alpine
  {
    $docker_args += '--memory 3g'

    # fake multistage builds for Windows since LCOW doesn't support yet
    docker build --pull `
      --file puppet-agent-alpine/windows-build/Dockerfile.build `
      --tag $Namespace/puppet-agent-alpine:build `
      .

    docker run -v (Join-Path (Get-CurrentDirectory) 'output'):/srv `
      --rm puppet/puppet-agent-alpine:build `
      cp -a /usr/lib/ruby/vendor_ruby/facter.rb `
      /etc/puppetlabs `
      /usr/local/share `
      /usr/local/bin `
      /usr/local/lib `
      /usr/lib/ruby/gems `
      /srv
  }

  docker build $docker_args puppet-agent-$Base

  Pop-Location
}

function Invoke-ContainerTest($Name, $Namespace = 'puppet', $Version = (Get-ContainerVersion))
{
  Push-Location (Join-Path (Get-CurrentDirectory) '..')

  bundle install --path .bundle/gems
  $ENV:PUPPET_TEST_DOCKER_IMAGE = "$Namespace/${Name}:$Version"
  Write-Host "Testing against image: ${ENV:PUPPET_TEST_DOCKER_IMAGE}"
  bundle exec rspec --version
  bundle exec rspec spec

  Pop-Location
}

# removes temporary layers / containers / images used during builds
# removes $Namespace/$Name images > 14 days old by default
function Clear-ContainerBuilds(
  $Namespace = 'puppet',
  $Name,
  $OlderThan = [DateTime]::Now.Subtract([TimeSpan]::FromDays(14)),
  [Switch]
  $Force = $false
)
{
  Write-Output 'Pruning Containers'
  docker container prune --force

  # this provides example data which ConvertFrom-String infers parsing structure with
  $template = @'
{Version*:10.2.3*} {ID:5b84704c1d01} {[DateTime]Created:2019-02-07 18:24:51} +0000 GMT
{Version*:latest} {ID:0123456789ab} {[DateTime]Created:2019-01-29 00:05:33} +0000 GMT
'@
  $output = docker images --filter=reference="$Namespace/${Name}" --format "{{.Tag}} {{.ID}} {{.CreatedAt}}"
  Write-Output @"

Found $Namespace/${Name} images:
$($output | Out-String)

"@

  if ($output -eq $null) { return }

  Write-Output "Filtering removal candidates..."
  # docker image prune supports filter until= but not repository like 'puppetlabs/foo'
  # must use label= style filtering which is a bit more inconvenient
  # that output is also not user-friendly!
  # engine doesn't maintain "last used" or "last pulled" metadata, which would be more useful
  # https://github.com/moby/moby/issues/4237
  $output |
    ConvertFrom-String -TemplateContent $template |
    ? { $_.Created -lt $OlderThan } |
    # ensure 'latest' are listed first
    Sort-Object -Property Version -Descending |
    % {
      Write-Output "Removing Old $Namespace/${Name} Image $($_.Version) ($($_.ID)) Created On $($_.Created)"
      $forcecli = if ($Force) { '-f' } else { '' }
      docker image rm $_.ID $forcecli
    }

  Write-Output "`nPruning Dangling Images"
  docker image prune --filter "dangling=true" --force
}
