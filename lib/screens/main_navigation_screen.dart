import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'communication_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: const [
                  HomeScreen(),
                  CoursesScreen(),
                  CommunicationScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: CupertinoTabBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    ref.read(selectedTabIndexProvider.notifier).state = index;
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.book),
                      label: 'Courses',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.chat_bubble_2),
                      label: 'Communication',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
