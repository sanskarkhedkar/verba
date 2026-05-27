import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../onboarding/providers/onboarding_provider.dart';

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
  String? _langB;
  String? _activeRecordingSpeaker;
  bool _isProcessing = false;
  String? _error;
  final List<_Turn> _turns = [];
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _maxTimer;

  String get _resolvedLangB {
    if (_langB != null) return _langB!;
    return ref.read(targetLanguageProvider);
  }

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
      if (_langA == _resolvedLangB) {
        _showSameLangDialog();
        return;
      }
      await _startRecording(speaker);
    }
  }

  void _showSameLangDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Same language selected', style: AppTypography.heading3),
        content: Text(
          'Both sides are set to the same language. Please choose a different language for one of the sides.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageMismatchDialog(String sourceLang) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Language mismatch', style: AppTypography.heading3),
        content: Text(
          'The speech does not match the selected side language. Please speak in $sourceLang.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLangPicker({required bool forA}) {
    final current = forA ? _langA : _resolvedLangB;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: AppConstants.supportedLanguages.map((lang) {
            final emoji = AppConstants.languageEmojis[lang] ?? '🌍';
            final selected = lang == current;
            return ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(lang,
                  style: AppTypography.bodyM.copyWith(
                    color:
                        selected ? AppColors.textAccent : AppColors.textPrimary,
                  )),
              trailing: selected
                  ? const Icon(Icons.check_rounded, color: AppColors.textAccent)
                  : null,
              onTap: () {
                setState(() {
                  if (forA) {
                    _langA = lang;
                  } else {
                    _langB = lang;
                  }
                  _error = null;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _startRecording(String speaker) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) return;

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
      final langB = _resolvedLangB;
      final srcLang = speaker == 'A' ? _langA : langB;
      final tgtLang = speaker == 'A' ? langB : _langA;

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

      final trimmedTranscript = transcript.trim();
      final translationService = ref.read(translationServiceProvider);
      final matchesLanguage = await translationService.matchesInputLanguage(
        trimmedTranscript,
        srcLang,
      );
      if (!matchesLanguage) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showLanguageMismatchDialog(srcLang);
        }
        return;
      }

      final result = await translationService.translateText(
        trimmedTranscript,
        sourceLang: srcLang,
        targetLang: tgtLang,
      );

      if (mounted) {
        setState(() {
          _turns.add(_Turn(
            speaker: speaker,
            original: trimmedTranscript,
            translated: result.translatedText,
          ));
          _isProcessing = false;
        });
        ref
            .read(analyticsServiceProvider)
            .logTranslation('face_to_face', srcLang, tgtLang);
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
    final langB = _resolvedLangB;
    final lastTurn = _turns.isEmpty ? null : _turns.last;

    // Each panel displays text in its own language.
    // When A speaks: panel A shows the transcript (lang A); panel B shows the translation (lang B).
    // When B speaks: panel A shows the translation (lang A); panel B shows the transcript (lang B).
    final textForA = lastTurn == null
        ? ''
        : lastTurn.speaker == 'A'
            ? lastTurn.original
            : lastTurn.translated;
    final textForB = lastTurn == null
        ? ''
        : lastTurn.speaker == 'B'
            ? lastTurn.original
            : lastTurn.translated;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Speaker B panel (rotated — faces the other person)
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: _SpeakerPanel(
                  label: langB,
                  isRecording: _activeRecordingSpeaker == 'B',
                  isProcessing:
                      _isProcessing && _activeRecordingSpeaker == null,
                  displayText: textForB,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LangChip(
                              language: _langA,
                              onTap: () => _showLangPicker(forA: true),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('↔'),
                            ),
                            _LangChip(
                              language: langB,
                              onTap: () => _showLangPicker(forA: false),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          final tmp = _langA;
                          _langA = langB;
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
                isProcessing: _isProcessing && _activeRecordingSpeaker == null,
                displayText: textForA,
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

class _LangChip extends StatelessWidget {
  const _LangChip({required this.language, required this.onTap});
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.languageEmojis[language] ?? '🌍';
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(language, style: AppTypography.bodyS),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more_rounded,
                size: 14, color: AppColors.textSecondary),
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
    required this.displayText,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool isRecording;
  final bool isProcessing;
  final String displayText;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasContent = displayText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (hasContent)
            Expanded(
              child: SingleChildScrollView(
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(displayText, style: AppTypography.heading3),
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(height: AppSpacing.lg),
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
            isRecording ? 'Tap to stop' : 'Tap to speak in $label',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
