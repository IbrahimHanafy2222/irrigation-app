import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // needed for DatabaseEvent in _SystemStateCard
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mode_toggle_card.dart';

class ActuatorScreen extends StatelessWidget {
  const ActuatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls')),
      body: StreamBuilder<String>(
        stream: FirebaseService.currentMode,
        builder: (context, modeSnap) {
          final mode = modeSnap.data ?? 'AUTOMATIC';
          final isManual = mode == 'MANUAL';
          return Column(
            children: [
              ModeToggleCard(currentMode: mode),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SystemStateCard(isManual: isManual),
                    const SizedBox(height: 16),
                    _PumpControlCard(isManual: isManual),
                    const SizedBox(height: 16),
                    _GantryControlCard(isManual: isManual),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── System State Card ─────────────────────────────────────────────────────────

class _SystemStateCard extends StatelessWidget {
  final bool isManual;
  const _SystemStateCard({required this.isManual});

  void _triggerEmergencyStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency stop'),
        content:
            const Text('This stops ALL actuators immediately. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              FirebaseService.writeEmergencyStop();
            },
            child: const Text('Stop everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('status/system_state').onValue,
      builder: (context, snapshot) {
        final systemState =
            snapshot.data?.snapshot.value?.toString() ?? 'UNKNOWN';
        return Card(
          child: ListTile(
            leading: Icon(
              systemState == 'NORMAL' ? Icons.check_circle : Icons.warning,
              color: systemState == 'NORMAL' ? Colors.green : Colors.red,
              size: 32,
            ),
            title: const Text('System State'),
            subtitle: Text(systemState),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.stop_circle),
              label: const Text('E-STOP'),
              // Always enabled — safety override ignores mode
              onPressed: () => _triggerEmergencyStop(context),
            ),
          ),
        );
      },
    );
  }
}

// ── Pump Control Card ─────────────────────────────────────────────────────────
class _PumpControlCard extends StatefulWidget {
  final bool isManual;
  const _PumpControlCard({required this.isManual});

  @override
  State<_PumpControlCard> createState() => _PumpControlCardState();
}

class _PumpControlCardState extends State<_PumpControlCard> {
  // Optimistic local state — null means "follow Firebase value"
  bool? _localOverride;

  Future<void> _togglePump(bool value) async {
    setState(() => _localOverride = value);
    final newState = value ? 'ON' : 'OFF';
    try {
      await Future.wait([
        FirebaseService.writePump(newState),
        FirebaseDatabase.instance.ref('status/pump').set(newState), // optimistic status update
      ]);
    } catch (e) {
      setState(() => _localOverride = null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update pump: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: FirebaseService.pumpStatus,
      builder: (context, snapshot) {
        final firebaseIsOn =
            (snapshot.data ?? 'OFF').toUpperCase() == 'ON';
        // Use local override if set; otherwise follow Firebase
        final isOn = _localOverride ?? firebaseIsOn;
        final pumpState = snapshot.data ?? 'UNKNOWN';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Irrigation Pump',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Firebase status: $pumpState',
                    style: const TextStyle(fontSize: 14)),
                SwitchListTile(
                  title: const Text('Turn Pump ON/OFF'),
                  value: isOn,
                  onChanged: widget.isManual ? _togglePump : null,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!widget.isManual)
                  Text(
                    'Controls locked — switch to Manual mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
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

class _GantryControlCard extends StatefulWidget {
  final bool isManual;
  const _GantryControlCard({required this.isManual});

  @override
  State<_GantryControlCard> createState() => _GantryControlCardState();
}

class _GantryControlCardState extends State<_GantryControlCard> {
  double _sliderValue = 0;
  bool _initialized = false;

  Future<void> _moveGantry(double x) async {
    try {
      await FirebaseService.writeGantryX(x.toInt());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to move gantry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gantry Position',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: FirebaseService.gantryX,
              builder: (context, snapshot) {
                final x = snapshot.data ?? 0;
                if (!_initialized && snapshot.hasData) {
                  _initialized = true;
                  _sliderValue = x.toDouble().clamp(0, 400);
                }
                return Text(
                  'Current X: $x',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('0mm', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 400,
                    divisions: 40,
                    value: _sliderValue,
                    label: _sliderValue.toInt().toString(),
                    onChanged: widget.isManual
                        ? (v) => setState(() => _sliderValue = v)
                        : null,
                    onChangeEnd: widget.isManual ? (v) { _moveGantry(v); } : null,
                  ),
                ),
                const Text('400mm', style: TextStyle(fontSize: 12)),
              ],
            ),
            Text(
              'Target: ${_sliderValue.toInt()}',
              style: const TextStyle(fontSize: 14),
            ),
            if (!widget.isManual) ...[
              const SizedBox(height: 8),
              Text(
                'Controls locked — switch to Manual mode',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
