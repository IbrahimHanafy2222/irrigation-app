import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsRef = FirebaseDatabase.instance.ref('alerts/history');

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Alerts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
        stream: alertsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;

          if (data == null) {
            return const Center(child: Text('No alerts found. System is healthy!'));
          }

          // Convert Firebase dynamic map/list into a list of items
          List<Map<dynamic, dynamic>> alertList = [];
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) alertList.add(value);
            });
          } else if (data is List) {
            for (var item in data) {
              if (item is Map) alertList.add(item);
            }
          }

          if (alertList.isEmpty) {
            return const Center(child: Text('No recent alerts.'));
          }

          // Sort by timestamp if available (assuming descending order)
          alertList.sort((a, b) {
            final tA = a['timestamp'] ?? 0;
            final tB = b['timestamp'] ?? 0;
            return tB.compareTo(tA);
          });

          return ListView.builder(
            itemCount: alertList.length,
            itemBuilder: (context, index) {
              final alert = alertList[index];
              final severity = alert['severity']?.toString() ?? 'info';
              final message = alert['message']?.toString() ?? 'Unknown alert';

              IconData icon = Icons.info;
              Color iconColor = Colors.blue;

              if (severity == 'high' || severity == 'error') {
                icon = Icons.error;
                iconColor = Colors.red;
              } else if (severity == 'medium' || severity == 'warning') {
                icon = Icons.warning;
                iconColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: Icon(icon, color: iconColor, size: 36),
                  title: Text(message),
                  subtitle: Text('Severity: ${severity.toUpperCase()}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}