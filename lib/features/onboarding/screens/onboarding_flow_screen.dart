import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/mascot_widget.dart';
import '../../../core/widgets/verba_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _index = 0;
  final _nameController = TextEditingController();
  bool _anonymousSignedIn = false;
  bool _isNavigating = false;

  List<_OnboardingStep> get _steps => [
        _OnboardingStep(title: 'Start speaking today',
            subtitle: 'Translation when you need it. Practice when it matters.',
            kind: _StepKind.welcome),
        _OnboardingStep(title: 'Which language do you want to learn?',
            subtitle: 'Pick the language Verba should personalize first.',
            kind: _StepKind.language),
        _OnboardingStep(title: 'What is your current level?',
            subtitle: 'This sets the lesson difficulty.',
            kind: _StepKind.level),
        _OnboardingStep(title: 'Why are you learning?',
            subtitle: 'Your goal changes the phrases we teach.',
            kind: _StepKind.motivation),
        _OnboardingStep(title: 'How much time can you practice daily?',
            subtitle: 'Even five focused minutes can build a habit.',
            kind: _StepKind.dailyGoal),
        _OnboardingStep(title: 'What should Verba focus on?',
            subtitle: 'Choose one or more practice areas.',
            kind: _StepKind.focus),
        _OnboardingStep(title: 'Your confidence curve',
            subtitle: 'Speaking practice turns translation dependency into recall.',
            kind: _StepKind.graph),
        _OnboardingStep(title: 'A faster path to usable speech',
            subtitle: 'Short spoken drills compound faster than passive lessons.',
            kind: _StepKind.speed),
        _OnboardingStep(title: 'Building your plan',
            subtitle: 'We are matching goals, phrases, and daily practice.',
            kind: _StepKind.plan),
        _OnboardingStep(title: 'In 30 days',
            subtitle: 'You will handle greetings, travel moments, and common replies.',
            kind: _StepKind.outcome),
        _OnboardingStep(title: 'Learners keep coming back',
            subtitle: 'Daily utility gives you a real reason to open the app.',
            kind: _StepKind.social),
        _OnboardingStep(title: 'Protect your streak',
            subtitle: 'Choose a reminder time for a short daily session.',
            kind: _StepKind.notifications),
        _OnboardingStep(title: 'What should we call you?',
            subtitle: 'Your tutor will use this in greetings.',
            kind: _StepKind.name),
        _OnboardingStep(title: 'Create your account',
            subtitle: 'Sign in to save your progress and sync across devices.',
            kind: _StepKind.auth),
        _OnboardingStep(title: 'Unlock unlimited speaking',
            subtitle: 'Continue free today, or upgrade to premium.',
            kind: _StepKind.paywall),
      ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_index > 0)
                _Header(
                  index: _index,
                  progress: progress,
                  onBack: () => setState(() => _index -= 1),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    key: ValueKey(_index),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: MascotWidget(
                              size: _index == 0 ? 132 : 96,
                              state: _index == 8
                                  ? MascotState.thinking
                                  : MascotState.idle,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (_index == 0)
                            GradientText('Verba',
                                style: AppTypography.displayXL),
                          Text(step.title, style: AppTypography.heading1),
                          const SizedBox(height: AppSpacing.sm),
                          Text(step.subtitle,
                              style: AppTypography.bodyM.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xl),
                          _StepBody(
                            kind: step.kind,
                            nameController: _nameController,
                            onAutoAdvance: _next,
                            onAuthSuccess: _handleAuthSuccess,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Hide the bottom Continue button on the auth step;
              // auth buttons inside the step body handle advancement.
              if (step.kind != _StepKind.auth) ...[
                VerbaButton(
                  label: _index == _steps.length - 1
                      ? 'Continue with limited access'
                      : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: (_canContinue && !_isNavigating) ? _next : null,
                ),
                if (_index == _steps.length - 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  VerbaButton(
                    label: 'View paywall screen',
                    icon: Icons.workspace_premium_rounded,
                    secondary: true,
                    onPressed: () => context.push(RouteConstants.paywall),
                  ),
                ],
              ] else ...[
                // Skip sign-in option on auth step
                VerbaButton(
                  label: 'Skip — continue as guest',
                  secondary: true,
                  onPressed: _isNavigating ? null : _next,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _canContinue {
    if (_steps[_index].kind == _StepKind.name) {
      return _nameController.text.trim().length >= 2;
    }
    return true;
  }

  void _onNameChanged() {
    if (_steps[_index].kind == _StepKind.name) setState(() {});
  }

  Future<void> _handleAuthSuccess(String uid) async {
    // Create Firestore profile after successful auth
    try {
      final obState = ref.read(onboardingProvider);
      final profile = UserProfile.fromOnboarding(uid, obState);
      await ref.read(firestoreServiceProvider).createUserProfile(profile);

      final token =
          await ref.read(fcmServiceProvider).requestPermissionAndGetToken();
      if (token != null) {
        await ref.read(firestoreServiceProvider).updateFcmToken(uid, token);
      }

      await ref.read(revenueCatServiceProvider).setUserId(uid);
    } catch (_) {}

    _next();
  }

  Future<void> _next() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      final kind = _steps[_index].kind;

      if (kind == _StepKind.name) {
        ref
            .read(onboardingProvider.notifier)
            .setDisplayName(_nameController.text);
      }

      // Trigger anonymous sign-in at the plan loader step
      if (kind == _StepKind.plan && !_anonymousSignedIn) {
        _anonymousSignedIn = true;
        try {
          final cred =
              await ref.read(authServiceProvider).signInAnonymously();
          final uid = cred.user?.uid;
          if (uid != null) {
            final obState = ref.read(onboardingProvider);
            final profile = UserProfile.fromOnboarding(uid, obState);
            await ref
                .read(firestoreServiceProvider)
                .createUserProfile(profile);
          }
        } catch (_) {}
      }

      if (_index == _steps.length - 1) {
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid != null) {
          try {
            await ref
                .read(firestoreServiceProvider)
                .markOnboardingComplete(uid);
          } catch (_) {}
        }
        if (mounted) context.go(RouteConstants.home);
        return;
      }

      if (mounted) setState(() => _index += 1);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.index,
    required this.progress,
    required this.onBack,
  });

  final int index;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            Text('${index + 1}/15', style: AppTypography.bodyS),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.bgElevated,
          color: AppColors.textAccent,
          minHeight: 3,
        ),
      ],
    );
  }
}

