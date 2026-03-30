import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/preferences.dart';
import 'package:flutter_app/providers/api_provider.dart';
import '../core/theme/theme.dart';
import 'package:flutter_app/extensions/color.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = context.tp;
    final colors = themeProvider.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              colors.background,
              themeProvider.isDarkMode
                  ? colors.surface.wOpacity(0.8)
                  : colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // Logo and decorative elements
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decorative ripple effect
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  colors.primary.wOpacity(0.1),
                                  colors.primary.wOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary.wOpacity(0.1),
                                  border: Border.all(
                                    color: colors.primary.wOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.waves_rounded,
                                  size: 60,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content section
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to',
                            style: AppTypography.headlineMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ripple ',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Chat',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Experience the new wave of communication.\nFast, secure, and always connected.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                welcomeScreenShown.value = true;
                                context.go('/login');
                              },
                              child: const Text('Get Started'),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text.rich(
                            TextSpan(
                              text: 'By continuing, you agree to our ',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Policy',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
