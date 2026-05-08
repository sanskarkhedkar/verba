import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/mascot_widget.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  bool _recorded = false;

  @override
  void dispose() {
    if (_recorded) {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        ref
            .read(firestoreServiceProvider)
            .recordConversation(uid)
            .ignore();
      }
    }
    super.dispose();
  }

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      isAi: true,
      text: 'Hallo! Wie kann ich dir heute helfen?',
      translation: 'Hello! How can I help you today?',
    ),
  ];
  bool _isRecording = false;
  bool _isProcessing = false;

  Future<void> _handleMic() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      setState(() {
        _isProcessing = false;
        _messages.add(const _ChatMessage(
          isAi: false,
          text: 'Ich möchte einen Kaffee, bitte.',
          translation: 'I would like a coffee, please.',
        ));
        _recorded = true;
      });
      // AI response
      await Future<void>.delayed(const Duration(milliseconds: 500));
      setState(() {
        _messages.add(const _ChatMessage(
          isAi: true,
          text: 'Natürlich! Groß oder klein?',
          translation: 'Of course! Large or small?',
        ));
      });
    } else {
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GradientText('AI Conversation',
                      style: AppTypography.heading3),
                  const Spacer(),
                  const MascotWidget(size: 36, state: MascotState.idle),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                itemCount: _messages.length,
                itemBuilder: (_, i) =>
                    _MessageBubble(message: _messages[i]),
              ),
            ),
            // Processing indicator
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Verba is thinking...'),
                  ],
                ),
              ),
            // Bottom controls
            _BottomBar(
              isRecording: _isRecording,
              onMicTap: _handleMic,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isRecording, required this.onMicTap});
  final bool isRecording;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isRecording
                    ? const LinearGradient(
                        colors: [AppColors.error, Color(0xFFDC2626)])
                    : const LinearGradient(colors: [
                        AppColors.primaryStart,
                        AppColors.primaryEnd
                      ]),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording
                            ? AppColors.error
                            : AppColors.primaryStart)
                        .withValues(alpha: 0.4),
                    blurRadius: isRecording ? 32 : 16,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRecording ? 'Tap to stop' : 'Tap to speak',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: message.isAi
              ? AppColors.bgElevated
              : AppColors.primaryStart.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: message.isAi ? Radius.zero : const Radius.circular(16),
            bottomRight:
                message.isAi ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: AppTypography.bodyM),
            const SizedBox(height: 4),
            Text(
              message.translation,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.isAi,
    required this.text,
    required this.translation,
  });
  final bool isAi;
  final String text;
  final String translation;
}
