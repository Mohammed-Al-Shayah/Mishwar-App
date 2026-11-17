param(
    [Parameter(Mandatory = $true)]
    [System.Net.IPAddress]$HostIp
)

$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    & fvm flutter build apk --debug "--dart-define=EMULATOR_HOST=$HostIp"
    if ($LASTEXITCODE -ne 0) { throw "APK build failed ($LASTEXITCODE)." }
    Write-Host "APK: $(Join-Path (Get-Location) 'build\app\outputs\flutter-apk\app-debug.apk')"
} finally {
    Pop-Location
}
