# Irrigation App

A Flutter mobile app for a smart irrigation system with AI-powered plant disease monitoring, real-time sensor data, and remote hardware control via Firebase.

---

## Features

- **Live sensor dashboard** — soil moisture, temperature, water level, current draw (Firebase RTDB streams)
- **AI plant monitoring** — disease detection (Healthy / Early Blight / Late Blight / Pest / Nutrient Deficiency) with confidence scores and camera images
- **Remote actuator control** — pump toggle, emergency stop, gantry XY positioning
- **AI irrigation protocol** — automatically triggered zone-targeted watering based on detection class
- **Alert history** — severity-sorted log of system events
- **Voice input** — Speech-to-Text integration for hands-free control
- **Material 3 UI** — green-palette theme with DM Serif Display / DM Sans fonts

---

## Architecture

```
Hardware / Edge device
  → writes sensor data to Firebase RTDB
    → Flutter app reads via real-time streams
      → user commands written back to Firebase
        → hardware reads and executes
```

### Firebase RTDB paths

| Path | Direction | Description |
|------|-----------|-------------|
| `sensors/soil_moisture` | read | % moisture |
| `sensors/temperature` | read | °C |
| `sensors/water_level` | read | % level |
| `sensors/current` | read | Amps draw |
| `status/system_state` | read | `NORMAL` / `WARNING` / `FAULT` |
| `status/pump` | read | `ON` / `OFF` |
| `status/gantry_x`, `gantry_y` | read | gantry position |
| `ai/latest_detection` | read | `{class, confidence, image_url}` |
| `ai/active_protocol` | read | `{status, zone_x, zone_y, grace_remaining}` |
| `alerts/history` | read | list of `{severity, message, timestamp}` |
| `commands/pump` | **write** | `{state, timestamp, source}` |
| `commands/emergency_stop` | **write** | `true` |
| `commands/gantry_move` | **write** | `{x, y, timestamp}` |
| `commands/cancel_ai_protocol` | **write** | `true` |

---

## Screens

| Tab | Screen | Purpose |
|-----|--------|---------|
| Home | `HomeScreen` | Hero landing, quick stats, how-it-works cards |
| Dashboard | `DashboardScreen` | Live sensor grid + AI detection card |
| Controls | `ActuatorScreen` | Pump toggle, emergency stop, gantry test move |
| AI Monitor | `AiMonitorScreen` | Latest detection image + active protocol status |
| Alerts | `AlertsScreen` | Alert history sorted by timestamp |

---

## Setup

1. **Flutter** — requires Flutter SDK (stable channel)
2. **Firebase** — run `flutterfire configure` to generate `lib/firebase_options.dart` (gitignored)
3. **Android** — microphone permission (`RECORD_AUDIO`) is declared in the manifest
4. **Run:**

```bash
flutter pub get
flutter run
```

---

## Build

```bash
flutter build apk      # Android
flutter build web      # Web
```

---

## Progress

### Done
- [x] Firebase Realtime Database integration (all sensor + status streams)
- [x] 5-tab navigation shell (`MainNavigation`)
- [x] `HomeScreen` — static landing page with hero and quick-stats
- [x] `DashboardScreen` — live `SensorCard` grid + `DetectionCard` + `StatusBadge`
- [x] `ActuatorScreen` — pump toggle, emergency stop, gantry move commands
- [x] `AiMonitorScreen` — detection image viewer + active protocol display
- [x] `AlertsScreen` — timestamped alert history
- [x] `SttTestScreen` — standalone voice input debug screen
- [x] Material 3 theme with custom green palette and DM fonts
- [x] Speech-to-Text service singleton

### In Progress / Planned
- [ ] Offline mode / connection-loss handling
- [ ] Push notifications for FAULT state
- [ ] Historical sensor charts (time-series graphs)
- [ ] Multi-zone irrigation scheduling UI
- [ ] iOS build & TestFlight distribution
- [ ] Unit + widget test coverage
