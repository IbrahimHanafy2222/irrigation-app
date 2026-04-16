import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttTestScreen extends StatefulWidget {
  const SttTestScreen({super.key});
  State createState() => _SttTestScreenState();
}

class _SttTestScreenState extends State<SttTestScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _transcript = 'Tap the mic and speak';
  String _status = 'Not initialized';

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => setState(() => _status = status),
      onError: (error) => setState(() => _status = 'Error: $error'),
    );
    setState(() =>
        _status = available ? 'Ready' : 'STT not available on this device');
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _transcript = result.recognizedWords;
            _isListening = result.hasConfidenceRating && result.confidence > 0;
          });
        },
        localeId: 'en_US', // change to 'ar_EG' for Arabic
      );
      setState(() => _isListening = true);
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void initState() {
    super.initState();
    _initSpeech();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STT test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text('Status: $_status',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_transcript, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.green,
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(_isListening ? 'Listening...' : 'Tap to speak',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
      ),
    );
  }
}
