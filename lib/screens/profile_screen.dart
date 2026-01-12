import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          largeTitle: Text('Profile'),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.person_circle,
                  size: 64,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thông tin cá nhân và cài đặt',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
