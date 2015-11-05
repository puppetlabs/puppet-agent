function Invoke-External
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ScriptBlock]
    $cmd
  )

  $Global:LASTEXITCODE = 0
  & $cmd
  if ($LASTEXITCODE -ne 0) { throw ("Terminating.  Last command failed with exit code $LASTEXITCODE") }
}
