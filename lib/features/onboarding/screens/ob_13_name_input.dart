import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mascot_widget.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob13NameInput extends ConsumerStatefulWidget {
  const Ob13NameInput({super.key});
  @override
  ConsumerState<Ob13NameInput> createState() => _Ob13NameInputState();
}

class _Ob13NameInputState extends ConsumerState<Ob13NameInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 13,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(child: const MascotWidget(size: 100)),
            const SizedBox(height: 32),
            const Text(
              'What should we\ncall you?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your tutor will greet you personally.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 28),
            ValueListenableBuilder(
              valueListenable: _ctrl,
              builder: (_, value, __) => TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Text('👤', style: TextStyle(fontSize: 20)),
                  ),
                  prefixIconConstraints: const BoxConstraints(),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.textMuted),
                          onPressed: _ctrl.clear,
                        )
                      : null,
                ),
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: ValueListenableBuilder(
                valueListenable: _ctrl,
                builder: (_, value, __) => GradientButton(
                  label: value.text.trim().isEmpty
                      ? 'Continue'
                      : 'Hi ${value.text.trim()}! Continue →',
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : () {
                          ref
                              .read(onboardingProvider.notifier)
                              .setUserName(_ctrl.text.trim());
                          context.go('/onboarding/auth');
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
