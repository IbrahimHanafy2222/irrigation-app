import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';
import '../models/protocol_definition.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final _notif = FlutterLocalNotificationsPlugin();
  static StreamSubscription? _detectionSub;
  static StreamSubscription? _modeSub;
  static StreamSubscription? _protocolSub;
  static String? _lastDetectionClass;
  static String? _lastMode;
  static Timer? _protocolTimer;
  static String? _lastProtocolStatus;

  static const _channel = AndroidNotificationChannel(
    'irrigation_alerts',
    'Irrigation Alerts',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (!kIsWeb) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _notif.initialize(const InitializationSettings(android: androidSettings));
      await _notif
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    _detectionSub = FirebaseService.latestDetection.listen((detection) {
      final cls = detection['class']?.toString() ?? '';
      if (cls.isEmpty || cls == 'Healthy' || cls == _lastDetectionClass) return;
      _lastDetectionClass = cls;
      _show('Plant Issue Detected', '$cls detected — check AI Monitor', severity: 'warning');
      _startProtocol(cls);
    });

    _modeSub = FirebaseService.currentMode.listen((mode) {
      if (mode == _lastMode) return;
      _lastMode = mode;
      if (mode == 'MANUAL') {
        _show('Manual Mode Enabled', 'AI automation paused. You have full control.', severity: 'info');
      }
    });

    _protocolSub = FirebaseService.activeProtocol.listen((protocol) {
      final status = protocol['status']?.toString() ?? 'idle';
      final grace = (protocol['grace_remaining'] as num?)?.toInt() ?? 0;
      final triggeredClass = protocol['triggered_class']?.toString() ?? 'Unknown';

      if (status == 'executing' && _lastProtocolStatus != 'executing') {
        _protocolTimer?.cancel();
        _protocolTimer = Timer(Duration(seconds: grace), () {
          _show('Protocol Complete', '$triggeredClass protocol finished — system resuming normal operation.', severity: 'info');
          _resetProtocol();
        });
      } else if (status != 'executing') {
        _protocolTimer?.cancel();
      }
      _lastProtocolStatus = status;
    });

    log.i('NotificationService initialized');
  }

  static Future<void> _show(String title, String body, {String severity = 'info'}) async {
    if (!kIsWeb) {
      _notif.show(
        DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
    await _logAlert(title, body, severity);
    log.i('Notification: $title — $body');
  }

  static Future<void> _logAlert(String title, String body, String severity) async {
    try {
      await FirebaseService.pushAlert(
        message: '$title: $body',
        severity: severity,
      );
      log.d('Alert logged: $title');
    } catch (e) {
      log.w('Alert log failed: $e');
    }
  }

  static Future<void> _startProtocol(String plantClass) async {
    final def = ProtocolDefinition.forClass(plantClass);
    final grace = def?.irrigationSeconds ?? 30;
    final deadlineMs = DateTime.now().millisecondsSinceEpoch + grace * 1000;
    try {
      await FirebaseService.writeActiveProtocol(
        plantClass: plantClass,
        graceSeconds: grace,
        deadlineMs: deadlineMs,
      );
      _protocolTimer?.cancel();
      _lastProtocolStatus = 'executing';
      _protocolTimer = Timer(Duration(seconds: grace), () {
        _show('Protocol Complete', '$plantClass protocol finished — resuming normal operation.', severity: 'info');
        _lastDetectionClass = null; // allow same class to re-trigger next time
        _resetProtocol();
      });
    } catch (e) {
      log.w('Protocol start failed: $e');
    }
  }

  static Future<void> _resetProtocol() async {
    try {
      await FirebaseService.cancelAiProtocol();
    } catch (e) {
      log.w('Protocol reset failed: $e');
    }
  }

  static void dispose() {
    _detectionSub?.cancel();
    _modeSub?.cancel();
    _protocolSub?.cancel();
    _protocolTimer?.cancel();
  }
}
