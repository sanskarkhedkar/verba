import 'dart:convert';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';
import 'firebase_functions_service.dart';

class ElevenLabsService {
  ElevenLabsService([this._functions = const FirebaseFunctionsService()]);

  final FirebaseFunctionsService _functions;
  final AudioPlayer _player = AudioPlayer();

  // Per-session in-memory cache: key → file path
  final Map<String, String> _cache = {};

  String _cacheKey(String text, String voiceId, double speed) =>
      '${voiceId}_${speed}_${text.hashCode}';

  String _voiceId(String language) =>
      ApiConstants.voiceIds[language] ??
      ApiConstants.voiceIds['English'] ??
      'EXAVITQu4vr4xnSDxMaL';

  Future<void> speak(String text, String language) =>
      _play(text, language, speed: 1.0);

  Future<void> speakSlow(String text, String language) =>
      _play(text, language, speed: 0.7);

  Future<void> _play(String text, String language,
      {required double speed}) async {
    if (text.isEmpty) return;

    final voiceId = _voiceId(language);
    final fallbackVoiceId =
        ApiConstants.voiceIds['English'] ?? 'EXAVITQu4vr4xnSDxMaL';

    if (await _tryPlay(text, language, voiceId, speed)) return;
    if (voiceId != fallbackVoiceId) {
      await _tryPlay(text, 'English', fallbackVoiceId, speed);
    }
  }

  Future<bool> _tryPlay(
    String text,
    String language,
    String voiceId,
    double speed,
  ) async {
    try {
      final key = _cacheKey(text, voiceId, speed);
      String filePath;
      if (_cache.containsKey(key)) {
        filePath = _cache[key]!;
      } else {
        filePath = await _fetchAndCache(text, language, speed, key);
      }
      await _player.stop();
      await _player.setFilePath(filePath);
      await _player.play();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> _fetchAndCache(
    String text,
    String language,
    double speed,
    String key,
  ) async {
    final response = await _functions.call(
      'synthesizeSpeech',
      {
        'text': text,
        'language': language,
        'speed': speed,
      },
      timeout: const Duration(seconds: ApiConstants.apiTimeoutSeconds),
    );
    final audioBase64 = response['audioBase64'] as String? ?? '';
    if (audioBase64.isEmpty) throw Exception('Empty TTS audio response');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tts_$key.mp3');
    await file.writeAsBytes(base64Decode(audioBase64));
    _cache[key] = file.path;
    return file.path;
  }

  void dispose() {
    _player.dispose();
  }
}
