import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speak_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/microphone_service.dart';
import '../../../services/audio_player_service.dart';
import '../../../services/elevenlabs_service.dart';

class SpeakScreen extends ConsumerStatefulWidget {
  const SpeakScreen({super.key});
  @override
  ConsumerState<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends ConsumerState<SpeakScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  final VerbaAudioPlayer _audioPlayer = VerbaAudioPlayer();

  // Hardcoded for demo — in production these come from user profile
  static const _targetLanguage = 'Spanish';
  static const _languageCode = 'es';
  static const _skillLevel = 'Beginner';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    // Add initial AI greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(speakSessionProvider).messages.isEmpty) {
        _addInitialGreeting();
      }
    });
  }

  void _addInitialGreeting() {
    ref.read(speakSessionProvider.notifier);
    // Initial message is pre-loaded in provider state
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _onMicPressed() async {
    final session = ref.read(speakSessionProvider);
    final notifier = ref.read(speakSessionProvider.notifier);

    if (session.sessionState == SpeakSessionState.idle) {
      // Start recording
      final started = await microphoneService.startRecording();
      if (started) {
        notifier.startListening();
      } else {
        _showPermissionDenied();
      }
    } else if (session.sessionState == SpeakSessionState.listening) {
      // Stop recording and process
      final bytes = await microphoneService.stopRecording();
      if (bytes != null && bytes.isNotEmpty) {
        await notifier.processAudio(
          audioBytes: bytes,
          targetLanguage: _targetLanguage,
          languageCode: _languageCode,
          skillLevel: _skillLevel,
        );
        // Play AI response if available
        final updatedSession = ref.read(speakSessionProvider);
        if (updatedSession.latestAudioBytes != null) {
          await _audioPlayer.playBytes(updatedSession.latestAudioBytes!);
        }
      } else {
        notifier.stopListening();
      }
    }
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone permission required for speaking practice.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(speakSessionProvider);

    // Auto-play TTS when new audio arrives
    ref.listen(speakSessionProvider, (prev, next) async {
      if (next.latestAudioBytes != null &&
          prev?.latestAudioBytes != next.latestAudioBytes) {
        await _audioPlayer.playBytes(next.latestAudioBytes!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(session),
              Expanded(child: _buildChat(session)),
              _buildBottomBar(session),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SpeakSessionModel session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.4), blurRadius: 12)
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Tutor — Spanish',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: session.sessionState == SpeakSessionState.idle
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _stateLabel(session.sessionState),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
            onPressed: () =>
                ref.read(speakSessionProvider.notifier).resetSession(),
          ),
        ],
      ),
    );
  }

  Widget _buildChat(SpeakSessionModel session) {
    final messages = session.messages.isEmpty
        ? [
            SpeakMessage(
              text:
                  '¡Hola! Soy tu tutor de IA. Practiquemos una conversación en español. Empieza diciendo: "Buenos días."',
              isAI: true,
              translation:
                  'Hi! I\'m your AI tutor. Let\'s practice a Spanish conversation. Start by saying: "Good morning."',
            )
          ]
        : session.messages;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length +
          (_isLoading(session.sessionState) ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == messages.length) return _buildTypingIndicator();
        return _buildMessage(messages[i]);
      },
    );
  }

  Widget _buildMessage(SpeakMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            msg.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (msg.isAI) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isAI
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: msg.isAI ? null : AppColors.primaryGradient,
                    color: msg.isAI ? AppColors.bgCard : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isAI ? 4 : 16),
                      bottomRight: Radius.circular(msg.isAI ? 16 : 4),
                    ),
                    border: msg.isAI
                        ? Border.all(color: AppColors.borderColor)
                        : null,
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5),
                  ),
                ),
                if (msg.translation != null) ...[
                  const SizedBox(height: 4),
                  Text(msg.translation!,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
                ],
                if (msg.correction != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✏️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(msg.correction!,
                              style: const TextStyle(
                                  color: AppColors.warning, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (msg.pronunciation != null) ...[
                  const SizedBox(height: 6),
                  _PronunciationChip(result: msg.pronunciation!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text('🤖', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                          0.3 + 0.7 * (i == 1 ? _pulse.value : (1 - _pulse.value))),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(SpeakSessionModel session) {
    final isListening = session.sessionState == SpeakSessionState.listening;
    final isIdle = session.sessionState == SpeakSessionState.idle;
    final isProcessing = _isLoading(session.sessionState);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _stateLabel(session.sessionState),
              key: ValueKey(session.sessionState),
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionBtn(
                icon: Icons.close_rounded,
                label: 'Cancel',
                onTap: isListening
                    ? () async {
                        await microphoneService.cancelRecording();
                        ref.read(speakSessionProvider.notifier).stopListening();
                      }
                    : null,
              ),
              // Mic button
              GestureDetector(
                onTap: (isIdle || isListening) && !isProcessing
                    ? _onMicPressed
                    : null,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) {
                    final scale =
                        isListening ? 1.0 + _pulse.value * 0.12 : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: isListening
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5271), Color(0xFFFF8A65)])
                          : isProcessing
                              ? LinearGradient(colors: [
                                  AppColors.primary.withOpacity(0.5),
                                  AppColors.primaryDark.withOpacity(0.5),
                                ])
                              : AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isListening
                                  ? AppColors.error
                                  : AppColors.primary)
                              .withOpacity(0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: isProcessing
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : Icon(
                            isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),
              ),
              _ActionBtn(
                icon: Icons.volume_up_rounded,
                label: 'Replay',
                onTap: session.latestAudioBytes != null
                    ? () => _audioPlayer.playBytes(session.latestAudioBytes!)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isLoading(SpeakSessionState s) =>
      s == SpeakSessionState.transcribing ||
      s == SpeakSessionState.thinking ||
      s == SpeakSessionState.speaking;

  String _stateLabel(SpeakSessionState s) {
    switch (s) {
      case SpeakSessionState.idle:
        return 'Tap to speak';
      case SpeakSessionState.listening:
        return 'Listening... tap again to stop';
      case SpeakSessionState.transcribing:
        return 'Transcribing...';
      case SpeakSessionState.thinking:
        return 'AI is thinking...';
      case SpeakSessionState.speaking:
        return 'Playing response...';
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap != null ? 1.0 : 0.3,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _PronunciationChip extends StatelessWidget {
  final PronunciationResult result;
  const _PronunciationChip({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.score >= 0.80
        ? AppColors.success
        : result.score >= 0.55
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${result.scorePercent}%',
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(result.feedback,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