class _StepBody extends ConsumerWidget {
  const _StepBody({
    required this.kind,
    required this.nameController,
    required this.onAutoAdvance,
    required this.onAuthSuccess,
  });

  final _StepKind kind;
  final TextEditingController nameController;
  final VoidCallback onAutoAdvance;
  final Future<void> Function(String uid) onAuthSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    return switch (kind) {
      _StepKind.welcome => _OptionGrid(
          options: const ['German', 'Spanish', 'French', 'Japanese', 'Korean'],
          selected: state.targetLanguage,
          onTap: controller.setTargetLanguage,
        ),
      _StepKind.language => _OptionGrid(
          options: const [
            'German', 'Spanish', 'French', 'Italian', 'Japanese', 'Korean'
          ],
          selected: state.targetLanguage,
          onTap: controller.setTargetLanguage,
        ),
      _StepKind.level => _OptionList(
          options: const [
            'A1 Beginner',
            'A2 Elementary',
            'B1 Intermediate',
            'B2 Upper Intermediate',
            'C1 Advanced'
          ],
          selected: state.level,
          onTap: (value) {
            controller.setLevel(value.split(' ').first);
            onAutoAdvance();
          },
        ),
      _StepKind.motivation => _OptionList(
          options: const [
            'travel', 'business', 'family', 'personal',
            'academic', 'culture', 'moving abroad'
          ],
          selected: state.goalCategory,
          onTap: (value) {
            controller.setGoalCategory(value);
            onAutoAdvance();
          },
        ),
      _StepKind.dailyGoal => _OptionList(
          options: const [
            '5 minutes', '10 minutes recommended', '15 minutes', '20 minutes'
          ],
          selected: '${state.dailyGoalMinutes}',
          onTap: (value) {
            controller.setDailyGoalMinutes(int.parse(value.split(' ').first));
            onAutoAdvance();
          },
        ),
      _StepKind.focus => _OptionGrid(
          options: const [
            'speaking', 'vocabulary', 'pronunciation',
            'translation', 'culture', 'confidence'
          ],
          selected: state.focusAreas.join(','),
          multi: true,
          onTap: controller.toggleFocusArea,
        ),
      _StepKind.graph => const _InsightCard(
          icon: Icons.trending_up_rounded,
          title: 'Confidence rises with spoken reps',
          body: 'Verba starts with phrases you actually need, then turns them into short speaking drills.',
        ),
      _StepKind.speed => const _InsightCard(
          icon: Icons.bolt_rounded,
          title: 'Translation first, learning second',
          body: 'Every translated phrase can become a three-minute practice moment.',
        ),
      _StepKind.plan => const _PlanChecklist(),
      _StepKind.outcome => const _InsightCard(
          icon: Icons.flag_rounded,
          title: 'Your first milestone',
          body: 'Hold a short greeting exchange, understand common responses, and practice pronunciation daily.',
        ),
      _StepKind.social => const _InsightCard(
          icon: Icons.star_rounded,
          title: '4.8 average learner rating',
          body: 'Built for adults who want real-world language, not disconnected trivia.',
        ),
      _StepKind.notifications => const _InsightCard(
          icon: Icons.notifications_active_rounded,
          title: 'Stay consistent',
          body: 'A short daily reminder keeps your streak alive. You can customize this anytime in settings.',
        ),
      _StepKind.name => TextField(
          controller: nameController,
          autofocus: true,
          onChanged: ref.read(onboardingProvider.notifier).setDisplayName,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
      _StepKind.auth => _AuthStep(onAuthSuccess: onAuthSuccess),
      _StepKind.paywall => const _InsightCard(
          icon: Icons.workspace_premium_rounded,
          title: 'Free tier available',
          body: 'Start free with 3 daily lessons. Upgrade to premium for unlimited access.',
        ),
    };
  }
}

