[CmdletBinding()]
param(
    [switch]$SkipPlan
)

$ErrorActionPreference = 'Stop'
$varsPath = Join-Path $PSScriptRoot 'terraform.tfvars'

# Resolve prerequisites before modifying the configuration.
if (-not $SkipPlan) {
    $terraformCommand = Get-Command terraform -ErrorAction Stop
}

$original = [System.IO.File]::ReadAllText($varsPath)
$assignment = [regex]'(?m)^(?<prefix>[ \t]*admin_ip[ \t]*=[ \t]*)"(?<cidr>[^"\r\n]*)"(?<suffix>[ \t]*(?:(?:#|//)[^\r\n]*)?)\r?$'
$matchesFound = $assignment.Matches($original)
if ($matchesFound.Count -ne 1) {
    throw 'Expected exactly one quoted admin_ip assignment in terraform.tfvars. File unchanged.'
}

$publicIp = ([string](Invoke-RestMethod -Uri 'https://checkip.amazonaws.com' -TimeoutSec 15)).Trim()
$parsedIp = $null
if ($publicIp -notmatch '^\d{1,3}(\.\d{1,3}){3}$' -or
    -not [System.Net.IPAddress]::TryParse($publicIp, [ref]$parsedIp) -or
    $parsedIp.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
    throw 'IP lookup did not return a valid IPv4 address. File unchanged.'
}

$newCidr = "$($parsedIp.ToString())/32"
$oldCidr = $matchesFound[0].Groups['cidr']
if ($oldCidr.Value -eq $newCidr) {
    Write-Host "admin_ip is already $newCidr. File unchanged."
} else {
    # Replace only the value; preserve comments, whitespace, newlines, and UTF-8 BOM.
    $updated = $original.Remove($oldCidr.Index, $oldCidr.Length).Insert($oldCidr.Index, $newCidr)
    $bytes = [System.IO.File]::ReadAllBytes($varsPath)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
    $encoding = [System.Text.UTF8Encoding]::new($hasBom)
    [System.IO.File]::WriteAllText($varsPath, $updated, $encoding)
    Write-Host "Updated admin_ip: $($oldCidr.Value) -> $newCidr"
}

if (-not $SkipPlan) {
    & $terraformCommand.Source "-chdir=$PSScriptRoot" plan -input=false -lock-timeout=60s
    if ($LASTEXITCODE -ne 0) {
        throw 'terraform plan failed. The local admin_ip is updated; AWS was not changed.'
    }
}

Write-Host "AWS has not been changed. Review the plan, then run: terraform -chdir=`"$PSScriptRoot`" apply"
