// ─── Voice Service: Gemini AI Pipeline ──────────────────────────
// Integrates the GeminiVoiceEngine for Hindi/regional NLU.
// In sandbox mode: simulates a 2-sec mic capture with rotating
// Hindi + English commands, then pipes through the Gemini parser.
import 'dart:async';
import 'package:baai/services/gemini_voice_engine.dart';

class VoiceService {
  bool _isListening = false;
  bool get isListening => _isListening;

  final StreamController<GeminiVoiceResult> _resultController = StreamController<GeminiVoiceResult>.broadcast();
  Stream<GeminiVoiceResult> get onResult => _resultController.stream;

  // Keep raw transcript stream for backward compat
  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  Stream<String> get onTranscript => _transcriptController.stream;

  final StreamController<bool> _listeningController = StreamController<bool>.broadcast();
  Stream<bool> get onListeningChange => _listeningController.stream;

  final GeminiVoiceEngine _engine = GeminiVoiceEngine();

  // Rotating sample commands: mix of Hindi, Hinglish, and English
  static const List<String> _sampleCommands = [
    // Hindi: "Tomatoes are finished"
    'Tamatar khatam ho gaye hain',
    // Hindi: "Make Pav Bhaji this evening"
    'Aaj sham ko Pav Bhaji banana hai',
    // Hinglish: "Prepare Dal Tadka for lunch"
    'Lunch ke liye Dal Tadka banao',
    // English
    'Prepare Chicken Biryani for dinner tonight',
    // Hindi: "Potatoes and onions are running out, order urgently"
    'Aloo aur pyaaz khatam hone wale hain, jaldi mangwao',
    // Hinglish: "Clean the kitchen before guests arrive"
    'Kitchen saaf karo guests aane se pehle',
    // Hindi: "Make tea with milk for everyone"
    'Sabke liye doodh wali chai banana',
    // English
    'Buy 2 kg tomatoes and 1 litre milk from market',
    // Hindi: "Aloo Gobi for dinner"
    'Raat ko Aloo Gobi banana hai',
    // Hinglish: "Eggs are finished, order from Blinkit"
    'Ande khatam ho gaye, Blinkit se mangwao',
    // Hindi: "Make Chole Bhature for Sunday brunch"
    'Sunday brunch ke liye Chole Bhature banao',
    // English
    'Iron the school uniforms for tomorrow',
    // Hindi: "Paneer Butter Masala for evening guests"
    'Sham ke guests ke liye Paneer Butter Masala banana hai',
    // Hinglish: "Water the terrace plants now"
    'Abhi terrace ke plants ko paani do',
  ];
  int _commandIndex = 0;

  // Current inventory stock levels — injected by AppState for real-time OOS detection
  Map<String, double>? _currentStock;

  void updateStockLevels(Map<String, double> stock) {
    _currentStock = stock;
  }

  /// Start listening via the browser microphone.
  /// In sandbox: simulates a 2-second voice capture with rotating commands.
  Future<void> startListening({String lang = 'hi-IN'}) async {
    if (_isListening) return;
    _isListening = true;
    _listeningController.add(true);

    // Simulate 2-second voice capture
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        final command = _sampleCommands[_commandIndex % _sampleCommands.length];
        _commandIndex++;

        // 1. Emit raw transcript
        _transcriptController.add(command);

        // 2. Parse through Gemini Voice Engine
        final result = _engine.parse(command, currentStock: _currentStock);
        _resultController.add(result);

        stopListening();
      }
    });
  }

  void stopListening() {
    _isListening = false;
    _listeningController.add(false);
  }

  /// Direct text input → Gemini parse (for manual text entry or testing)
  GeminiVoiceResult parseText(String text) {
    return _engine.parse(text, currentStock: _currentStock);
  }

  /// Legacy compat: basic keyword parse (still used in old callers)
  Map<String, String> parseVoiceCommand(String transcript) {
    final result = _engine.parse(transcript, currentStock: _currentStock);
    return {
      'title': result.taskTitle,
      'category': result.category,
      'priority': result.priority,
      'linkedRecipeId': result.linkedRecipeId ?? '',
    };
  }

  void dispose() {
    _resultController.close();
    _transcriptController.close();
    _listeningController.close();
  }
}
