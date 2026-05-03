# Irriga

A smart irrigation mobile app built with Flutter and Firebase, designed for real-time monitoring and control of an AI-powered plant care system.

---

## What It Does

Irriga connects to a hardware system (Raspberry Pi + sensors) via Firebase Realtime Database. It gives you live visibility into your plants health and lets you control irrigation by touch or by voice.

- **Live sensor dashboard** — soil moisture, temperature, water level, and current draw, each with a sparkline history chart
- **AI plant monitoring** — displays the latest camera detection (plant class + confidence score) from the edge device
- **Voice commands** — say "pump on", "water for 30 seconds", or "emergency stop" and the system responds
- **AI protocol lifecycle** — when a disease or pest is detected, the app automatically starts the irrigation protocol with a live countdown timer
- **Local notifications** — get alerted when a plant issue is detected or when manual mode is activated
- **Alert history** — a log of all system events sorted newest first
- **Manual / Automatic mode** — switch between full manual control and AI-driven automation

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| Database | Firebase Realtime Database |
| Storage | Firebase Storage |
| Notifications | flutter_local_notifications |
| Voice | speech_to_text |
| Charts | fl_chart |
| Logging | logger |

---

## App Structure

```
lib/
├── main.dart                    # App entry, Firebase init, navigation
├── screens/
│   ├── home_screen.dart         # Landing page
│   ├── dashboard_screen.dart    # Live sensor grid + offline banner
│   ├── actuator_screen.dart     # Pump, gantry, emergency stop controls
│   ├── ai_monitor_screen.dart   # Detection image, active protocol, action log
│   └── alerts_screen.dart       # Alert history
├── services/
│   ├── firebase_service.dart    # All RTDB streams and write helpers
│   ├── notification_service.dart # Local notifications + alert logging
│   └── stt_service.dart         # Speech-to-text wrapper
├── utils/
│   ├── command_parser.dart      # Voice command parsing (pure, fully tested)
│   └── app_logger.dart          # Structured logger
├── models/
│   └── protocol_definition.dart # Per-class irrigation durations and actions
└── widgets/
    ├── sensor_card.dart          # Live value + sparkline
    ├── stt_mic_button.dart       # FAB mic with feedback bubble + command guide
    ├── detection_card.dart       # AI detection display
    ├── mode_toggle_card.dart     # Auto/Manual toggle
    └── status_badge.dart         # System state pill
```

---

## Voice Commands

Long-press the mic button in the app to see the full command reference. Examples:

| Say | Action |
|---|---|
| "pump on" | Turn irrigation pump ON |
| "pump off" | Turn irrigation pump OFF |
| "water for 45 seconds" | Run irrigation cycle for 45s |
| "gantry x 200" | Move gantry to position 200mm |
| "emergency stop" | Stop all actuators immediately |
| "cancel AI" | Cancel the active AI protocol |

---

## Firebase Data Structure

```
/sensors
  soil_moisture       read    % moisture
  temperature         read    degrees C
  water_level         read    % level
  current             read    Amps

/status
  pump                read    ON / OFF
  system_state        read    NORMAL / WARNING / FAULT
  mode                write   AUTOMATIC / MANUAL
  gantry_x            read    current position mm

/ai
  latest_detection    read    { class, confidence, image_url, timestamp }
  active_protocol     write   { status, triggered_class, deadline_ms }
  action_log          read    history of AI actions

/commands
  pump                write   { state, timestamp, source }
  gantry_move         write   { x, timestamp, source }
  emergency_stop      write   true
  irrigation_cycle    write   { duration, timestamp, source }

/alerts
  history             write   { message, severity, timestamp }
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase project with Realtime Database and Storage enabled
- `lib/firebase_options.dart` generated via `flutterfire configure`

### Run

```bash
flutter pub get
flutter run                   # Android device
flutter run -d chrome         # Chrome (web — no push notifications)
flutter build apk --release   # Production APK
```

### Tests

```bash
flutter test test/command_parser_test.dart
```

---

## Hardware Integration

The app is designed to pair with a Raspberry Pi that:

1. Captures images with a camera module
2. Runs a plant disease classification model
3. Writes detections to Firebase under `ai/latest_detection`
4. Reads commands from `commands/` and controls physical actuators

The app handles protocol management, notifications, and UI automatically once detections arrive.

---

## Project Status

Currently in active development as part of a university embedded systems project. Hardware integration in progress.
