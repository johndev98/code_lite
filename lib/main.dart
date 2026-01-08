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
          future: _loadLessonContent(path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Lỗi tải nội dung"));
            }

            final data = snapshot.data!;
            final List blocks = data['blocks'] ?? [];

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blocks.length,
              itemBuilder: (context, index) {
                final block = blocks[index];
                return _buildBlock(context, block);
              },
            );
          },
        ),
      ),
    );
  }

  // Hàm điều hướng render các loại block
  Widget _buildBlock(BuildContext context, Map<String, dynamic> block) {
    final type = block['type'];
    final value = block['value'] ?? '';

    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.activeBlue,
            ),
          ),
        );
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(value, style: const TextStyle(fontSize: 17, height: 1.5)),
        );
      case 'code':
        return _buildCodeBlock(value);
      case 'image':
        return SafeImageBlock(url: value, caption: block['caption']);
      case 'quiz':
        return QuizBlock(data: block);
      default:
        return const SizedBox.shrink();
    }
  }

  // Khối hiển thị Code
  Widget _buildCodeBlock(String code) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: CupertinoColors.activeOrange,
        ),
      ),
    );
  }

  // Khối hiển thị Hình ảnh

  Future<Map<String, dynamic>> _loadLessonContent(String path) async {
    final url =
        'https://raw.githubusercontent.com/johndev98/data_code/refs/heads/main/assets/$path';
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    return jsonDecode(response.body);
  }
}

// Khối câu hỏi trắc nghiệm (Quiz)
class QuizBlock extends StatefulWidget {
  final Map<String, dynamic> data;
  const QuizBlock({super.key, required this.data});

  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  int? selectedIndex;
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final List options = widget.data['options'] ?? [];
    final int correctAnswer = widget.data['answer'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data['question'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  isCorrect = (index == correctAnswer);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? (isCorrect
                            ? CupertinoColors.activeGreen.withValues(alpha: 0.2)
                            : CupertinoColors.systemRed.withValues(alpha: 0.2))
                      : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedIndex == index
                        ? (isCorrect
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemRed)
                        : CupertinoColors.systemGrey4,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "${String.fromCharCode(65 + index)}. ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(options[index])),
                    if (selectedIndex == index)
                      Icon(
                        isCorrect
                            ? CupertinoIcons.check_mark_circled
                            : CupertinoIcons.xmark_circle,
                        color: isCorrect
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemRed,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SafeImageBlock extends StatefulWidget {
  final String url;
  final String? caption;

  const SafeImageBlock({super.key, required this.url, this.caption});

  @override
  State<SafeImageBlock> createState() => _SafeImageBlockState();
}

class _SafeImageBlockState extends State<SafeImageBlock> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // Nếu xảy ra lỗi, trả về một widget rỗng không chiếm diện tích
    if (_hasError || widget.url.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
              // Xử lý khi load ảnh lỗi
              errorBuilder: (context, error, stackTrace) {
                // Sử dụng addPostFrameCallback để tránh lỗi setState trong khi build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                    });
                  }
                });
                return const SizedBox.shrink();
              },
            ),
          ),
          // Chỉ hiện caption nếu ảnh load thành công và có caption
          if (widget.caption != null && !_hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.caption!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
