import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../l10n/app_strings.dart';

enum AppLanguage { english, hindi, marathi }

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final FlutterTts _tts = FlutterTts();
  AppLanguage _currentLanguage = AppLanguage.english;
  bool _isSpeaking = false;
  bool _voiceEnabled = true;
  bool _isInitialized = false;
  double _speechRate = 0.45;
  double _pitch = 1.0;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isSpeaking => _isSpeaking;
  bool get voiceEnabled => _voiceEnabled;
  String get langCode => _currentLanguage == AppLanguage.hindi ? 'hi' : _currentLanguage == AppLanguage.marathi ? 'mr' : 'en';
  String get languageName => _currentLanguage == AppLanguage.hindi ? 'हिंदी' : _currentLanguage == AppLanguage.marathi ? 'मराठी' : 'English';

  // Get translated string from AppStrings
  String str(Map<String, Map<String, String>> category, String key) {
    return AppStrings.get(category, key, langCode);
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('app_language') ?? 0;
    _currentLanguage = AppLanguage.values[langIndex];
    _voiceEnabled = prefs.getBool('voice_enabled') ?? true;
    _speechRate = prefs.getDouble('speech_rate') ?? 0.45;
    await _setupTts();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _setupTts() async {
    try {
      if (Platform.isAndroid) {
        await _tts.setEngine("com.google.android.tts");
        await _tts.awaitSpeakCompletion(true);
      }
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
      }
      
      await _tts.setLanguage(_getTtsLanguage());
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);
      
      _tts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        notifyListeners();
      });
      debugPrint('TTS Setup Complete');
    } catch (e) {
      debugPrint('TTS Setup Error: $e');
    }
  }

  String _getTtsLanguage() {
    switch (_currentLanguage) {
      case AppLanguage.hindi: return 'hi-IN';
      case AppLanguage.marathi: return 'mr-IN';
      default: return 'en-US';
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_language', lang.index);
    await _tts.setLanguage(_getTtsLanguage());
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_enabled', enabled);
    if (!enabled) await stop();
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_voiceEnabled || text.isEmpty) return;
    if (!_isInitialized) await init();
    await stop();
    try {
      debugPrint('TTS Speaking: $text');
      _isSpeaking = true;
      notifyListeners();
      var result = await _tts.speak(text);
      debugPrint('TTS Result: $result');
      if (result != 1) {
        _isSpeaking = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS Stop Error: $e');
    }
    _isSpeaking = false;
    notifyListeners();
  }

  String tr(String en, {String? hi, String? mr}) {
    switch (_currentLanguage) {
      case AppLanguage.hindi: return hi ?? en;
      case AppLanguage.marathi: return mr ?? hi ?? en;
      default: return en;
    }
  }
}
