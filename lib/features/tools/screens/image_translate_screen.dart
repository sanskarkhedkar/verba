import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_config.dart';
import '../../../services/translation_service.dart';

/// Image translation screen (stubbed OCR): picks an image, extracts placeholder
/// text, and translates it so the UI flow is complete without OCR keys.
class ImageTranslateScreen extends ConsumerStatefulWidget {
  const ImageTranslateScreen({super.key});

  @override
  ConsumerState<ImageTranslateScreen> createState() => _ImageTranslateScreenState();
}

class _ImageTranslateScreenState extends ConsumerState<ImageTranslateScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  TranslationResult? _result;
  bool _loading = false;
  String _targetLang = 'en';
  static const _placeholderText =
      'Gracias por su visita.\nHorario: 9:00 - 18:00\nCerrado los lunes.';

  @override
  Widget build(BuildContext context) {
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
                      'Image Translate',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _targetLang,
                  decoration: const InputDecoration(labelText: 'Translate to'),
                  dropdownColor: AppColors.bgSurface,
                  iconEnabledColor: AppColors.textPrimary,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _targetLang = v);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _PickButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pick(ImageSource.gallery),
                    ),
                    const SizedBox(width: 12),
                    _PickButton(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: _imageFile == null
                        ? const Center(
                            child: Text(
                              'Pick an image with text to translate.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Extracted Text (stub)',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                _placeholderText,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const Spacer(),
                              _loading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _translate,
                                      child: const Text('Translate'),
                                    ),
                            ],
                          ),
                  ),
                ),
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

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1600);
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _result = null;
    });
  }

  Future<void> _translate() async {
    if (_imageFile == null) return;
    setState(() => _loading = true);
    final svc = ref.read(translationServiceProvider);
    try {
      final res = await svc.translate(
        text: _placeholderText,
        sourceLang: 'es',
        targetLang: _targetLang,
      );
      setState(() => _result = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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

