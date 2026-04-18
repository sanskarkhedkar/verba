import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// ElevenLabs service — handles both TTS and STT via ElevenLabs API.
/// Drop your API key in AppConfig or via env before shipping.
class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  // ── Voice IDs ─────────────────────────────────────────────────────────────
  // Default AI tutor voice (Rachel — warm, neutral English)
  static const String _defaultVoiceId = '21m00Tcm4TlvDq8ikWAM';

  // Language-specific voice map (add more as needed)
  static const Map<String, String> _languageVoiceMap = {
    'es': 'pFZP5JQG7iQjIQuC4Bku', // Spanish voice
    'fr': 'mlngWJGDPrXuRQqNRHBj', // French voice
    'de': 'IKne3meq5aSn9XLyUdCD', // German voice
    'ja': '56AoDkrOh6qfVPDXZ7Pt', // Japanese voice
    'ko': 'TxGEqnHWrfWFTfGW9XjX', // Korean voice
  };

  late final Dio _dio;
  String _apiKey;

  ElevenLabsService({required String apiKey}) : _apiKey = apiKey {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
    ));
  }

  void updateApiKey(String key) {
    _apiKey = key;
    _dio.options.headers['xi-api-key'] = key;
  }

  // ── Text-to-Speech ────────────────────────────────────────────────────────

  /// Convert [text] to speech. Returns raw MP3 bytes for playback.
  /// [languageCode] selects the appropriate voice.
  /// [voiceId] overrides the automatic voice selection.
  Future<Uint8List> textToSpeech({
    required String text,
    String languageCode = 'en',
    String? voiceId,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double style = 0.0,
    bool useSpeakerBoost = true,
  }) async {
    final id = voiceId ??
        _languageVoiceMap[languageCode] ??
        _defaultVoiceId;

    try {
      final response = await _dio.post<List<int>>(
        '/text-to-speech/$id',
        queryParameters: {
          'output_format': 'mp3_44100_128',
        },
        data: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': stability,
            'similarity_boost': similarityBoost,
            'style': style,
            'use_speaker_boost': useSpeakerBoost,
          },
        }),
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      throw _mapError(e, 'TTS');
    }
  }

  /// Stream TTS audio for lower latency. Returns a stream of audio chunks.
  Stream<Uint8List> textToSpeechStream({
    required String text,
    String languageCode = 'en',
    String? voiceId,
  }) async* {
    final id = voiceId ??
        _languageVoiceMap[languageCode] ??
        _defaultVoiceId;

    try {
      final response = await _dio.post<ResponseBody>(
        '/text-to-speech/$id/stream',
        data: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          },
        }),
        options: Options(responseType: ResponseType.stream),
      );
      await for (final chunk in response.data!.stream) {
        yield Uint8List.fromList(chunk);
      }
    } on DioException catch (e) {
      throw _mapError(e, 'TTS Stream');
    }
  }

  // ── Speech-to-Text ────────────────────────────────────────────────────────

  /// Transcribe audio bytes to text using ElevenLabs Speech-to-Text (Scribe).
  /// [audioBytes] should be raw audio (mp3, wav, webm, ogg, m4a supported).
  /// [mimeType] e.g. 'audio/wav', 'audio/mp3', 'audio/webm'
  Future<SttResult> speechToText({
    required Uint8List audioBytes,
    String mimeType = 'audio/wav',
    String? languageCode,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioBytes,
          filename: 'audio.${_mimeToExt(mimeType)}',
          contentType: DioMediaType.parse(mimeType),
        ),
        'model_id': 'scribe_v1',
        if (languageCode != null) 'language_code': languageCode,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/speech-to-text',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'xi-api-key': _apiKey},
        ),
      );

      final data = response.data!;
      return SttResult(
        text: data['text'] as String? ?? '',
        languageCode: data['language_code'] as String? ?? 'en',
        confidence: (data['alignment']?['confidence'] as num?)?.toDouble() ?? 1.0,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'STT');
    }
  }

  // ── Pronunciation Assessment ───────────────────────────────────────────────

  /// Compare [spokenAudio] against a [referenceText] and return a score.
  /// This is a mock that uses STT + text comparison until ElevenLabs
  /// ships a native pronunciation endpoint.
  Future<PronunciationResult> assessPronunciation({
    required Uint8List spokenAudio,
    required String referenceText,
    String languageCode = 'en',
  }) async {
    final stt = await speechToText(
      audioBytes: spokenAudio,
      languageCode: languageCode,
    );
    final score = _computeSimilarity(
        stt.text.toLowerCase(), referenceText.toLowerCase());
    return PronunciationResult(
      transcript: stt.text,
      score: score,
      referenceText: referenceText,
      feedback: _feedbackForScore(score),
    );
  }

  // ── Voice list ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/voices');
      final voices = response.data?['voices'] as List? ?? [];
      return voices
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e, 'GetVoices');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _mimeToExt(String mime) {
    final m = mime.split('/').last.split(';').first.trim();
    const map = {'mpeg': 'mp3', 'mp4': 'mp4', 'webm': 'webm'};
    return map[m] ?? m;
  }

  ElevenLabsException _mapError(DioException e, String context) {
    final status = e.response?.statusCode;
    final msg = e.response?.data.toString() ?? e.message ?? 'Unknown error';
    return ElevenLabsException(
      context: context,
      statusCode: status,
      message: msg,
    );
  }

  // Simple character-level similarity (Jaccard on bigrams)
  double _computeSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    Set<String> bigrams(String s) {
      final result = <String>{};
      for (int i = 0; i < s.length - 1; i++) {
        result.add(s.substring(i, i + 2));
      }
      return result;
    }

    final bA = bigrams(a);
    final bB = bigrams(b);
    final intersection = bA.intersection(bB).length;
    final union = bA.union(bB).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  String _feedbackForScore(double score) {
    if (score >= 0.90) return 'Excellent pronunciation! 🎉';
    if (score >= 0.75) return 'Great job! Minor differences detected.';
    if (score >= 0.55) return 'Good effort! Try focusing on the highlighted words.';
    if (score >= 0.35) return 'Keep practicing — you\'re getting there!';
    return 'Let\'s try that again more slowly.';
  }
}

// ── Result models ──────────────────────────────────────────────────────────

class SttResult {
  final String text;
  final String languageCode;
  final double confidence;
  const SttResult({
    required this.text,
    required this.languageCode,
    required this.confidence,
  });
}

class PronunciationResult {
  final String transcript;
  final double score;
  final String referenceText;
  final String feedback;
  const PronunciationResult({
    required this.transcript,
    required this.score,
    required this.referenceText,
    required this.feedback,
  });

  int get scorePercent => (score * 100).round();
}

class ElevenLabsException implements Exception {
  final String context;
  final int? statusCode;
  final String message;
  const ElevenLabsException({
    required this.context,
    this.statusCode,
    required this.message,
  });

  @override
  String toString() =>
      'ElevenLabsException[$context] $statusCode: $message';
}
