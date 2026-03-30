import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/extensions/color.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/core/theme/app_typography.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          if (context.isWide) const Expanded(child: RippleChatLoginHeroArea()),
          Expanded(
            child: Container(
              color: context.c.background,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                children: [
                  if (!context.isWide) ...[
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: context.c.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.waves,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: LoginForm(
                          key: const Key('login_form'),
                          onLogin: (email, pass) async {
                            return await ref
                                .read(authProvider.notifier)
                                .login(email, pass);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RippleChatLoginHeroArea extends StatelessWidget {
  const RippleChatLoginHeroArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111418),
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/ripple.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.c.primary.wOpacity(0.1),
              const Color(0xFF101922).wOpacity(0.5),
              const Color(0xFF101922).wOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Icon
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: context.c.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.c.primary.wOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.waves, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 24),
            // Headline
            Text(
              'Connect instantly.\nChat seamlessly.',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'Experience the next generation of communication with Ripple Chat. Secure, fast, and built for connection.',
              style: AppTypography.bodyLarge.copyWith(
                color: const Color(0xFF93AEBF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
