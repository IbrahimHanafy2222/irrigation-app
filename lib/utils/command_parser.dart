import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import 'app_logger.dart';

enum CommandType { emergencyStop, cancelAi, pumpOn, pumpOff, gantryMove, irrigate, unknown }

class ParsedCommand {
  final CommandType type;
  final int? gantryX;
  final int? irrigationSeconds;
  final String description;

  const ParsedCommand({
    required this.type,
    this.gantryX,
    this.irrigationSeconds,
    required this.description,
  });
}

class CommandParser {
  static ParsedCommand parse(String text) {
    final lower = text.toLowerCase().trim();

    if (_matches(lower, ['emergency stop', 'stop everything', 'stop all'])) {
      return const ParsedCommand(type: CommandType.emergencyStop, description: 'Emergency stop triggered');
    }
    if (_matches(lower, ['cancel ai', 'cancel protocol', 'stop ai action', 'abort protocol'])) {
      return const ParsedCommand(type: CommandType.cancelAi, description: 'AI protocol cancelled');
    }
    if (_matches(lower, ['pump on', 'turn on pump', 'start pump', 'switch pump on'])) {
      return const ParsedCommand(type: CommandType.pumpOn, description: 'Pump turned ON');
    }
    if (_matches(lower, ['pump off', 'turn off pump', 'stop pump', 'switch pump off'])) {
      return const ParsedCommand(type: CommandType.pumpOff, description: 'Pump turned OFF');
    }

    final gantryMatch = RegExp(r'gantry.*x\s*(\d+)').firstMatch(lower);
    if (gantryMatch != null) {
      final x = (int.tryParse(gantryMatch.group(1) ?? '') ?? 0).clamp(0, 400);
      return ParsedCommand(type: CommandType.gantryMove, gantryX: x, description: 'Gantry moving to X=$x');
    }

    final waterMatch = RegExp(r'water for (\d+) seconds?').firstMatch(lower);
    if (waterMatch != null) {
      final secs = (int.tryParse(waterMatch.group(1) ?? '') ?? 60).clamp(10, 600);
      return ParsedCommand(type: CommandType.irrigate, irrigationSeconds: secs, description: 'Irrigation started for ${secs}s');
    }

    return const ParsedCommand(type: CommandType.unknown, description: 'Command not recognized');
  }

  static Future<void> execute(ParsedCommand cmd) async {
    log.i('Voice command: ${cmd.description}');
    switch (cmd.type) {
      case CommandType.emergencyStop:
        await FirebaseService.writeEmergencyStop();
      case CommandType.cancelAi:
        await FirebaseService.cancelAiProtocol();
      case CommandType.pumpOn:
        await Future.wait([
          FirebaseService.writePump('ON'),
          FirebaseDatabase.instance.ref('status/pump').set('ON'),
        ]);
      case CommandType.pumpOff:
        await Future.wait([
          FirebaseService.writePump('OFF'),
          FirebaseDatabase.instance.ref('status/pump').set('OFF'),
        ]);
      case CommandType.gantryMove:
        await Future.wait([
          FirebaseService.writeGantryX(cmd.gantryX!),
          FirebaseDatabase.instance.ref('status/gantry_x').set(cmd.gantryX!),
        ]);
      case CommandType.irrigate:
        await FirebaseService.writeIrrigationCycle(cmd.irrigationSeconds!);
      case CommandType.unknown:
        break;
    }
  }

  static bool _matches(String input, List<String> phrases) =>
      phrases.any((p) => input.contains(p));
}
