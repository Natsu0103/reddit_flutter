import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double iconSize = kIsWeb ? 40 : 30;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
        backgroundColor: currentTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => navigateToType(context, 'image'),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: iconSize,
                    color: currentTheme.iconTheme.color,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () => navigateToType(context, 'text'),
              child: Row(
                children: [
                  Icon(
                    Icons.font_download_outlined,
                    size: iconSize,
                    color: currentTheme.iconTheme.color,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Text',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () => navigateToType(context, 'link'),
              child: Row(
                children: [
                  Icon(
                    Icons.link_outlined,
                    size: iconSize,
                    color: currentTheme.iconTheme.color,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Link',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ThemeData {
  Color get backgroundColor => colorScheme.background;
}

