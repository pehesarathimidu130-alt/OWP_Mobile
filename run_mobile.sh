#!/bin/bash
# ==============================================================================
# Oleena Mobile App - Smart Auto-IP Runner (macOS / Linux)
# Automatically detects your PC IPv4, forwards ADB port 5131, and launches Flutter.
# ==============================================================================

echo "=========================================================="
echo "     Oleena Mobile App - Universal Auto-IP Runner        "
echo "=========================================================="

# 1. Detect Host IPv4 Address
HOST_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "127.0.0.1")
echo "[+] Detected Host PC IPv4: $HOST_IP"

# 2. Check for ADB device & forward port 5131
if command -v adb &> /dev/null; then
    DEVICES=$(adb devices | grep -w "device")
    if [ -n "$DEVICES" ]; then
        adb reverse tcp:5131 tcp:5131 > /dev/null 2>&1
        echo "[+] ADB device detected: Port 5131 forwarded via USB (127.0.0.1 ready)"
    else
        echo "[i] No ADB device attached via USB (using Wi-Fi: $HOST_IP:5131)"
    fi
fi

echo "=========================================================="
echo ">>> Starting Flutter with DEV_IP=$HOST_IP..."
echo "=========================================================="

flutter run --dart-define=DEV_IP="$HOST_IP" "$@"
