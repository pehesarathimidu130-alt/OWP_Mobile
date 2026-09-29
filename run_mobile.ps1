# ==============================================================================
# Oleena Mobile App - Smart Auto-IP Runner
# Automatically detects your PC IPv4, forwards ADB port 5131, and launches Flutter.
# No manual edits to app_config.dart needed!
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     Oleena Mobile App - Universal Auto-IP Runner        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Detect Host IPv4 Address (prioritize Wi-Fi for mobile testing, fallback to Ethernet)
$wifi = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "127.*" } |
    Select-Object -First 1

if ($wifi) {
    $hostIp = $wifi.IPAddress
} else {
    $ethernet = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet*" -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "127.*" } |
        Select-Object -First 1
    $hostIp = if ($ethernet) { $ethernet.IPAddress } else { "127.0.0.1" }
}

Write-Host "[+] Detected Host PC IPv4: $hostIp" -ForegroundColor Green

# 2. Check for ADB device & forward port 5131
$adb = Get-Command adb -ErrorAction SilentlyContinue
if ($adb) {
    $devices = & adb devices | Select-String -Pattern "\bdevice\b"
    if ($devices) {
        & adb reverse tcp:5131 tcp:5131 | Out-Null
        Write-Host "[+] ADB device detected: Port 5131 forwarded via USB (127.0.0.1 ready)" -ForegroundColor Green
    } else {
        Write-Host "[i] No ADB device attached via USB (using Wi-Fi: $hostIp:5131)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[i] ADB not in PATH (using Wi-Fi: $hostIp:5131)" -ForegroundColor Yellow
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ">>> Starting Flutter with DEV_IP=$hostIp..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

flutter run --dart-define=DEV_IP=$hostIp $args
