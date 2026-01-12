import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_providers.dart';
import '../utils/error_handler.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Courses')),
      child: SafeArea(
        child: coursesAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text("Không có dữ liệu"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CourseCard(
                  title: item.title,
                  subtitle: item.subtitle,
                  imageUrl: item.image,
                  onTap: () {
                    if (item.path != null) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => CourseDetailScreen(
                            title: item.title,
                            path: item.path!,
                            breadcrumb: item.title,
                            languageId: item.id,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) {
            ErrorHandler.handleNetworkError(context, "Lỗi kết nối");
            return const Center(child: Text("Lỗi tải dữ liệu"));
          },
        ),
      ),
    );
  }
}
