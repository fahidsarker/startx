import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/core/theme/app_typography.dart';

class LoginForm extends StatefulWidget {
  final Future<bool> Function(String email, String password)? onLogin;
  const LoginForm({super.key, this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    // await Future.delayed(const Duration(seconds: 2));
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (widget.onLogin != null) {
      final success = await widget.onLogin!(email, password);
      if (mounted) {
        if (success) {
          context.showSnackBar('Login successful!');
        } else {
          context.showSnackBar('Login failed. Please check your credentials.');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Headline
          Column(
            crossAxisAlignment: context.isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome back to Ripple',
                style: AppTypography.displaySmall.copyWith(
                  color: context.c.textPrimary,
                ),
                textAlign: context.isWide ? TextAlign.start : TextAlign.center,
              ),

              const SizedBox(height: 8),
              Text(
                'Please enter your details to sign in.',
                style: AppTypography.bodyLarge.copyWith(
                  color: context.c.textSecondary,
                ),
                textAlign: context.isWide ? TextAlign.start : TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: AppTypography.labelLarge.copyWith(
                  color: context.c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: context.c.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: AppTypography.labelLarge.copyWith(
                  color: context.c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: context.c.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: context.c.textSecondary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Handle forgot password
                context.showSnackBar('Forgot password feature coming soon!');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: AppTypography.labelLarge.copyWith(
                  color: context.c.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Log In'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.go('/registration');
            },
            child: Text('Create an account'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
