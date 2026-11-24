# Builds the admin web panel against the live project and deploys it to mishwar-ps-jo-admin.web.app.
# The browser Maps key is read from web/secrets.properties (MAPS_WEB_KEY=...), which is gitignored.
# The key is never printed. Without the file the panel still works; only the live map is hidden.
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    $defines = @('--dart-define=USE_EMULATORS=false')
    $secrets = 'web/secrets.properties'
    if (Test-Path $secrets) {
        $line = Get-Content $secrets | Where-Object { $_ -match '^\s*MAPS_WEB_KEY\s*=' } | Select-Object -First 1
        if ($line) {
            $key = ($line -split '=', 2)[1].Trim()
            if ($key) { $defines += "--dart-define=MAPS_WEB_KEY=$key" }
        }
    }
    if ($defines.Count -eq 1) { Write-Host 'No MAPS_WEB_KEY found; building without the live map.' }
    else { Write-Host 'MAPS_WEB_KEY found; building with the live map.' }
    & fvm flutter build web --release @defines
    if ($LASTEXITCODE -ne 0) { throw "Web build failed ($LASTEXITCODE)." }
    & firebase deploy --config firebase.admin.json --only hosting --project mishwar-ps-jo
    if ($LASTEXITCODE -ne 0) { throw "Deploy failed ($LASTEXITCODE)." }
} finally {
    Pop-Location
}
