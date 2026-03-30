import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resultx/resultx.dart';
import 'package:flutter_app/core/api_paths.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/extensions/riverpod.dart';
import 'package:flutter_app/widgets/profiles/profile_section.dart';

class ProfilePasswordSection extends HookConsumerWidget {
  ProfilePasswordSection({super.key});
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChangingPassword = useState(false);

    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscureCurrentPassword = useState(true);
    final obscureNewPassword = useState(true);
    final obscureConfirmPassword = useState(true);

    final loading = useState(false);

    return ProfileSection(
      icon: Icons.lock_outline,
      title: 'Change Password',
      child: !isChangingPassword.value
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => isChangingPassword.value = true,
                child: const Text('Change Password'),
              ),
            )
          : Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: currentPasswordController,
                    label: 'Current Password',
                    isObscured: obscureCurrentPassword.value,
                    onToggleVisibility: () => obscureCurrentPassword.value =
                        !obscureCurrentPassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: newPasswordController,
                    label: 'New Password',
                    isObscured: obscureNewPassword.value,
                    onToggleVisibility: () =>
                        obscureNewPassword.value = !obscureNewPassword.value,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    isObscured: obscureConfirmPassword.value,
                    onToggleVisibility: () => obscureConfirmPassword.value =
                        !obscureConfirmPassword.value,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: loading.value
                              ? null
                              : () {
                                  currentPasswordController.clear();
                                  newPasswordController.clear();
                                  confirmPasswordController.clear();
                                  isChangingPassword.value = false;
                                },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading.value
                              ? null
                              : () async {
                                  if (_passwordFormKey.currentState
                                          ?.validate() ??
                                      false) {
                                    loading.value = true;

                                    final res = await ref.api
                                        .post(
                                          ApiPost.profileUpdatePassword.path,
                                          body: {
                                            'old_password':
                                                currentPasswordController.text,
                                            'new_password':
                                                newPasswordController.text,
                                          },
                                        )
                                        .mapSuccess((_) {
                                          currentPasswordController.clear();
                                          newPasswordController.clear();
                                          confirmPasswordController.clear();
                                          isChangingPassword.value = false;
                                          return true;
                                        })
                                        .resolve(onError: (_) => false)
                                        .whenComplete(() {
                                          loading.value = false;
                                        })
                                        .data;
                                    if (!context.mounted) return;
                                    context.showSnackBar(
                                      res == true
                                          ? 'Password updated successfully'
                                          : 'Failed to update password. Please try again.',
                                      isError: res != true,
                                    );
                                  }
                                },
                          child: const Text('Update Password'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
