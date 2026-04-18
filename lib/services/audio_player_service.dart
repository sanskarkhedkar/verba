import 'dart:io';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Plays raw audio bytes (MP3) returned from ElevenLabs TTS.
class VerbaAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  /// Play TTS audio bytes from ElevenLabs.
  /// Writes bytes to a temp file then streams via just_audio.
  Future<void> playBytes(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes, flush: true);
      await _player.setFilePath(file.path);
      await _player.play();
    } catch (e) {
      // Log and swallow — UI should not crash on audio failure
      // ignore: avoid_print
      print('[VerbaAudioPlayer] Error: $e');
    }
  }

  Future<void> stop() => _player.stop();
  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();

  void dispose() => _player.dispose();

  Stream<PlayerState> get stateStream => _player.playerStateStream;
  bool get isPlaying => _player.playing;
}
