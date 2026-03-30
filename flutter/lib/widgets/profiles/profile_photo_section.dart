import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resultx/resultx.dart';
import 'package:flutter_app/core/api_paths.dart';
import 'package:flutter_app/extensions/color.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/extensions/map.dart';
import 'package:flutter_app/extensions/riverpod.dart';
import 'package:flutter_app/extensions/xfile.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/widgets/profiles/profile_section.dart';

class ProfilePhotoSection extends HookConsumerWidget {
  const ProfilePhotoSection({super.key});

  Future<void> updateProfile(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    await ref.api
        .post(
          ApiPost.profileUpdatePhoto.path,
          body: {"file": await pickedFile.toMultipartFile()}.toFormData(),
        )
        .onSuccess((_) {
          ref.read(authProvider.notifier).reloadProfile();
        })
        .onError((e) {
          if (!context.mounted) return;
          context.showSnackBar('Photo upload failed!');
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final auth = ref.watch(authProvider);

    return ProfileSection(
      icon: Icons.account_circle_outlined,
      title: 'Profile Photo',
      child: Center(
        child: Column(
          children: [
            // Profile Photo Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.c.primary.wOpacity(0.1),
                border: Border.all(color: context.c.border, width: 2),
              ),
              child: isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : auth?.user.profilePhotoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: auth!.user.profilePhotoUrl!,
                        cacheKey: auth.user.profilePhotoUrl!.split('?').first,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : Icon(Icons.person, size: 60, color: context.c.primary),
            ),
            const SizedBox(height: 16),
            // Photo Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    isLoading.value = true;
                    await updateProfile(context, ref);
                    isLoading.value = false;
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    context.showSnackBar('Photo removed');
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
