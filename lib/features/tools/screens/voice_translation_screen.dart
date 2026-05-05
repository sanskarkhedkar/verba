import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/verba_button.dart';
import '../widgets/language_selector.dart';

class VoiceTranslationScreen extends ConsumerStatefulWidget {
  const VoiceTranslationScreen({super.key});

  @override
  ConsumerState<VoiceTranslationScreen> createState() =>
      _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState
    extends ConsumerState<VoiceTranslationScreen> {
  String _sourceLang = 'English';
  String _targetLang = 'German';
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcript;
  String? _translation;
  String? _error;

  final AudioRecorder _recorder = AudioRecorder();

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  void _swap() => setState(() {
        final tmp = _sourceLang;
        _sourceLang = _targetLang;
        _targetLang = tmp;
        _transcript = null;
        _translation = null;
        _error = null;
      });

  Future<void> _toggleRecording() async {
    if (_isProcessing) return;
    if (_isRecording) {
      await _stopAndProcess();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_trans_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    if (mounted) {
      setState(() {
        _isRecording = true;
        _transcript = null;
        _translation = null;
      });
    }
  }

  Future<void> _stopAndProcess() async {
    final path = await _recorder.stop();
    if (!mounted) return;
    if (path == null) {
      setState(() => _isRecording = false);
      return;
    }

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _error = null;
    });

    try {
      final transcript = await ref
          .read(sttServiceProvider)
          .transcribeAudio(File(path), _sourceLang);

      if (transcript.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _error = 'No speech detected. Try speaking clearly into the mic.';
          });
        }
        return;
      }

      final result = await ref.read(translationServiceProvider).translateText(
            transcript.trim(),
            sourceLang: _sourceLang,
            targetLang: _targetLang,
          );

      if (mounted) {
        setState(() {
          _transcript = transcript.trim();
          _translation = result.translatedText;
          _isProcessing = false;
        });
        ref.read(analyticsServiceProvider).logTranslation(
              'voice', _sourceLang, _targetLang);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Translation failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text('Voice Translation',
                        style: AppTypography.heading3,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LanguageSelectorRow(
                sourceLang: _sourceLang,
                targetLang: _targetLang,
                onSourceChanged: (l) => setState(() => _sourceLang = l),
                onTargetChanged: (l) => setState(() => _targetLang = l),
                onSwap: _swap,
              ),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isRecording
                        ? const LinearGradient(
                            colors: [AppColors.error, Color(0xFFDC2626)],
                          )
                        : const LinearGradient(
                            colors: [
                              AppColors.primaryStart,
                              AppColors.primaryEnd,
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? AppColors.error
                                : AppColors.primaryStart)
                            .withValues(alpha: 0.4),
                        blurRadius: _isRecording ? 40 : 20,
                        spreadRadius: _isRecording ? 8 : 0,
                      ),
                    ],
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Icon(
                          _isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _isRecording
                    ? 'Listening... tap to stop'
                    : _isProcessing
                        ? 'Translating...'
                        : 'Tap to speak',
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(_error!,
                            style: AppTypography.bodyS
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              if (_transcript != null && _translation != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sourceLang,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                      Text(_transcript!, style: AppTypography.bodyL),
                      const Divider(height: AppSpacing.xl),
                      Text(_targetLang,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                      Text(_translation!, style: AppTypography.heading2),
                      const SizedBox(height: AppSpacing.lg),
                      VerbaButton(
                        label: 'Practice this phrase',
                        icon: Icons.record_voice_over_rounded,
                        onPressed: () =>
                            context.push(RouteConstants.lesson),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
