import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_typography.dart';
import 'package:flutter_app/extensions/context.dart';

class SignupForm extends StatefulWidget {
  final Future<bool> Function(String name, String email, String password)?
  onRegister;
  const SignupForm({super.key, this.onRegister});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      if (widget.onRegister != null) {
        final res = await widget.onRegister!(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        if (!res) {
          context.showSnackBar('Registration failed. Please try again.');
          return;
        }
        context.showSnackBar('Registration successful!');
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SignupTextField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: 'Email Address',
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
          const SizedBox(height: 20),
          SignupTextField(
            label: 'Password',
            hintText: 'Create a strong password',
            prefixIcon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            hasVisibilityToggle: true,
            isVisible: _isPasswordVisible,
            onVisibilityToggle: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            helpText: 'Must be at least 8 characters long.',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: 'Confirm Password',
            hintText: 'Confirm your password',
            prefixIcon: Icons.lock_outline,
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            hasVisibilityToggle: true,
            isVisible: _isConfirmPasswordVisible,
            onVisibilityToggle: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.c.primary,
                foregroundColor: context.c.onPrimary,
                disabledBackgroundColor: context.c.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: AppTypography.buttonLarge.copyWith(
                      color: context.c.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: context.c.onPrimary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: Text('Already have an account? Log in'),
          ),
          const SizedBox(height: 24),
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: context.c.border, height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'You are logging into',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.c.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.c.border, height: 1)),
            ],
          ),

          // Social Login Buttons
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'demo.ripplechat.app',
                style: AppTypography.buttonLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.c.success,
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  context.go('/connect-server');
                },
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: context.c.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'Update',
                      style: AppTypography.buttonMedium.copyWith(
                        color: context.c.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignupTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool hasVisibilityToggle;
  final bool? isVisible;
  final VoidCallback? onVisibilityToggle;
  final String? helpText;
  const SignupTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.hasVisibilityToggle = false,
    this.isVisible,
    this.onVisibilityToggle,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    // Helper method to create consistent label style
    TextStyle labelStyle = AppTypography.labelLarge.copyWith(
      color: context.c.textPrimary,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: AppTypography.bodyMedium.copyWith(
            color: context.c.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: context.c.textSecondary),
            suffixIcon: hasVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      (isVisible ?? false)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: context.c.textSecondary,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: context.c.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.c.primary, width: 2),
            ),
            filled: true,
            fillColor: context.c.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText!,
            style: AppTypography.bodySmall.copyWith(
              color: context.c.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
