import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final _db = FirebaseDatabase.instance;

  // Sensor streams — each returns a live Stream that updates automatically
  static Stream<double> get soilMoisture => _db
      .ref('sensors/soil_moisture')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get temperature => _db
      .ref('sensors/temperature')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get waterLevel => _db
      .ref('sensors/water_level')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  static Stream<double> get current => _db
      .ref('sensors/current')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0.0);

  // System state stream
  static Stream<String> get systemState => _db
      .ref('status/system_state')
      .onValue
      .map((e) => e.snapshot.value?.toString() ?? 'NORMAL');

  // Latest AI detection stream
  static Stream<Map<String, dynamic>> get latestDetection =>
      _db.ref('ai/latest_detection').onValue.map((e) {
        final val = e.snapshot.value as Map?;
        if (val == null) return {};
        return Map<String, dynamic>.from(val);
      });

  // Mode stream — defaults to MANUAL if absent (safe fallback)
  static Stream<String> get currentMode => _db
      .ref('status/mode')
      .onValue
      .map((e) => e.snapshot.value?.toString() ?? 'AUTOMATIC');

  static Future<void> setMode(String mode) async {
    await _db.ref('status/mode').set(mode);
    await _db
        .ref('status/mode_changed_at')
        .set(DateTime.now().millisecondsSinceEpoch);
  }

  // Pump status stream
  static Stream<String> get pumpStatus => _db
      .ref('status/pump')
      .onValue
      .map((e) => e.snapshot.value?.toString().toUpperCase() ?? 'OFF');

  // Gantry X position stream (X-axis only)
  static Stream<int> get gantryX => _db
      .ref('status/gantry_x')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toInt() ?? 0);

  // AI action log stream — sorted newest first
  static Stream<List<Map<String, dynamic>>> get actionLog =>
      _db.ref('ai/action_log').onValue.map((e) {
        final val = e.snapshot.value as Map?;
        if (val == null) return [];
        return val.values
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList()
          ..sort((a, b) => ((b['timestamp'] as num?) ?? 0)
              .compareTo((a['timestamp'] as num?) ?? 0));
      });

  // Active protocol stream
  static Stream<Map<String, dynamic>> get activeProtocol =>
      _db.ref('ai/active_protocol').onValue.map((e) {
        final val = e.snapshot.value as Map?;
        if (val == null) return {};
        return Map<String, dynamic>.from(val);
      });

  // Write helpers — all app→hardware commands go through here
  static Future<void> writePump(String state) =>
      _db.ref('commands/pump').set({
        'state': state,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'app',
      });

  static Future<void> writeGantryX(int x) =>
      _db.ref('commands/gantry_move').set({
        'x': x,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'app',
      });

  static Future<void> writeEmergencyStop() =>
      _db.ref('commands/emergency_stop').set(true);

  static Future<void> cancelAiProtocol() =>
      _db.ref('commands/cancel_ai_protocol').set(true);
}
