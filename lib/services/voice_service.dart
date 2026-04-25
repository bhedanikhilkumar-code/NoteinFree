import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _stt = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> init() async {
    if (_isInitialized) {
      return true;
    }

    _isInitialized = await _stt.initialize(
      onStatus: (String status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (dynamic error) {
        _isListening = false;
      },
    );

    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartial,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    if (!_isInitialized) {
      return;
    }

    _isListening = true;

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        } else if (onPartial != null) {
          onPartial(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_IN',
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  Future<List<LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await init();
    }
    return _stt.locales();
  }
}