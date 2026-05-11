import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
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

// ── Top-level helper: language picker sheet ───────────────────────────────────
void _showAllLanguagesSheet(
  BuildContext context,
  String currentLang,
  void Function(String) onSelect,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bgElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text('All languages', style: AppTypography.heading3),
          ),
          ...AppConstants.supportedLanguagesWithEnglish.map((lang) {
            final emoji = AppConstants.languageEmojis[lang] ?? '🌐';
            final isSelected = lang == currentLang;
            return ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(lang, style: AppTypography.bodyM),
              selected: isSelected,
              selectedTileColor: AppColors.glassBorder.withValues(alpha: 0.3),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.textAccent)
                  : null,
              onTap: () {
                onSelect(lang);
                Navigator.pop(ctx);
              },
            );
          }),
        ],
      ),
    ),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────
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
  bool _isNewUser = true;

  // Steps: name is LAST (after auth), skipped for returning users
  List<_OnboardingStep> get _steps => [
        _OnboardingStep(
            title: 'Start speaking today',
            subtitle: 'Translation when you need it. Practice when it matters.',
            kind: _StepKind.welcome),
        _OnboardingStep(
            title: 'Which language do you want to learn?',
            subtitle: 'Pick the language Verba should personalize first.',
            kind: _StepKind.language),
        _OnboardingStep(
            title: 'What is your current level?',
            subtitle: 'This sets the lesson difficulty.',
            kind: _StepKind.level),
        _OnboardingStep(
            title: 'Why are you learning?',
            subtitle: 'Your goal changes the phrases we teach.',
            kind: _StepKind.motivation),
        _OnboardingStep(
            title: 'How much time can you practice daily?',
            subtitle: 'Even five focused minutes can build a habit.',
            kind: _StepKind.dailyGoal),
        _OnboardingStep(
            title: 'What should Verba focus on?',
            subtitle: 'Choose one or more practice areas.',
            kind: _StepKind.focus),
        _OnboardingStep(
            title: 'Your confidence curve',
            subtitle:
                'Speaking practice turns translation dependency into recall.',
            kind: _StepKind.graph),
        _OnboardingStep(
            title: 'A faster path to usable speech',
            subtitle:
                'Short spoken drills compound faster than passive lessons.',
            kind: _StepKind.speed),
        _OnboardingStep(
            title: 'Building your plan',
            subtitle: 'We are matching goals, phrases, and daily practice.',
            kind: _StepKind.plan),
        _OnboardingStep(
            title: 'In 30 days',
            subtitle:
                'You will handle greetings, travel moments, and common replies.',
            kind: _StepKind.outcome),
        _OnboardingStep(
            title: 'Learners keep coming back',
            subtitle: 'Daily utility gives you a real reason to open the app.',
            kind: _StepKind.social),
        _OnboardingStep(
            title: 'Protect your streak',
            subtitle: 'Set a reminder and stay consistent.',
            kind: _StepKind.notifications),
        _OnboardingStep(
            title: 'Unlock unlimited speaking',
            subtitle: 'One plan. Full access.',
            kind: _StepKind.paywall),
        _OnboardingStep(
            title: 'Create your account',
            subtitle: 'Sign in to save your progress and sync across devices.',
            kind: _StepKind.auth),
        _OnboardingStep(
            title: 'What should we call you?',
            subtitle: 'Your tutor will use this in greetings.',
            kind: _StepKind.name),
      ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logOnboardingStart();
    });
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
                              style: AppTypography.bodyM
                                  .copyWith(color: AppColors.textSecondary)),
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
              if (step.kind == _StepKind.auth) ...[
                VerbaButton(
                  label: 'Skip — continue as guest',
                  secondary: true,
                  onPressed: _isNavigating
                      ? null
                      : () {
                          ref.read(analyticsServiceProvider).logAuthSkipped();
                          _next();
                        },
                ),
              ] else if (step.kind != _StepKind.paywall &&
                  step.kind != _StepKind.plan) ...[
                VerbaButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  trailingIcon: true,
                  onPressed: (_canContinue && !_isNavigating) ? _next : null,
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

  Future<void> _handleAuthSuccess(String uid, bool isNewUser) async {
    setState(() => _isNewUser = isNewUser);
    ref.read(analyticsServiceProvider)
      ..logSignUp('auth_wall')
      ..setUserId(uid);

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
      final analytics = ref.read(analyticsServiceProvider);
      analytics.logOnboardingStep(kind.name, _index);

      if (kind == _StepKind.name) {
        ref
            .read(onboardingProvider.notifier)
            .setDisplayName(_nameController.text);
      }

      if (kind == _StepKind.language) {
        analytics
            .logLanguageSelected(ref.read(onboardingProvider).targetLanguage);
      }

      // Anonymous sign-in at plan step
      if (kind == _StepKind.plan && !_anonymousSignedIn) {
        _anonymousSignedIn = true;
        try {
          final cred = await ref.read(authServiceProvider).signInAnonymously();
          final uid = cred.user?.uid;
          if (uid != null) {
            final obState = ref.read(onboardingProvider);
            final profile = UserProfile.fromOnboarding(uid, obState);
            await ref.read(firestoreServiceProvider).createUserProfile(profile);
          }
        } catch (_) {}
      }

      // Last step → go home
      if (_index == _steps.length - 1) {
        await _completeOnboarding();
        return;
      }

      // Determine next index; skip name step for returning users
      var nextIndex = _index + 1;
      if (nextIndex < _steps.length &&
          _steps[nextIndex].kind == _StepKind.name &&
          !_isNewUser) {
        nextIndex++; // skip name
        if (nextIndex >= _steps.length) {
          await _completeOnboarding();
          return;
        }
      }

      if (mounted) setState(() => _index = nextIndex);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Future<void> _completeOnboarding() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid != null) {
      ref
          .read(firestoreServiceProvider)
          .markOnboardingComplete(uid)
          .catchError((_) {});
    }
    ref
        .read(analyticsServiceProvider)
        .logOnboardingComplete(ref.read(onboardingProvider).targetLanguage);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
    } catch (_) {}
    if (mounted) context.go(RouteConstants.home);
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
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

