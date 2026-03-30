import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/extensions/color.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/core/theme/app_typography.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/widgets/signup_form.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.c.background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: context.c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.c.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.wOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your account',
                          style: AppTypography.displaySmall.copyWith(
                            color: context.c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect with friends and colleagues instantly. Get started for free.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SignupForm(
                      onRegister: (name, email, password) async {
                        return ref
                            .read(authProvider.notifier)
                            .register(name, email, password);
                      },
                    ),
                  ),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          context.c.primary.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
