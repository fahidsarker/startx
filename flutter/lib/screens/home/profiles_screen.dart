import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/widgets/profiles/profile_password_section.dart';
import 'package:flutter_app/widgets/profiles/profile_personal_info_section.dart';
import 'package:flutter_app/widgets/profiles/profile_photo_section.dart';
import 'package:flutter_app/widgets/profiles/profile_section.dart';
import 'package:flutter_app/extensions/context.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.defPadding),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              ProfilePhotoSection(),
              const SizedBox(height: 24),

              // Personal Information Section
              ProfilePersonalInfoSection(),
              const SizedBox(height: 24),

              // Password Section
              ProfilePasswordSection(),
              const SizedBox(height: 24),

              ProfileSection(
                icon: Icons.logout,
                iconColor: context.c.error,
                title: 'Account',
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.c.error,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.c.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
