import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';

class ElevenLabsService {
  ElevenLabsService();

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

  Future<void> _play(String text, String language, {required double speed}) async {
    if (text.isEmpty || ApiConstants.elevenLabsApiKey.isEmpty) return;

    try {
      final voiceId = _voiceId(language);
      final key = _cacheKey(text, voiceId, speed);

      String filePath;
      if (_cache.containsKey(key)) {
        filePath = _cache[key]!;
      } else {
        filePath = await _fetchAndCache(text, voiceId, speed, key);
      }

      await _player.stop();
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (_) {
      // Fail silently — audio is enhancement, not blocking
    }
  }

  Future<String> _fetchAndCache(
    String text,
    String voiceId,
    double speed,
    String key,
  ) async {
    final response = await http
        .post(
          Uri.parse(
            '${ApiConstants.elevenLabsBaseUrl}'
            '${ApiConstants.elevenLabsTtsEndpoint}/$voiceId',
          ),
          headers: {
            'xi-api-key': ApiConstants.elevenLabsApiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          body: '''{"text":${_jsonString(text)},"model_id":"eleven_multilingual_v2","voice_settings":{"stability":0.8,"similarity_boost":0.7,"speed":$speed}}''',
        )
        .timeout(Duration(seconds: ApiConstants.apiTimeoutSeconds));

    if (response.statusCode != 200) {
      throw Exception('ElevenLabs ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tts_$key.mp3');
    await file.writeAsBytes(response.bodyBytes);
    _cache[key] = file.path;
    return file.path;
  }

  String _jsonString(String s) =>
      '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';

  void dispose() {
    _player.dispose();
  }
}
