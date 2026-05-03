  import 'package:permission_handler/permission_handler.dart';
  import 'package:speech_to_text/speech_to_text.dart';
  import '../utils/app_logger.dart';

  class SttService {
    static final SpeechToText _speech = SpeechToText();
    static bool _initialized = false;

    // Call this once when the app starts
    static Future<bool> initialize() async {
      // Step 1: ask for mic permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        log.d('Mic permission denied — STT will not work');
        return false;
      }
      log.d('Mic permission granted');

      // Step 2: initialize the STT engine
      _initialized = await _speech.initialize(
        onStatus: (status) => log.d('STT status: $status'),
        onError: (error) => log.d('STT error: $error'),
      );

      log.d(_initialized ? 'STT ready' : 'STT not available on this device');
      return _initialized;
    }

    static bool get isInitialized => _initialized;
    static bool get isListening => _speech.isListening;

    // Start listening — calls onResult every time words are recognized
    static Future<void> startListening({
      required Function(String words, bool isFinal) onResult,
      String localeId = 'en_US',
    }) async {
      if (!_initialized) return;
      await _speech.listen(
        onResult: (result) => onResult(
          result.recognizedWords,
          result.finalResult,
        ),
        localeId: localeId,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: false,
          autoPunctuation: false,
        ),
      );
    }

    static Future<void> stopListening() async {
      await _speech.stop();
    }
  }
