import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_config.dart';
import '../../../services/translation_service.dart';
import '../../../services/microphone_service.dart';

const _langOptions = [
  ('en', 'English'),
  ('es', 'Spanish'),
  ('fr', 'French'),
  ('de', 'German'),
  ('ja', 'Japanese'),
];

/// Voice translation screen:
/// 1) Record mic input
/// 2) Transcribe via ElevenLabs STT
/// 3) Translate text via TranslationService
class VoiceTranslateScreen extends ConsumerStatefulWidget {
  const VoiceTranslateScreen({super.key});

  @override
  ConsumerState<VoiceTranslateScreen> createState() =>
      _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends ConsumerState<VoiceTranslateScreen>
    with SingleTickerProviderStateMixin {
  bool _recording = false;
  bool _processing = false;
  String _status = 'Tap to start recording';
  String _targetLang = 'en';
  String _sourceLang = 'es';
  String? _transcript;
  TranslationResult? _result;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _stopAndProcess();
      return;
    }
    final ok = await microphoneService.startRecording();
    if (!ok) {
      _showSnack('Microphone permission required.');
      return;
    }
    setState(() {
      _recording = true;
      _status = 'Listening... tap to stop';
    });
  }

  Future<void> _stopAndProcess() async {
    setState(() {
      _recording = false;
      _processing = true;
      _status = 'Transcribing...';
    });

    Uint8List? bytes = await microphoneService.stopRecording();
    if (bytes == null || bytes.isEmpty) {
      setState(() {
        _processing = false;
        _status = 'No audio captured. Try again.';
      });
      return;
    }

    final sttSvc = ref.read(elevenLabsServiceProvider);
    final translateSvc = ref.read(translationServiceProvider);

    try {
      final stt = await sttSvc.speechToText(
        audioBytes: bytes,
        languageCode: _sourceLang,
      );
      setState(() {
        _transcript = stt.text;
        _status = 'Translating...';
      });
      final translated = await translateSvc.translate(
        text: stt.text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );
      setState(() {
        _result = translated;
        _status = 'Done';
      });
    } catch (e) {
      _showSnack('Could not process audio: $e');
      setState(() => _status = 'Tap to start recording');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !_processing;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Voice Translate',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LanguagePickers(
                  sourceLang: _sourceLang,
                  targetLang: _targetLang,
                  onChanged: (s, t) => setState(() {
                    _sourceLang = s;
                    _targetLang = t;
                  }),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: canTap ? _toggleRecording : null,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) {
                          final scale = _recording ? 1.0 + _pulse.value * 0.08 : 1.0;
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: _recording
                                ? const LinearGradient(
                                    colors: [Color(0xFFFF5271), Color(0xFFFF8A65)])
                                : AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_recording
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withOpacity(0.45),
                                blurRadius: 26,
                              )
                            ],
                          ),
                          child: Center(
                            child: _processing
                                ? const SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_transcript != null) _TranscriptCard(text: _transcript!),
                if (_result != null) ...[
                  const SizedBox(height: 12),
                  _TranslationCard(result: _result!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final String text;
  const _TranscriptCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transcript',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final TranslationResult result;
  const _TranslationCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Translation',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            result.translatedText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Detected: ${result.detectedSourceLang.toUpperCase()} → ${result.targetLang.toUpperCase()}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LanguagePickers extends StatelessWidget {
  final String sourceLang;
  final String targetLang;
  final void Function(String src, String tgt) onChanged;

  const _LanguagePickers({
    required this.sourceLang,
    required this.targetLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: sourceLang,
            decoration: const InputDecoration(labelText: 'From'),
            dropdownColor: AppColors.bgSurface,
            iconEnabledColor: AppColors.textPrimary,
            items: _langOptions
                .map((l) => DropdownMenuItem(
                      value: l.$1,
                      child: Text(l.$2,
                          style: const TextStyle(color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v, targetLang);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: targetLang,
            decoration: const InputDecoration(labelText: 'To'),
            dropdownColor: AppColors.bgSurface,
            iconEnabledColor: AppColors.textPrimary,
            items: _langOptions
                .map((l) => DropdownMenuItem(
                      value: l.$1,
                      child: Text(l.$2,
                          style: const TextStyle(color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(sourceLang, v);
            },
          ),
        ),
      ],
    );
  }
}
