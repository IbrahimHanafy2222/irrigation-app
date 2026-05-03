import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  String _relativeTime(int? ms) {
    if (ms == null) return '';
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('alerts/history').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No alerts yet. System is healthy!'));
          }

          final alertList = <Map<dynamic, dynamic>>[];
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) alertList.add(value);
            });
          }

          if (alertList.isEmpty) {
            return const Center(child: Text('No alerts yet.'));
          }

          alertList.sort((a, b) {
            final tA = (a['timestamp'] as num?) ?? 0;
            final tB = (b['timestamp'] as num?) ?? 0;
            return tB.compareTo(tA);
          });

          final capped = alertList.take(20).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: capped.length,
            itemBuilder: (context, index) {
              final alert = capped[index];
              final severity = alert['severity']?.toString() ?? 'info';
              final message = alert['message']?.toString() ?? '';
              final timestamp = alert['timestamp'] as int?;

              final (icon, color) = switch (severity) {
                'warning' => (Icons.warning_rounded, Colors.orange),
                'error' => (Icons.error_rounded, Colors.red),
                _ => (Icons.info_rounded, Colors.blue),
              };

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(icon, color: color, size: 32),
                  title: Text(message),
                  trailing: Text(
                    _relativeTime(timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
