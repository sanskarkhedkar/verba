import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

class _Turn {
  const _Turn({
    required this.speaker,
    required this.original,
    required this.translated,
  });
  final String speaker; // 'A' or 'B'
  final String original;
  final String translated;
}

class FaceToFaceScreen extends ConsumerStatefulWidget {
  const FaceToFaceScreen({super.key});

  @override
  ConsumerState<FaceToFaceScreen> createState() => _FaceToFaceScreenState();
}

class _FaceToFaceScreenState extends ConsumerState<FaceToFaceScreen> {
  String _langA = 'English';
  String _langB = 'German';
  String? _activeRecordingSpeaker;
  bool _isProcessing = false;
  String? _error;
  final List<_Turn> _turns = [];
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _maxTimer;

  @override
  void dispose() {
    _maxTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _handleTap(String speaker) async {
    if (_isProcessing) return;

    if (_activeRecordingSpeaker == speaker) {
      await _stopAndProcess(speaker);
    } else {
      await _startRecording(speaker);
    }
  }

  Future<void> _startRecording(String speaker) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) return;

    // Stop any existing recording first
    if (_activeRecordingSpeaker != null) {
      await _recorder.stop();
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/f2f_${speaker}_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    _maxTimer?.cancel();
    _maxTimer = Timer(const Duration(seconds: 12), () {
      if (_activeRecordingSpeaker == speaker) {
        _stopAndProcess(speaker);
      }
    });

    if (mounted) setState(() => _activeRecordingSpeaker = speaker);
  }

  Future<void> _stopAndProcess(String speaker) async {
    _maxTimer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;

    setState(() {
      _activeRecordingSpeaker = null;
      _isProcessing = true;
      _error = null;
    });

    if (path == null) {
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final srcLang = speaker == 'A' ? _langA : _langB;
      final tgtLang = speaker == 'A' ? _langB : _langA;

      final transcript = await ref
          .read(sttServiceProvider)
          .transcribeAudio(File(path), srcLang);

      if (transcript.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _error = 'No speech detected. Try again.';
          });
        }
        return;
      }

      final result = await ref.read(translationServiceProvider).translateText(
            transcript.trim(),
            sourceLang: srcLang,
            targetLang: tgtLang,
          );

      if (mounted) {
        setState(() {
          _turns.add(_Turn(
            speaker: speaker,
            original: transcript.trim(),
            translated: result.translatedText,
          ));
          _isProcessing = false;
        });
        ref.read(analyticsServiceProvider).logTranslation(
              'face_to_face', srcLang, tgtLang);
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid != null) {
          ref.read(firestoreServiceProvider).recordTranslation(uid).ignore();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Could not process audio: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Speaker B panel (rotated — faces the other person)
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: _SpeakerPanel(
                  label: _langB,
                  isRecording: _activeRecordingSpeaker == 'B',
                  isProcessing: _isProcessing,
                  lastTurn: _turns.lastWhere(
                    (t) => t.speaker == 'B',
                    orElse: () => const _Turn(
                        speaker: 'B', original: '', translated: ''),
                  ),
                  accentColor: AppColors.primaryEnd,
                  onTap: () => _handleTap('B'),
                ),
              ),
            ),
            // Divider bar
            Container(
              color: AppColors.bgElevated,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          '$_langA ↔ $_langB',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyS,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          final tmp = _langA;
                          _langA = _langB;
                          _langB = tmp;
                          _error = null;
                        }),
                        icon: const Icon(Icons.swap_vert_rounded, size: 20),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        _error!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // Speaker A panel (normal orientation)
            Expanded(
              child: _SpeakerPanel(
                label: _langA,
                isRecording: _activeRecordingSpeaker == 'A',
                isProcessing: _isProcessing,
                lastTurn: _turns.lastWhere(
                  (t) => t.speaker == 'A',
                  orElse: () =>
                      const _Turn(speaker: 'A', original: '', translated: ''),
                ),
                accentColor: AppColors.primaryStart,
                onTap: () => _handleTap('A'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeakerPanel extends StatelessWidget {
  const _SpeakerPanel({
    required this.label,
    required this.isRecording,
    required this.isProcessing,
    required this.lastTurn,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool isRecording;
  final bool isProcessing;
  final _Turn lastTurn;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasContent = lastTurn.original.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (hasContent) ...[
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lastTurn.original,
                      style: AppTypography.bodyM
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(lastTurn.translated, style: AppTypography.heading3),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const Spacer(),
          if (isProcessing)
            const CircularProgressIndicator()
          else
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? accentColor : AppColors.bgElevated,
                  border: Border.all(color: accentColor, width: 2),
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 32)
                        ]
                      : null,
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 48,
                  color: isRecording ? Colors.white : accentColor,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRecording
                ? 'Tap to stop'
                : 'Tap to speak in $label',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
