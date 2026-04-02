$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$runDir = Join-Path $projectRoot ".run"
$pidFile = Join-Path $runDir "hugo-server.pid"

if (-not (Test-Path $pidFile)) {
    Write-Host "No running Hugo server PID file found."
    exit 0
}

$serverPidValue = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($serverPidValue)) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "PID file was empty and has been cleaned up."
    exit 0
}

$serverPid = $serverPidValue.Trim()
$process = Get-Process -Id $serverPid -ErrorAction SilentlyContinue
if (-not $process) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "Hugo server process was not running. PID file has been cleaned up."
    exit 0
}

Stop-Process -Id $serverPid
Remove-Item $pidFile -ErrorAction SilentlyContinue

Write-Host "Hugo server stopped. PID: $serverPid"
