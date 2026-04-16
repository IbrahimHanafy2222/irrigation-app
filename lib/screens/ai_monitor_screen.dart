import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../models/protocol_definition.dart';

class AiMonitorScreen extends StatelessWidget {
  const AiMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DetectionCard(),
            const SizedBox(height: 16),
            const _ActiveProtocolCard(),
            const SizedBox(height: 24),
            // ── Action History ───────────────────────────────────────
            Text(
              'Action history',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirebaseService.actionLog,
              builder: (context, logSnap) {
                final entries = logSnap.data ?? [];
                if (entries.isEmpty) {
                  return Text(
                    'No actions recorded yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.45),
                        ),
                  );
                }
                return Column(
                  children: entries
                      .take(10)
                      .map((e) => _ActionLogTile(entry: e))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            // ── Protocol Reference ───────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ExpansionTile(
                title: Text(
                  'Protocol reference',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                backgroundColor: AppTheme.greenPale,
                collapsedBackgroundColor: AppTheme.greenPale,
                shape: const Border(),
                collapsedShape: const Border(),
                children: ProtocolDefinition.all.map((def) {
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: def.indicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      def.plantClass,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.greenDeep),
                    ),
                    trailing: Text(
                      def.actionLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55),
                          ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Detection Card ────────────────────────────────────────────────────────────

class _DetectionCard extends StatelessWidget {
  const _DetectionCard();

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.amber;
    return Colors.red;
  }

  String _updatedAgo(int? timestampMs) {
    if (timestampMs == null) return '';
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestampMs));
    if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    return 'Updated ${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService.latestDetection,
      builder: (context, snap) {
        final detection = snap.data ?? {};
        final plantClass = detection['class']?.toString() ?? 'None';
        final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
        final imageUrl = detection['image_url']?.toString() ?? '';
        final timestamp = detection['timestamp'] as int?;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Detection',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (timestamp != null)
                      Text(
                        _updatedAgo(timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.45),
                            ),
                      ),
                  ],
                ),
                const Divider(),
                if (imageUrl.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Icon(Icons.camera_alt,
                        size: 100, color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                Text(
                  plantClass,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'DM Serif Display',
                        color: AppTheme.greenDeep,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _confidenceColor(confidence)),
                          backgroundColor:
                              _confidenceColor(confidence).withOpacity(0.15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _confidenceColor(confidence),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Active Protocol Card ──────────────────────────────────────────────────────

class _ActiveProtocolCard extends StatefulWidget {
  const _ActiveProtocolCard();

  @override
  State<_ActiveProtocolCard> createState() => _ActiveProtocolCardState();
}

class _ActiveProtocolCardState extends State<_ActiveProtocolCard> {
  Timer? _timer;
  int _countdown = 0;
  int? _lastGrace; // tracks last grace_remaining from Firebase to detect resets
  Map<String, dynamic> _protocol = {};
  late final StreamSubscription<Map<String, dynamic>> _protocolSub;

  @override
  void initState() {
    super.initState();
    _protocolSub = FirebaseService.activeProtocol.listen((protocol) {
      if (!mounted) return;
      final status = protocol['status']?.toString() ?? 'idle';
      final grace = (protocol['grace_remaining'] as num?)?.toInt() ?? 0;

      setState(() => _protocol = protocol);

      if (status == 'executing' && grace != _lastGrace) {
        _lastGrace = grace;
        _timer?.cancel();
        setState(() => _countdown = grace);
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          if (_countdown > 0) {
            setState(() => _countdown--);
          } else {
            _timer?.cancel();
          }
        });
      } else if (status != 'executing') {
        _timer?.cancel();
        _lastGrace = null;
        if (_countdown != 0) setState(() => _countdown = 0);
      }
    });
  }

  @override
  void dispose() {
    _protocolSub.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _protocol['status']?.toString() ?? 'idle';
    final isExecuting = status == 'executing';
    final zoneX = (_protocol['zone_x'] as num?)?.toInt() ?? 0;
    final triggeredClass =
        _protocol['triggered_class']?.toString() ?? '';
    final protocolDef = ProtocolDefinition.forClass(triggeredClass);
    final suggestedPump =
        _protocol['pump_state']?.toString() ?? 'ON';

    return StreamBuilder<String>(
      stream: FirebaseService.currentMode,
      builder: (context, modeSnap) {
        final isManual = (modeSnap.data ?? 'AUTOMATIC') == 'MANUAL';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Protocol',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text('Status: $status'),
                Text('Zone X: $zoneX'),
                if (protocolDef != null) ...[
                  const SizedBox(height: 4),
                  Text('Triggered by: $triggeredClass'),
                  Text('Action: ${protocolDef.actionLabel}'),
                ],
                if (isExecuting) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Grace remaining: ${_countdown}s',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.greenBright),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _lastGrace != null && _lastGrace! > 0
                        ? _countdown / _lastGrace!
                        : 0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.greenBright),
                    backgroundColor: AppTheme.greenBright.withOpacity(0.15),
                  ),
                ],
                const SizedBox(height: 16),
                // Cancel (auto mode) or Apply (manual mode)
                if (isManual)
                  ElevatedButton.icon(
                    onPressed: isExecuting
                        ? () {
                            FirebaseService.writeGantryX(zoneX);
                            FirebaseService.writePump(suggestedPump);
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Apply AI Suggestion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenDeep,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: isExecuting
                        ? () => FirebaseService.cancelAiProtocol()
                        : null,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel AI Protocol'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100),
                  ),
                if (isManual && isExecuting)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'AI suggestion — tap Apply to act',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Action Log Tile ───────────────────────────────────────────────────────────

class _ActionLogTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _ActionLogTile({required this.entry});

  Color _colorForClass(String className) {
    switch (className) {
      case 'Healthy':
        return Colors.green;
      case 'Early_Blight':
        return Colors.orange;
      case 'Late_Blight':
        return Colors.red;
      case 'Pest':
        return Colors.purple;
      case 'Nutrient_Deficiency':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _relativeTime(int? timestampMs) {
    if (timestampMs == null) return '';
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestampMs));
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final plantClass = entry['class']?.toString() ?? 'Unknown';
    final actionTaken = entry['action_taken']?.toString() ?? '';
    final zoneX = entry['zone_x'] ?? 0;
    final confidence = (entry['confidence'] as num?)?.toDouble() ?? 0.0;
    final timestamp = entry['timestamp'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.greenDeep.withOpacity(0.07),
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: _colorForClass(plantClass),
            shape: BoxShape.circle,
          ),
        ),
        title: Text('$plantClass — $actionTaken',
            style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(
          'Zone X:$zoneX   ${(confidence * 100).toStringAsFixed(0)}% confidence',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
        ),
        trailing: Text(
          _relativeTime(timestamp),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.45),
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}
