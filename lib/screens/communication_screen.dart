import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunicationScreen extends ConsumerWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          largeTitle: Text('Communication'),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.chat_bubble_2,
                  size: 64,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Communication',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kết nối và giao tiếp với cộng đồng',
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
