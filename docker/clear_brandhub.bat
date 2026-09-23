@echo off
setlocal
set "BRANDHUB_CLEANUP_FILE=%~f0"
set "BRANDHUB_CLEANUP_MODE=%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$raw = [IO.File]::ReadAllText($env:BRANDHUB_CLEANUP_FILE); $body = ($raw -split '(?m)^# POWERSHELL_BODY\r?$', 2)[1]; & ([scriptblock]::Create($body))"
exit /b %errorlevel%
# POWERSHELL_BODY
$ErrorActionPreference = 'Stop'
try {
    $dryRun = $env:BRANDHUB_CLEANUP_MODE -eq '--dry-run'
    if ($env:BRANDHUB_CLEANUP_MODE -and -not $dryRun) {
        throw 'Usage: clear_brandhub.bat [--dry-run]'
    }
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker CLI not found.' }
    function Invoke-Docker {
        param([string[]]$DockerArgs)
        $result = & docker @DockerArgs
        if ($LASTEXITCODE -ne 0) { throw ('Docker command failed: ' + ($DockerArgs -join ' ')) }
        return $result
    }
    function Is-BrandHub([string]$value) { return $value -match '^brandhub($|[-_])' }
    function Get-OwnedResources([string]$kind, [string[]]$listArgs) {
        $ids = @(Invoke-Docker -DockerArgs $listArgs)
        foreach ($id in $ids) {
            $item = (Invoke-Docker -DockerArgs @($kind, 'inspect', $id) | Out-String | ConvertFrom-Json)[0]
            $labels = $item.Labels
            if ($kind -eq 'container') { $labels = $item.Config.Labels }
            $name = $item.Name -replace '^/', ''
            if ((Is-BrandHub $name) -or (Is-BrandHub $labels.'com.docker.compose.project')) {
                [pscustomobject]@{ Kind = $kind; Name = $name; Id = $id }
            }
        }
    }
    $null = Invoke-Docker -DockerArgs @('info', '--format', '{{.ServerVersion}}')
    $targets = @()
    $targets += @(Get-OwnedResources 'container' @('container', 'ls', '-aq'))
    $targets += @(Get-OwnedResources 'network' @('network', 'ls', '-q'))
    $targets += @(Get-OwnedResources 'volume' @('volume', 'ls', '-q'))
    # Remove BrandHub repository tags only, not shared upstream images or global cache.
    $imageRefs = @(Invoke-Docker -DockerArgs @('image', 'ls', '--format', '{{.Repository}}:{{.Tag}}'))
    foreach ($ref in ($imageRefs | Sort-Object -Unique)) {
        $repo = $ref -replace ':[^:]+$', ''
        $owned = @($repo -split '/' | Where-Object { Is-BrandHub $_ }).Count -gt 0
        if ($owned -and $ref -notmatch ':<none>$') {
            $targets += [pscustomobject]@{ Kind = 'image'; Name = $ref; Id = $ref }
        }
    }
    # Previous app builds may have lost their repository tag after a rebuild.
    # Compose project labels establish ownership even for dangling images.
    $dangling = @(Invoke-Docker -DockerArgs @('image', 'ls', '-q', '--filter', 'dangling=true'))
    foreach ($id in ($dangling | Sort-Object -Unique)) {
        $item = (Invoke-Docker -DockerArgs @('image', 'inspect', $id) | Out-String | ConvertFrom-Json)[0]
        if (Is-BrandHub $item.Config.Labels.'com.docker.compose.project') {
            $targets += [pscustomobject]@{ Kind = 'image'; Name = $id; Id = $id }
        }
    }
    if ($targets.Count -eq 0) { Write-Host 'No BrandHub resources found.'; exit 0 }
    $targets | Select-Object Kind, Name | Format-Table -AutoSize | Out-Host
    if ($dryRun) { Write-Host 'Preview only. Nothing deleted.'; exit 0 }
    Write-Host 'WARNING: ALL listed BrandHub containers and database volumes will be deleted permanently.' -ForegroundColor Yellow
    $answer = Read-Host 'Type DELETE to continue'
    if ($answer -cne 'DELETE') { Write-Host 'Cancelled. Nothing deleted.'; exit 0 }
    $failures = @()
    foreach ($target in $targets) {
        Write-Host ('Removing ' + $target.Kind + ': ' + $target.Name)
        $argsToRun = @($target.Kind, 'rm')
        if ($target.Kind -eq 'container') { $argsToRun += '-f' }
        # Never force-delete volumes/networks/images still used by other containers.
        $argsToRun += $target.Id
        try {
            $null = Invoke-Docker -DockerArgs $argsToRun
        } catch {
            $failures += ($target.Kind + ': ' + $target.Name)
            Write-Warning $_.Exception.Message
        }
    }
    if ($failures.Count -gt 0) {
        throw ('Cleanup incomplete. These resources could not be removed: ' + ($failures -join ', '))
    }
    Write-Host 'BrandHub cleanup completed. Old container names, networks and volumes are cleared.'
    Write-Host 'You can now run .\run_dev.bat.'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
