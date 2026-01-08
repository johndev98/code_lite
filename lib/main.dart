import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
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

// --- CONSTANTS ---
class AppConfig {
  static const String baseUrl =
      'https://raw.githubusercontent.com/johndev98/data_code/refs/heads/main/assets';
}

// --- UTILS ---
void _showExplanation(BuildContext context, String title, String content) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showUpdateDialog(
  BuildContext context,
  String title, {
  bool shouldPopScreen = false,
}) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: const Text("Nội dung đang được cập nhật!"),
      actions: [
        CupertinoDialogAction(
          child: const Text("Đóng"),
          onPressed: () {
            Navigator.pop(ctx);
            if (shouldPopScreen) Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

// --- MODELS ---
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

// --- LOADER ---
class ContentLoader {
  static Future<List<ContentItem>> loadCollection(String path) async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/$path'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception();
    final jsonMap = jsonDecode(response.body);
    return (jsonMap['items'] as List)
        .map((e) => ContentItem.fromJson(e))
        .toList();
  }
}

// --- SCREENS ---
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
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showUpdateDialog(context, "Lỗi kết nối"),
              );
              return const Center(child: Text("Lỗi tải dữ liệu"));
            }
            final items = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => CourseCard(
                title: items[index].title,
                subtitle: items[index].subtitle,
                imageUrl: items[index].image,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => CourseDetailScreen(
                      title: items[index].title,
                      path: items[index].path!,
                      breadcrumb: items[index].title,
                      languageId: items[index].id,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final String title, path, breadcrumb, languageId;
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
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showUpdateDialog(context, title, shouldPopScreen: true),
              );
              return const Center(child: Text("Đang tải..."));
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

class LessonReadingScreen extends StatelessWidget {
  final String title, path, languageId;
  const LessonReadingScreen({
    super.key,
    required this.title,
    required this.path,
    required this.languageId,
  });

  static final Map<String, Map<String, dynamic>> _dictionariesCache = {};

  Future<Map<String, dynamic>> _loadAllData() async {
    // Thêm timestamp để ép GitHub trả về file mới nhất ngay lập tức
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Tải bài học
    final lessonUrl = '${AppConfig.baseUrl}/$path?t=$timestamp';
    debugPrint('--- Đang tải bài học: $lessonUrl');

    final lRes = await http
        .get(Uri.parse(lessonUrl))
        .timeout(const Duration(seconds: 10));
    if (lRes.statusCode != 200) {
      throw Exception("Lỗi tải bài học: ${lRes.statusCode}");
    }

    final lessonData = jsonDecode(lRes.body);

    // 2. Xác định từ điển
    String? customPath = lessonData['dictionary_path'];
    // Nếu customPath có .json ở cuối thì xóa đi để code tự thêm đồng nhất
    if (customPath != null && customPath.endsWith('.json')) {
      customPath = customPath.replaceAll('.json', '');
    }

    String dictKey = customPath ?? 'languages/$languageId';

    if (!_dictionariesCache.containsKey(dictKey)) {
      try {
        // Xây dựng URL từ điển chuẩn
        String finalUrl;
        /*
        Khi đang phát triển bài học: Nên dùng thêm ?t=... để thấy thay đổi ngay lập tức.
    Khi đã phát hành app cho người dùng: Bạn có thể bỏ đoạn ?t=... đi để tận dụng Cache. 
    Việc dùng Cache giúp App load nhanh hơn và tiết kiệm pin cho người dùng vì CDN sẽ xử lý dữ liệu nhanh hơn máy chủ gốc.
    XÓA ?t=$timestamp khi phát hành:
    Giữ ?t=$timestamp khi phát triển:
    */
        if (customPath != null) {
          finalUrl = '${AppConfig.baseUrl}/$customPath.json?t=$timestamp';
        } else {
          finalUrl =
              '${AppConfig.baseUrl}/content/dictionary/languages/$languageId.json?t=$timestamp';
        }

        debugPrint('--- Đang tải từ điển: $finalUrl');

        final dRes = await http
            .get(Uri.parse(finalUrl))
            .timeout(const Duration(seconds: 10));
        if (dRes.statusCode == 200) {
          _dictionariesCache[dictKey] = jsonDecode(dRes.body);
          debugPrint('--- Đã tải từ điển thành công cho: $dictKey');
        } else {
          debugPrint('--- Không tìm thấy file từ điển (404) tại: $finalUrl');
        }
      } catch (e) {
        debugPrint('--- Lỗi kết nối khi tải từ điển: $e');
      }
    }

    return {'lesson': lessonData, 'active_dict_path': dictKey};
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Lỗi tải nội dung"));
            }

            final lesson = snapshot.data!['lesson'];
            final String activeDictPath = snapshot.data!['active_dict_path'];
            final List blocks = lesson['blocks'] ?? [];
            // Lấy từ điển từ cache
            final Map<String, dynamic>? dict =
                _dictionariesCache[activeDictPath];

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blocks.length,
              itemBuilder: (context, index) =>
                  _buildBlock(context, blocks[index], dict),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context,
    Map<String, dynamic> block,
    Map<String, dynamic>? dict,
  ) {
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
        return _buildCodeSection(
          context,
          value,
          block['language'] ?? languageId,
          block['keywords'],
          dict,
        );
      case 'image':
        return SafeImageBlock(url: value, caption: block['caption']);
      case 'quiz':
        return QuizBlock(data: block);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCodeSection(
    BuildContext context,
    String code,
    String lang,
    List? keywords,
    Map<String, dynamic>? dict,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xff282c34),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: HighlightView(
              code,
              language: lang,
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'MyCodeFont',
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
        if (keywords != null && dict != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((key) {
                final info = dict[key];
                if (info == null) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () =>
                      _showExplanation(context, info['title'], info['content']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: CupertinoColors.activeBlue.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// --- UI COMPONENTS ---
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
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, _) =>
                      Container(color: CupertinoColors.systemGrey6),
                  errorWidget: (_, _, _) => Container(
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
        String display = breadcrumb;
        if (_hasOverflow(display, style, constraints.maxWidth)) {
          while (parts.length > 1) {
            parts.removeAt(0);
            display = "... -> ${parts.join(' -> ')}";
            if (!_hasOverflow(display, style, constraints.maxWidth)) break;
          }
        }
        return Text(
          display,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  bool _hasOverflow(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    return tp.width > maxWidth;
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
  bool _err = false;
  @override
  Widget build(BuildContext context) {
    if (_err || widget.url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                height: 200,
                color: CupertinoColors.systemGrey6,
                child: const Center(child: CupertinoActivityIndicator()),
              ),
              errorWidget: (_, _, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _err = true);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
          if (widget.caption != null && !_err)
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

class QuizBlock extends StatefulWidget {
  final Map<String, dynamic> data;
  const QuizBlock({super.key, required this.data});
  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  int? _sel;
  @override
  Widget build(BuildContext context) {
    final List opt = widget.data['options'] ?? [];
    final int ans = widget.data['answer'] ?? 0;
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
          ...List.generate(opt.length, (i) {
            final isCorrect = (i == ans);
            return GestureDetector(
              onTap: () => setState(() => _sel = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _sel == i
                      ? (isCorrect
                            ? CupertinoColors.activeGreen.withValues(alpha: 0.2)
                            : CupertinoColors.systemRed.withValues(alpha: 0.2))
                      : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _sel == i
                        ? (isCorrect
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemRed)
                        : CupertinoColors.systemGrey4,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "${String.fromCharCode(65 + i)}. ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(opt[i])),
                    if (_sel == i)
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
