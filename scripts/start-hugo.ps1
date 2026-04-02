param(
    [int]$Port = 1313
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$runDir = Join-Path $projectRoot ".run"
$stdoutLog = Join-Path $runDir "hugo-server.out.log"
$stderrLog = Join-Path $runDir "hugo-server.err.log"
$pidFile = Join-Path $runDir "hugo-server.pid"

if (-not (Test-Path $runDir)) {
    New-Item -ItemType Directory -Path $runDir | Out-Null
}

if (Test-Path $pidFile) {
    $existingPidValue = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not [string]::IsNullOrWhiteSpace($existingPidValue)) {
        $existingPid = $existingPidValue.Trim()
        $existingProcess = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($existingProcess) {
            Write-Host "Hugo server is already running in background. PID: $existingPid"
            Write-Host "URL: http://localhost:$Port/"
            exit 0
        }
    }

    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

$hugoCommand = Get-Command hugo -ErrorAction SilentlyContinue
if (-not $hugoCommand) {
    Write-Error "Cannot find 'hugo' in PATH. Please install Hugo or add it to PATH first."
}

$arguments = @(
    "server"
    "--bind", "0.0.0.0"
    "--port", $Port
)

$process = Start-Process `
    -FilePath $hugoCommand.Source `
    -ArgumentList $arguments `
    -WorkingDirectory $projectRoot `
    -WindowStyle Hidden `
    -RedirectStandardOutput $stdoutLog `
    -RedirectStandardError $stderrLog `
    -PassThru

Set-Content -Path $pidFile -Value $process.Id

Write-Host "Hugo server started in background."
Write-Host "PID: $($process.Id)"
Write-Host "URL: http://localhost:$Port/"
Write-Host "STDOUT: $stdoutLog"
Write-Host "STDERR: $stderrLog"