// ── Auth step widget ──────────────────────────────────────────────────────────

class _AuthStep extends ConsumerStatefulWidget {
  const _AuthStep({required this.onAuthSuccess});
  final Future<void> Function(String uid) onAuthSuccess;

  @override
  ConsumerState<_AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends ConsumerState<_AuthStep> {
  bool _loading = false;
  String? _error;
  bool _showEmailForm = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _auth(Future<dynamic> Function() method) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await method();
      final uid = (result?.user?.uid as String?) ??
          ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null && mounted) await widget.onAuthSuccess(uid);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('cancelled')) return 'Sign-in was cancelled.';
    if (raw.contains('email-already-in-use')) return 'This email is already registered.';
    if (raw.contains('wrong-password')) return 'Incorrect password.';
    if (raw.contains('invalid-email')) return 'Invalid email address.';
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showEmailForm) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            VerbaButton(
              label: 'Create account',
              icon: Icons.email_rounded,
              onPressed: () {
                _auth(() => ref.read(authServiceProvider).createWithEmail(
                    _emailCtrl.text, _passCtrl.text));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _showEmailForm = false),
              child: const Text('← Back'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(_error!,
                style: AppTypography.bodyS.copyWith(color: AppColors.error)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        VerbaButton(
          label: 'Continue with Google',
          icon: Icons.account_circle_rounded,
          onPressed: () =>
              _auth(() => ref.read(authServiceProvider).signInWithGoogle()),
        ),
        const SizedBox(height: AppSpacing.md),
        VerbaButton(
          label: 'Continue with Email',
          icon: Icons.email_rounded,
          secondary: true,
          onPressed: () => setState(() => _showEmailForm = true),
        ),
      ],
    );
  }
}

// ── Shared option widgets ─────────────────────────────────────────────────────

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onTap;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final active =
            multi ? selected.contains(option) : selected == option;
        return GlassCard(
          onTap: () => onTap(option),
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.check_circle_rounded
                    : Icons.language_rounded,
                color: active
                    ? AppColors.textAccent
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(option, style: AppTypography.bodyM)),
            ],
          ),
        );
      },
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.selected,
    required this.onTap,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final active = option.contains(selected);
        return GlassCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          onTap: () => onTap(option),
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: active
                    ? AppColors.textAccent
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(option, style: AppTypography.bodyM)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textAccent, size: 36),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.heading3),
          const SizedBox(height: AppSpacing.sm),
          Text(body,
              style: AppTypography.bodyM
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PlanChecklist extends StatelessWidget {
  const _PlanChecklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Personal goal mapped',
      'Speaking drills selected',
      'Translation bridge enabled',
      'Daily lesson ready',
    ];
    return GlassCard(
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(item, style: AppTypography.bodyM)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String title;
  final String subtitle;
  final _StepKind kind;
}

enum _StepKind {
  welcome,
  language,
  level,
  motivation,
  dailyGoal,
  focus,
  graph,
  speed,
  plan,
  outcome,
  social,
  notifications,
  name,
  auth,
  paywall,
}
