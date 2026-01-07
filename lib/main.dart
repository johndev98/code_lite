import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CoursesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Các hàm hỗ trợ dùng chung ---
void _showUpdateDialog(
  BuildContext context,
  String title, {
  bool shouldPopScreen = false,
}) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: const Text("Nội dung bài học đang được cập nhật!"),
      actions: [
        CupertinoDialogAction(
          child: const Text("Đóng"),
          onPressed: () {
            Navigator.pop(ctx); // Đóng dialog
            if (shouldPopScreen) {
              Navigator.pop(context); // Quay lại màn hình trước đó nếu load lỗi
            }
          },
        ),
      ],
    ),
  );
}

// --- Model & Loader (Giữ nguyên logic của bạn) ---
class ContentItem {
  final String id, title, subtitle, image;
  final String? path;
  ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.path,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      path: json['path'],
    );
  }
}

class ContentLoader {
  static const String baseUrl =
      'https://raw.githubusercontent.com/johndev98/data_code/refs/heads/main/assets';

  static Future<List<ContentItem>> loadCollection(String path) async {
    final url = '$baseUrl/$path';
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception();
    final jsonMap = jsonDecode(response.body);
    return (jsonMap['items'] as List)
        .map((e) => ContentItem.fromJson(e))
        .toList();
  }
}

// --- UI Components ---
class CourseCard extends StatelessWidget {
  final String title, subtitle, imageUrl;
  final VoidCallback onTap;
  const CourseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 140,
            decoration: const BoxDecoration(color: CupertinoColors.systemGrey6),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, _, _) => Container(
                    color: CupertinoColors.systemGrey,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CupertinoColors.black.withValues(alpha: 0.0),
                        CupertinoColors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Courses')),
      child: SafeArea(
        child: FutureBuilder<List<ContentItem>>(
          future: ContentLoader.loadCollection('content/courses/index.json'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              // Hiển thị thông báo lỗi bằng Dialog
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showUpdateDialog(context, "Thông báo"),
              );
              return const Center(child: Text("Không thể tải nội dung"));
            }

            final items = snapshot.data ?? [];
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
                          ),
                        ),
                      );
                    } else {
                      _showUpdateDialog(context, item.title);
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

class CourseDetailScreen extends StatelessWidget {
  final String title, path, breadcrumb;
  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.path,
    required this.breadcrumb,
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
              // Nếu lỗi load file JSON (ví dụ file không tồn tại trên GitHub)
              // Tự động hiện dialog và khi đóng sẽ quay lại màn hình trước
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showUpdateDialog(context, title, shouldPopScreen: true),
              );
              return const Center(child: Text("Đang tải dữ liệu..."));
            }

            final lessons = snapshot.data ?? [];
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
                      // Nếu path trỏ đến một file index.json -> Mở tiếp danh sách Card
                      if (lesson.path!.endsWith('index.json')) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => CourseDetailScreen(
                              title: lesson.title,
                              path: lesson.path!,
                              breadcrumb: "$breadcrumb -> ${lesson.title}",
                            ),
                          ),
                        );
                      }
                      // Nếu path trỏ đến file bài học cụ thể (vd: variables.json) -> Mở trang đọc nội dung
                      else {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LessonReadingScreen(
                              // Bạn cần tạo thêm màn hình này
                              title: lesson.title,
                              path: lesson.path!,
                            ),
                          ),
                        );
                      }
                    } else {
                      _showUpdateDialog(context, lesson.title);
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

// --- Widget hiển thị Breadcrumb (Giữ nguyên logic của bạn) ---
class BreadcrumbTitle extends StatelessWidget {
  final String breadcrumb;
  const BreadcrumbTitle({super.key, required this.breadcrumb});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const style = TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        );
        List<String> parts = breadcrumb.split(' -> ');
        String currentDisplay = breadcrumb;

        if (_hasTextOverflow(currentDisplay, style, constraints.maxWidth)) {
          while (parts.length > 1) {
            parts.removeAt(0);
            currentDisplay = "... -> ${parts.join(' -> ')}";
            if (!_hasTextOverflow(
              currentDisplay,
              style,
              constraints.maxWidth,
            )) {
              break;
            }
          }
        }
        return Text(
          currentDisplay,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  bool _hasTextOverflow(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    return textPainter.width > maxWidth;
  }
}

class LessonReadingScreen extends StatelessWidget {
  final String title;
  final String path;

  const LessonReadingScreen({
    super.key,
    required this.title,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          // Ở đây load file json chứa nội dung bài học
          future: _loadLessonContent(path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Lỗi tải nội dung"));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['content'] ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  // Bạn có thể thêm widget hiển thị code ở đây
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadLessonContent(String path) async {
    final url =
        'https://raw.githubusercontent.com/johndev98/data_code/refs/heads/main/assets/$path';
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }
}
