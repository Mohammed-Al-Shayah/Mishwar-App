# Stops leftover Firebase emulator processes (Firestore/Storage JVMs and the firebase-tools Node CLI)
# that keep ports 4000/8080/9099/5001/9199 busy after an interrupted `firebase emulators:start`.
# Only touches processes whose command line references the Firebase emulator binaries.
$patterns = @('cloud-firestore-emulator', 'cloud-storage-rules-runtime', 'firebase-tools', 'emulators:start')
Get-CimInstance Win32_Process -Filter "Name = 'java.exe' OR Name = 'node.exe'" |
  Where-Object { $cmd = $_.CommandLine; $cmd -and ($patterns | Where-Object { $cmd -like "*$_*" }) } |
  ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    Write-Output "stopped $($_.Name) $($_.ProcessId)"
  }
