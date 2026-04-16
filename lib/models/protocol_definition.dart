import 'package:flutter/material.dart';

class ProtocolDefinition {
  final String plantClass;
  final String actionLabel;
  final String actionTaken;
  final int irrigationSeconds;
  final bool sendsAlert;
  final Color indicatorColor;

  const ProtocolDefinition({
    required this.plantClass,
    required this.actionLabel,
    required this.actionTaken,
    required this.irrigationSeconds,
    required this.sendsAlert,
    required this.indicatorColor,
  });

  static const List<ProtocolDefinition> all = [
    ProtocolDefinition(
      plantClass: 'Healthy',
      actionLabel: 'No action',
      actionTaken: 'no_action',
      irrigationSeconds: 0,
      sendsAlert: false,
      indicatorColor: Colors.green,
    ),
    ProtocolDefinition(
      plantClass: 'Early_Blight',
      actionLabel: 'Irrigate 30s',
      actionTaken: 'irrigate_30s',
      irrigationSeconds: 30,
      sendsAlert: false,
      indicatorColor: Colors.orange,
    ),
    ProtocolDefinition(
      plantClass: 'Late_Blight',
      actionLabel: 'Irrigate 60s + High Alert',
      actionTaken: 'irrigate_60s',
      irrigationSeconds: 60,
      sendsAlert: true,
      indicatorColor: Colors.red,
    ),
    ProtocolDefinition(
      plantClass: 'Pest',
      actionLabel: 'Irrigate 45s + Alert',
      actionTaken: 'irrigate_45s',
      irrigationSeconds: 45,
      sendsAlert: true,
      indicatorColor: Colors.purple,
    ),
    ProtocolDefinition(
      plantClass: 'Nutrient_Deficiency',
      actionLabel: 'Irrigate 20s (nutrients)',
      actionTaken: 'irrigate_20s',
      irrigationSeconds: 20,
      sendsAlert: false,
      indicatorColor: Colors.blue,
    ),
  ];

  static ProtocolDefinition? forClass(String className) {
    try {
      return all.firstWhere((d) => d.plantClass == className);
    } catch (_) {
      return null;
    }
  }
}
