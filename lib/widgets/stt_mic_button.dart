import 'dart:async';
import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../utils/command_parser.dart';

class SttMicButton extends StatefulWidget {
  const SttMicButton({super.key});

  @override
  State<SttMicButton> createState() => _SttMicButtonState();
}

class _SttMicButtonState extends State<SttMicButton> {
  bool _listening = false;
  String _feedback = '';
  Timer? _clearTimer;

  void _showFeedback(String text) {
    _clearTimer?.cancel();
    setState(() => _feedback = text);
    _clearTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _feedback = '');
    });
  }

  Future<void> _toggle() async {
    if (_listening) {
      await SttService.stopListening();
      setState(() => _listening = false);
      return;
    }

    setState(() {
      _listening = true;
      _feedback = 'Listening...';
    });

    await SttService.startListening(
      onResult: (words, isFinal) async {
        if (!isFinal) return;
        if (!mounted) return;
        setState(() => _listening = false);
        final cmd = CommandParser.parse(words);
        if (cmd.type != CommandType.unknown) {
          try {
            await CommandParser.execute(cmd);
            _showFeedback('✓ ${cmd.description}');
          } catch (e) {
            _showFeedback('✗ Command failed');
          }
        } else {
          _showFeedback('✗ Not recognized: "$words"');
        }
      },
    );
  }

  void _showCommandsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CommandsSheet(),
    );
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    if (_listening) SttService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_feedback.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _feedback,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              softWrap: true,
            ),
          ),
        GestureDetector(
          onLongPress: () => _showCommandsSheet(context),
          child: FloatingActionButton(
            heroTag: 'stt_fab',
            onPressed: _toggle,
            backgroundColor: _listening ? Colors.red : const Color(0xFF1B5E20),
            child: Icon(
              _listening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommandsSheet extends StatelessWidget {
  const _CommandsSheet();

  static const _commands = [
    _CommandGroup('Pump', [
      _Command('"pump on"', 'Turn irrigation pump ON'),
      _Command('"pump off"', 'Turn irrigation pump OFF'),
      _Command('"turn on pump"', 'Alternative phrasing'),
      _Command('"stop pump"', 'Alternative phrasing'),
    ]),
    _CommandGroup('Irrigation', [
      _Command('"water for 30 seconds"', 'Run irrigation cycle (10–600s)'),
    ]),
    _CommandGroup('Gantry', [
      _Command('"gantry x 200"', 'Move gantry to position 0–400mm'),
    ]),
    _CommandGroup('Safety', [
      _Command('"emergency stop"', 'Stop all actuators immediately'),
      _Command('"stop everything"', 'Alternative phrasing'),
      _Command('"cancel AI"', 'Cancel active AI protocol'),
      _Command('"abort protocol"', 'Alternative phrasing'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.mic, size: 20),
              const SizedBox(width: 8),
              Text('Voice Commands',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const Spacer(),
              Text('Long-press mic to open',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      )),
            ],
          ),
          const Divider(height: 20),
          ..._commands.map((group) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.title,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            letterSpacing: 1.1,
                          )),
                  const SizedBox(height: 6),
                  ...group.commands.map((cmd) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(cmd.phrase,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Color(0xFF1B5E20))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(cmd.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      )),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),
                ],
              )),
          ],
        ),
      ),
    );
  }
}

class _CommandGroup {
  final String title;
  final List<_Command> commands;
  const _CommandGroup(this.title, this.commands);
}

class _Command {
  final String phrase;
  final String description;
  const _Command(this.phrase, this.description);
}
