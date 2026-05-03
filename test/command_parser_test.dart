import 'package:flutter_test/flutter_test.dart';
import 'package:irrigation_app/utils/command_parser.dart';

void main() {
  group('CommandParser.parse', () {
    test('recognizes emergency stop phrases', () {
      expect(CommandParser.parse('emergency stop').type, CommandType.emergencyStop);
      expect(CommandParser.parse('stop everything').type, CommandType.emergencyStop);
      expect(CommandParser.parse('stop all').type, CommandType.emergencyStop);
    });

    test('recognizes cancel ai phrases', () {
      expect(CommandParser.parse('cancel ai').type, CommandType.cancelAi);
      expect(CommandParser.parse('cancel protocol').type, CommandType.cancelAi);
      expect(CommandParser.parse('stop ai action').type, CommandType.cancelAi);
      expect(CommandParser.parse('abort protocol').type, CommandType.cancelAi);
    });

    test('recognizes pump on phrases', () {
      expect(CommandParser.parse('pump on').type, CommandType.pumpOn);
      expect(CommandParser.parse('turn on pump').type, CommandType.pumpOn);
      expect(CommandParser.parse('start pump').type, CommandType.pumpOn);
    });

    test('recognizes pump off phrases', () {
      expect(CommandParser.parse('pump off').type, CommandType.pumpOff);
      expect(CommandParser.parse('turn off pump').type, CommandType.pumpOff);
    });

    test('recognizes gantry move with x coordinate', () {
      final cmd = CommandParser.parse('move gantry to x 200');
      expect(cmd.type, CommandType.gantryMove);
      expect(cmd.gantryX, 200);
    });

    test('clamps gantry x to 0–400 mm', () {
      expect(CommandParser.parse('gantry x 500').gantryX, 400);
      expect(CommandParser.parse('gantry x 0').gantryX, 0);
    });

    test('recognizes water for N seconds', () {
      final cmd = CommandParser.parse('water for 45 seconds');
      expect(cmd.type, CommandType.irrigate);
      expect(cmd.irrigationSeconds, 45);
    });

    test('clamps irrigation to 10–600 seconds', () {
      expect(CommandParser.parse('water for 5 seconds').irrigationSeconds, 10);
      expect(CommandParser.parse('water for 1000 seconds').irrigationSeconds, 600);
    });

    test('returns unknown for unrecognized input', () {
      expect(CommandParser.parse('hello world').type, CommandType.unknown);
      expect(CommandParser.parse('').type, CommandType.unknown);
    });

    test('is case insensitive', () {
      expect(CommandParser.parse('PUMP ON').type, CommandType.pumpOn);
      expect(CommandParser.parse('Emergency Stop').type, CommandType.emergencyStop);
    });

    test('emergency stop has highest priority over pump phrases', () {
      expect(CommandParser.parse('stop everything now').type, CommandType.emergencyStop);
    });

    test('description is non-empty for recognized commands', () {
      expect(CommandParser.parse('pump on').description, isNotEmpty);
      expect(CommandParser.parse('emergency stop').description, isNotEmpty);
    });
  });
}
