# Mobile App & Backend Connection Guide (Auto-Configured)

You no longer need to manually edit `app_config.dart` or commit your personal IP address to GitHub! The mobile app now detects your computer's IP address and configures itself automatically.

---

## 🚀 How to Run (Choose Any Method)

### Method 1: One-Click Runner (Recommended for Everyone)

#### Windows
Simply double-click:
```
Mobile/OWP_Mobile/run_mobile.bat
```
*(or from workspace root: `run_mobile.bat`)*

Or from PowerShell:
```powershell
cd Mobile/OWP_Mobile
.\run_mobile.ps1
```

#### macOS / Linux
```bash
cd Mobile/OWP_Mobile
chmod +x run_mobile.sh
./run_mobile.sh
```

**What the runner does automatically:**
1. Detects your computer's active Wi-Fi / Ethernet IPv4 address (e.g. `192.168.1.2`, `10.x.x.x`).
2. If your Android phone is plugged in via USB, it automatically runs `adb reverse tcp:5131 tcp:5131` for zero-latency, 100% reliable USB connection.
3. Launches the Flutter app passing your IP via `--dart-define=DEV_IP=<your_ip>`.

---

### Method 2: Standard `flutter run` or VS Code (F5)

If you prefer to run `flutter run` directly from terminal or press `F5` in VS Code:
1. Start the backend: `cd Backend && dotnet run`
2. Start the mobile app: `cd Mobile/OWP_Mobile && flutter run`

The app will **automatically discover** your computer:
1. **USB (ADB Reverse):** If `adb reverse tcp:5131 tcp:5131` was executed, it connects via `127.0.0.1` (<2ms).
2. **Android Emulator:** Connects via `10.0.2.2` (<2ms).
3. **Wi-Fi Subnet Scan:** Scans the local Wi-Fi network for port `5131`, locates your PC running the backend, and saves the IP in `SharedPreferences`. Future launches connect instantly!

---

### Method 3: In-App "Auto-Detect / Change IP" (Right from the Phone Screen)

If the app ever shows "Unable to Load Listings" (e.g., your router changed your IP or you switched Wi-Fi):
1. Tap the **Server: <ip>:5131** link below the *Try Again* button.
2. Tap **"Auto-Detect PC IP (Wi-Fi)"** — the phone will scan your Wi-Fi subnet in real-time, find your computer, and reconnect immediately!
3. Alternatively, you can type your PC's IPv4 address manually and tap **Save & Reconnect**.

---

## 🖥️ Backend Requirements
Make sure the backend is running before testing:
```bash
cd Backend
dotnet run
```
The backend is configured in `Properties/launchSettings.json` to listen on `http://0.0.0.0:5131`, meaning it automatically accepts requests from both `localhost` and your mobile phone over Wi-Fi.
