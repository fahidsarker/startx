import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resultx/resultx.dart';
import 'package:flutter_app/core/api_paths.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/extensions/riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/widgets/profiles/profile_section.dart';
import 'package:flutter_app/widgets/ui/consume.dart';

class ProfilePersonalInfoSection extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  ProfilePersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditingName = useState(false);
    final isLoading = useState(false);
    final auth = ref.watch(authProvider);
    final nameController = useTextEditingController();

    return ProfileSection(
      icon: Icons.person_outline,
      title: 'Personal Information',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              initialValue: auth?.user.email ?? '',
              label: 'Email',
              prefixIcon: Icons.email_outlined,
              suffixIcon: Icons.lock_outline,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Consume(
              provider: authProvider,
              builder: (_, auth) {
                if (!isEditingName.value && nameController.text.isEmpty) {
                  nameController.text = auth?.user.name ?? '';
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: nameController,
                        label: 'Name',
                        prefixIcon: Icons.badge_outlined,
                        suffixIcon: isEditingName.value
                            ? null
                            : Icons.edit_outlined,
                        readOnly: !isEditingName.value,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isLoading.value)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.c.primary,
                        ),
                      )
                    else if (isEditingName.value) ...[
                      IconButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final newName = nameController.text.trim();
                            isLoading.value = true;
                            final (message, isError) = await ref.api
                                .post(
                                  ApiPost.profileUpdateName.path,
                                  body: {'name': newName},
                                )
                                .mapSuccess(
                                  (_) => ('Name updated successfully', false),
                                )
                                .resolve(onError: (err) => (err.message, true))
                                .whenComplete(() {
                                  isEditingName.value = false;
                                  isLoading.value = false;
                                  ref
                                      .read(authProvider.notifier)
                                      .reloadProfile();
                                })
                                .data;

                            if (!context.mounted) return;
                            context.showSnackBar(message, isError: isError);
                          }
                        },
                        icon: Icon(Icons.check, color: context.c.success),
                      ),
                      IconButton(
                        onPressed: () {
                          isEditingName.value = false;
                          nameController.text = auth?.user.name ?? '';
                        },
                        icon: Icon(Icons.close, color: context.c.error),
                      ),
                    ] else
                      IconButton(
                        onPressed: () {
                          isEditingName.value = true;
                        },
                        icon: Icon(Icons.edit, color: context.c.primary),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? initialValue,
    TextEditingController? controller,
    required String label,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
      validator: validator,
    );
  }
}