// ── Step body dispatcher ──────────────────────────────────────────────────────
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
  final Future<void> Function(String uid, bool isNewUser) onAuthSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    return switch (kind) {
      // Welcome: no language picker — clean splash
      _StepKind.welcome => const SizedBox.shrink(),

      // Language: grid + "See all" sheet
      _StepKind.language => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionGrid(
              options: const [
                'English',
                'German',
                'Spanish',
                'French',
                'Italian',
                'Japanese',
              ],
              selected: state.targetLanguage,
              onTap: controller.setTargetLanguage,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _showAllLanguagesSheet(
                context,
                state.targetLanguage,
                controller.setTargetLanguage,
              ),
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: const Text('See all languages'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.glassBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      _StepKind.level => _OptionList(
          options: const [
            'A1 Beginner',
            'A2 Elementary',
            'B1 Intermediate',
            'B2 Upper Intermediate',
            'C1 Advanced',
          ],
          selected: state.level,
          onTap: (value) {
            controller.setLevel(value.split(' ').first);
            onAutoAdvance();
          },
        ),
      _StepKind.motivation => _OptionList(
          options: const [
            'travel',
            'business',
            'family',
            'personal',
            'academic',
            'culture',
            'moving abroad',
          ],
          selected: state.goalCategory,
          onTap: (value) {
            controller.setGoalCategory(value);
            onAutoAdvance();
          },
        ),
      _StepKind.dailyGoal => _OptionList(
          options: const [
            '5 minutes',
            '10 minutes recommended',
            '15 minutes',
            '20 minutes',
          ],
          selected: '${state.dailyGoalMinutes}',
          onTap: (value) {
            controller.setDailyGoalMinutes(int.parse(value.split(' ').first));
            onAutoAdvance();
          },
        ),
      _StepKind.focus => _OptionGrid(
          options: const [
            'speaking',
            'vocabulary',
            'pronunciation',
            'translation',
            'culture',
            'confidence',
          ],
          selected: state.focusAreas.join(','),
          multi: true,
          onTap: controller.toggleFocusArea,
        ),
      _StepKind.graph => const _InsightCard(
          icon: Icons.trending_up_rounded,
          title: 'Confidence rises with spoken reps',
          body:
              'Verba starts with phrases you actually need, then turns them into short speaking drills.',
        ),
      _StepKind.speed => const _InsightCard(
          icon: Icons.bolt_rounded,
          title: 'Translation first, learning second',
          body:
              'Every translated phrase can become a three-minute practice moment.',
        ),

      // Plan: animated checklist, auto-advances after 5 s
      _StepKind.plan => _PlanChecklist(onComplete: onAutoAdvance),
      _StepKind.outcome => const _InsightCard(
          icon: Icons.flag_rounded,
          title: 'Your first milestone',
          body:
              'Hold a short greeting exchange, understand common responses, and practice pronunciation daily.',
        ),
      _StepKind.social => const _InsightCard(
          icon: Icons.star_rounded,
          title: '4.8 average learner rating',
          body:
              'Built for adults who want real-world language, not disconnected trivia.',
        ),

      // Notifications: time picker + permission
      _StepKind.notifications => const _NotificationsStep(),

      // Auth: create or sign-in
      _StepKind.auth => _AuthStep(onAuthSuccess: onAuthSuccess),
      _StepKind.paywall => _PaywallAutoStep(onDone: onAutoAdvance),
      _StepKind.name => TextField(
          controller: nameController,
          autofocus: true,
          onChanged: ref.read(onboardingProvider.notifier).setDisplayName,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
    };
  }
}

// ── Notifications step ────────────────────────────────────────────────────────
class _NotificationsStep extends ConsumerStatefulWidget {
  const _NotificationsStep();

  @override
  ConsumerState<_NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends ConsumerState<_NotificationsStep> {
  bool _permissionGranted = false;
  bool _permissionRequested = false;

  Future<void> _requestPermission() async {
    final granted =
        await ref.read(localNotificationsServiceProvider).requestPermissions();
    if (mounted) {
      setState(() {
        _permissionRequested = true;
        _permissionGranted = granted;
      });
    }
    if (granted) {
      try {
        final time = ref.read(onboardingProvider).notificationTime;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reminder_time', time);
        await prefs.setBool('reminder_enabled', true);
        await ref
            .read(localNotificationsServiceProvider)
            .scheduleDailyReminder(time);
      } on Object {/* non-blocking */}
    }
  }

  Future<void> _pickTime() async {
    final current = ref.read(onboardingProvider).notificationTime;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 19,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (time != null && mounted) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      ref.read(onboardingProvider.notifier).setNotificationTime(formatted);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reminder_time', formatted);
        if (_permissionGranted) {
          await prefs.setBool('reminder_enabled', true);
          await ref
              .read(localNotificationsServiceProvider)
              .scheduleDailyReminder(formatted);
        }
      } on Object {/* non-blocking */}
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifTime = ref.watch(onboardingProvider).notificationTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Time picker card
        GlassCard(
          onTap: _pickTime,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.textAccent, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily reminder time',
                        style: AppTypography.bodyS
                            .copyWith(color: AppColors.textSecondary)),
                    Text(notifTime,
                        style: AppTypography.heading3
                            .copyWith(color: AppColors.textAccent)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Notification permission button
        if (_permissionGranted)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.md),
                Text('Notifications enabled', style: AppTypography.bodyM),
              ],
            ),
          )
        else
          VerbaButton(
            label: _permissionRequested
                ? 'Notifications blocked — tap to retry'
                : 'Enable notifications',
            icon: Icons.notifications_rounded,
            secondary: _permissionRequested,
            onPressed: _requestPermission,
          ),
      ],
    );
  }
}

