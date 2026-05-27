import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/verba_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../widgets/language_selector.dart';

class ImageTranslationScreen extends ConsumerStatefulWidget {
  const ImageTranslationScreen({super.key});

  @override
  ConsumerState<ImageTranslationScreen> createState() =>
      _ImageTranslationScreenState();
}

class _ImageTranslationScreenState
    extends ConsumerState<ImageTranslationScreen> {
  String _sourceLang = 'English';
  String? _targetLang;
  File? _imageFile;
  bool _isProcessing = false;
  String? _ocrText;
  String? _translation;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  String get _resolvedTargetLang {
    if (_targetLang != null) return _targetLang!;
    final learning = ref.read(onboardingProvider).targetLanguage;
    return learning.isEmpty || learning == _sourceLang ? 'German' : learning;
  }

  @override
  void initState() {
    super.initState();
    // Recover image captured before MIUI killed the process
    if (Platform.isAndroid) _recoverLostData();
  }

  Future<void> _recoverLostData() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty || !mounted) return;
      final file = response.file;
      if (file != null) {
        setState(() {
          _imageFile = File(file.path);
          _isProcessing = true;
          _ocrText = null;
          _translation = null;
          _error = null;
        });
        await _processPath(file.path);
      }
    } catch (_) {}
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    if (_sourceLang == _resolvedTargetLang) {
      _showSameLangDialog();
      return;
    }

    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null || !mounted) return;

      setState(() {
        _imageFile = File(picked.path);
        _isProcessing = true;
        _ocrText = null;
        _translation = null;
        _error = null;
      });

      await _processPath(picked.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Could not process image: $e';
        });
      }
    }
  }

  void _showSameLangDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Same language selected', style: AppTypography.heading3),
        content: Text(
          'Source and target languages are the same. Please choose a different language for either the source or the target.',
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

  Future<void> _processPath(String path) async {
    try {
      final ocrText = await ref.read(mlkitOcrServiceProvider).extractText(path);

      if (ocrText.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _error = 'No text detected in the image.';
          });
        }
        return;
      }

      final result = await ref.read(translationServiceProvider).translateText(
            ocrText.trim(),
            sourceLang: _sourceLang,
            targetLang: _resolvedTargetLang,
          );

      if (mounted) {
        setState(() {
          _ocrText = ocrText.trim();
          _translation = result.translatedText;
          _isProcessing = false;
        });
        ref
            .read(analyticsServiceProvider)
            .logTranslation('image', _sourceLang, _resolvedTargetLang);
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid != null) {
          ref.read(firestoreServiceProvider).recordTranslation(uid).ignore();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Could not process image: $e';
        });
      }
    }
  }

  void _reset() => setState(() {
        _imageFile = null;
        _ocrText = null;
        _translation = null;
        _error = null;
        _isProcessing = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text('Image Translation',
                        style: AppTypography.heading3,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: LanguageSelectorRow(
                sourceLang: _sourceLang,
                targetLang: _resolvedTargetLang,
                onSourceChanged: (l) => setState(() => _sourceLang = l),
                onTargetChanged: (l) => setState(() => _targetLang = l),
                onSwap: () => setState(() {
                  final tmp = _sourceLang;
                  _sourceLang = _resolvedTargetLang;
                  _targetLang = tmp;
                }),
              ),
            ),
            Expanded(
              child: _imageFile == null
                  ? _EmptyPrompt(onPickImage: _pickImage)
                  : _ImageView(
                      imageFile: _imageFile!,
                      isProcessing: _isProcessing,
                      ocrText: _ocrText,
                      translation: _translation,
                      error: _error,
                      targetLang: _resolvedTargetLang,
                      onReset: _reset,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.onPickImage});
  final void Function({required bool fromCamera}) onPickImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 56, color: AppColors.textAccent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Point your camera at any text',
              style: AppTypography.heading2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Menus, signs, labels — Verba reads and translates instantly.',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          VerbaButton(
            label: 'Take a photo',
            icon: Icons.camera_alt_rounded,
            onPressed: () => onPickImage(fromCamera: true),
          ),
          const SizedBox(height: AppSpacing.md),
          VerbaButton(
            label: 'Choose from gallery',
            icon: Icons.photo_library_rounded,
            secondary: true,
            onPressed: () => onPickImage(fromCamera: false),
          ),
        ],
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({
    required this.imageFile,
    required this.isProcessing,
    required this.ocrText,
    required this.translation,
    required this.error,
    required this.targetLang,
    required this.onReset,
  });

  final File imageFile;
  final bool isProcessing;
  final String? ocrText;
  final String? translation;
  final String? error;
  final String targetLang;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            imageFile,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isProcessing)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('Reading and translating...'),
              ],
            ),
          )
        else if (error != null)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(error!,
                style: AppTypography.bodyM.copyWith(color: AppColors.error)),
          )
        else if (ocrText != null && translation != null) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detected text',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Text(ocrText!, style: AppTypography.bodyL),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(targetLang,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Text(translation!, style: AppTypography.heading2),
                const SizedBox(height: AppSpacing.lg),
                VerbaButton(
                  label: 'Practice these phrases',
                  icon: Icons.record_voice_over_rounded,
                  onPressed: () => context.push(
                    RouteConstants.lesson,
                    extra: translation,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        VerbaButton(
          label: 'Scan another image',
          secondary: true,
          icon: Icons.camera_alt_rounded,
          onPressed: onReset,
        ),
      ],
    );
  }
}
