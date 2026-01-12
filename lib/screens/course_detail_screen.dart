import 'package:flutter/cupertino.dart';
import '../models/content_item.dart';
import '../utils/content_loader.dart';
import '../utils/error_handler.dart';
import '../utils/dialogs.dart';
import '../widgets/course_card.dart';
import '../widgets/breadcrumb_title.dart';
import 'lesson_reading_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String title;
  final String path;
  final String breadcrumb;
  final String languageId;
  
  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.path,
    required this.breadcrumb,
    required this.languageId,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: BreadcrumbTitle(breadcrumb: breadcrumb),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: FutureBuilder<List<ContentItem>>(
          future: ContentLoader.loadCollection(path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              ErrorHandler.handleNetworkErrorWithPop(context, title);
              return const Center(child: Text("Đang tải..."));
            }
            final lessons = snapshot.data ?? [];
            if (lessons.isEmpty) {
              return const Center(child: Text("Không có dữ liệu"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return CourseCard(
                  title: lesson.title,
                  subtitle: lesson.subtitle,
                  imageUrl: lesson.image,
                  onTap: () {
                    if (lesson.path != null) {
                      if (lesson.path!.endsWith('index.json')) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => CourseDetailScreen(
                              title: lesson.title,
                              path: lesson.path!,
                              breadcrumb: "$breadcrumb -> ${lesson.title}",
                              languageId: languageId,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LessonReadingScreen(
                              title: lesson.title,
                              path: lesson.path!,
                              languageId: languageId,
                            ),
                          ),
                        );
                      }
                    } else {
                      showUpdateDialog(context, lesson.title);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