// ── Paywall auto-step ─────────────────────────────────────────────────────────
class _PaywallAutoStep extends ConsumerStatefulWidget {
  const _PaywallAutoStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_PaywallAutoStep> createState() => _PaywallAutoStepState();
}

class _PaywallAutoStepState extends ConsumerState<_PaywallAutoStep> {
  bool _presented = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _present());
  }

  Future<void> _present() async {
    if (_presented || !mounted) return;
    _presented = true;

    if (kIsWeb) {
      widget.onDone();
      return;
    }

    final rcService = ref.read(revenueCatServiceProvider);
    if (!rcService.isInitialized) {
      widget.onDone();
      return;
    }

    Offering? offering;
    try {
      offering = await rcService.getCurrentOffering();
    } catch (_) {}

    if (!mounted) return;

    if (offering != null) {
      ref.read(analyticsServiceProvider).logPaywallShown();
      try {
        final result = await RevenueCatUI.presentPaywall(offering: offering);
        if (result == PaywallResult.purchased ||
            result == PaywallResult.restored) {
          ref.read(analyticsServiceProvider).logPaywallPurchased();
          // Sticky override drives UI immediately across all screens.
          if (mounted) ref.read(premiumOverrideProvider.notifier).state = true;
          rcService.markPremium();
          final uid = ref.read(authServiceProvider).currentUser?.uid;
          if (uid != null) {
            ref
                .read(firestoreServiceProvider)
                .updateSubscription(uid, isPremium: true)
                .catchError((_) {});
          }
        } else {
          ref.read(analyticsServiceProvider).logPaywallDismissed();
        }
      } catch (_) {}
    }

    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Auth step ─────────────────────────────────────────────────────────────────
class _AuthStep extends ConsumerStatefulWidget {
  const _AuthStep({required this.onAuthSuccess});
  final Future<void> Function(String uid, bool isNewUser) onAuthSuccess;

  @override
  ConsumerState<_AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends ConsumerState<_AuthStep> {
  bool _loading = false;
  String? _error;
  bool _showEmailForm = false;
  bool _signInMode = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _authWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();
      final isNew = cred.additionalUserInfo?.isNewUser ?? true;
      final uid =
          cred.user?.uid ?? ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null && mounted) await widget.onAuthSuccess(uid, isNew);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _authWithEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = _signInMode
          ? await ref
              .read(authServiceProvider)
              .signInWithEmail(_emailCtrl.text, _passCtrl.text)
          : await ref
              .read(authServiceProvider)
              .createWithEmail(_emailCtrl.text, _passCtrl.text);
      final isNew = !_signInMode;
      final uid =
          cred.user?.uid ?? ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null && mounted) await widget.onAuthSuccess(uid, isNew);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    // ignore: avoid_print
    print('[Auth] error: $raw');
    if (raw.contains('cancelled')) return 'Sign-in was cancelled.';
    if (raw.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect password.';
    }
    if (raw.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (raw.contains('invalid-email')) return 'Invalid email address.';
    if (raw.contains('network')) {
      return 'Network error. Check your connection and try again.';
    }
    if (raw.contains('ApiException: 10') || raw.contains('DEVELOPER_ERROR')) {
      return 'Google Sign-In configuration error. Please use email sign-in.';
    }
    return 'Sign-in failed: $raw';
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
            Text(
              _signInMode ? 'Sign in with email' : 'Create account',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: AppSpacing.lg),
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
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            VerbaButton(
              label: _signInMode ? 'Sign in' : 'Create account',
              icon: Icons.email_rounded,
              onPressed: _authWithEmail,
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
          onPressed: _authWithGoogle,
        ),
        const SizedBox(height: AppSpacing.md),
        VerbaButton(
          label: 'Continue with Email',
          icon: Icons.email_rounded,
          secondary: true,
          onPressed: () => setState(() {
            _signInMode = false;
            _showEmailForm = true;
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _signInMode = true;
              _showEmailForm = true;
            }),
            child: Text(
              'Already have an account? Sign in',
              style: AppTypography.bodyS.copyWith(color: AppColors.textAccent),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Plan animated checklist ───────────────────────────────────────────────────
class _PlanChecklist extends StatefulWidget {
  const _PlanChecklist({required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<_PlanChecklist> createState() => _PlanChecklistState();
}

class _PlanChecklistState extends State<_PlanChecklist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _items = [
    'Personal goal mapped',
    'Speaking drills selected',
    'Translation bridge enabled',
    'Daily lesson ready',
  ];

  static const _thresholds = [0.0, 0.25, 0.5, 0.75];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        final visibleCount = _thresholds.where((t) => progress >= t).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: AppTypography.bodyS
                        .copyWith(color: AppColors.textAccent),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.bgElevated,
                      color: AppColors.textAccent,
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Checklist
            GlassCard(
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    AnimatedOpacity(
                      opacity: i < visibleCount ? 1.0 : 0.15,
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              i < visibleCount
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: i < visibleCount
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child:
                                  Text(_items[i], style: AppTypography.bodyM),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
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
        final active = multi ? selected.contains(option) : selected == option;
        return GlassCard(
          onTap: () => onTap(option),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_circle_rounded : Icons.language_rounded,
                color: active ? AppColors.textAccent : AppColors.textSecondary,
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
                color: active ? AppColors.textAccent : AppColors.textSecondary,
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
              style:
                  AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Step model ────────────────────────────────────────────────────────────────
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
  paywall,
  auth,
  name,
}
