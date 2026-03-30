import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/providers/users_provider.dart';

class UserAvatar extends ConsumerWidget {
  final String uid;
  final String? imgUrl;
  final String? fallbackText;
  final double? size;
  const UserAvatar({
    super.key,
    required this.uid,
    this.size,
    this.imgUrl,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (size != null) {
      return SizedBox(width: size, height: size, child: buildUI(context, ref));
    }
    return buildUI(context, ref);
  }

  Widget buildUI(BuildContext context, WidgetRef ref) {
    if (imgUrl != null) {
      return buildAvatar(imgUrl, fallbackText);
    }

    return fetchBuildUI(context, ref);
  }

  Widget buildAvatar(String? imgUrl, String? fallbackText) {
    if (imgUrl == null) {
      return CircleAvatar(
        child: Text(
          fallbackText != null && fallbackText.isNotEmpty
              ? fallbackText[0].toUpperCase()
              : 'U',
        ),
      );
    }
    return CircleAvatar(backgroundImage: CachedNetworkImageProvider(imgUrl));
  }

  Widget fetchBuildUI(BuildContext context, WidgetRef ref) {
    final details = ref.watch(userDetailProvider(userId: uid));
    if (details.isLoading) {
      return CircleAvatar();
    }
    if (details.hasError || details.value == null) {
      return CircleAvatar(child: Icon(Icons.error));
    }
    final user = details.value!;

    final userName = user.name;
    final imgUrl = user.profilePhotoUrl;
    return buildAvatar(imgUrl, userName);
  }
}
