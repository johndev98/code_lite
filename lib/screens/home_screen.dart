import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          // Không cần hero cho tab, tránh xung đột Hero giữa các tab
          transitionBetweenRoutes: false,
          largeTitle: Text('Dashboard'),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.home,
                  size: 64,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng bạn đến với ứng dụng học lập trình',
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
