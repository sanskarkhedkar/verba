import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

/// Microphone recording service using the `record` package.
/// Produces WAV/M4A bytes ready for ElevenLabs STT.
class MicrophoneService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _activePath;

  /// Request microphone permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  bool get isRecording => _activePath != null;

  /// Start recording to a temp file.
  Future<bool> startRecording() async {
    final granted = await requestPermission();
    if (!granted) return false;

    final dir = await getTemporaryDirectory();
    _activePath =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _activePath!,
      );
      return true;
    } catch (e) {
      debugPrint('[Mic] Start error: $e');
      _activePath = null;
      return false;
    }
  }

  /// Stop recording and return raw bytes.
  Future<Uint8List?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _activePath = null;
      if (path == null) return null;
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      // Clean up temp file
      await file.delete();
      return bytes;
    } catch (e) {
      debugPrint('[Mic] Stop error: $e');
      _activePath = null;
      return null;
    }
  }

  /// Cancel without returning bytes.
  Future<void> cancelRecording() async {
    await _recorder.cancel();
    _activePath = null;
  }

  void dispose() => _recorder.dispose();

  Stream<Amplitude> get amplitudeStream => _recorder.onAmplitudeChanged(
        const Duration(milliseconds: 100),
      );
}

final microphoneService = MicrophoneService();
