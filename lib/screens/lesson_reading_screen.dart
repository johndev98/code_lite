import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../utils/dialogs.dart';
import '../widgets/safe_image_block.dart';
import '../widgets/quiz_block.dart';
import '../widgets/cupertino_divider.dart';

class LessonReadingScreen extends StatelessWidget {
  final String title;
  final String path;
  final String languageId;

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

    final lessonResponse = await http
        .get(Uri.parse(lessonUrl))
        .timeout(AppConfig.networkTimeout);
    
    if (lessonResponse.statusCode != 200) {
      throw Exception("Lỗi tải bài học: ${lessonResponse.statusCode}");
    }

    final lessonData = jsonDecode(lessonResponse.body) as Map<String, dynamic>;

    // 2. Xác định từ điển
    String? customPath = lessonData['dictionary_path'] as String?;
    // Nếu customPath có .json ở cuối thì xóa đi để code tự thêm đồng nhất
    if (customPath != null && customPath.endsWith('.json')) {
      customPath = customPath.replaceAll('.json', '');
    }

    String dictKey = customPath ?? 'languages/$languageId';

    if (!_dictionariesCache.containsKey(dictKey)) {
      try {
        // Xây dựng URL từ điển chuẩn
        final String finalUrl;
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

        final dictResponse = await http
            .get(Uri.parse(finalUrl))
            .timeout(AppConfig.networkTimeout);
        
        if (dictResponse.statusCode == 200) {
          _dictionariesCache[dictKey] = jsonDecode(dictResponse.body) as Map<String, dynamic>;
          debugPrint('--- Đã tải từ điển thành công cho: $dictKey');
        } else {
          debugPrint('--- Không tìm thấy file từ điển (404) tại: $finalUrl');
        }
      } catch (e) {
        debugPrint('--- Lỗi kết nối khi tải từ điển: $e');
      }
    }

    return {
      'lesson': lessonData,
      'active_dict_path': dictKey,
    };
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

            final data = snapshot.data!;
            final lesson = data['lesson'] as Map<String, dynamic>;
            final String activeDictPath = data['active_dict_path'] as String;
            final List blocks = lesson['blocks'] ?? [];
            // Lấy từ điển từ cache
            final Map<String, dynamic>? dict =
                _dictionariesCache[activeDictPath];

            if (blocks.isEmpty) {
              return const Center(child: Text("Không có nội dung"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blocks.length,
              itemBuilder: (context, index) =>
                  _buildBlock(context, blocks[index] as Map<String, dynamic>, dict),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlock(
      BuildContext context, Map<String, dynamic> block, Map<String, dynamic>? dict) {
    final type = block['type'] as String?;
    final value = block['value'] ?? '';

    switch (type) {
      case 'heading':
        return _buildHeading(value.toString());
      case 'text':
        return _buildText(value.toString());
      case 'analogy':
        return _buildAnalogy(
            block['concept']?.toString() ?? 'Khái niệm', value.toString());
      case 'comparison':
        return _buildComparison(
          block['wrong']?.toString() ?? '',
          block['right']?.toString() ?? '',
          block['reason']?.toString() ?? '',
        );
      case 'callout':
        return _buildCallout(value.toString(), block['style']?.toString() ?? 'info');
      case 'list':
        return _buildList(block['items'] as List? ?? []);
      case 'video':
        return _buildVideoBlock(value.toString(), block['caption']?.toString());
      case 'code':
        return _buildCodeSection(
          context,
          value.toString(),
          block['language']?.toString() ?? languageId,
          block['keywords'] as List?,
          dict,
        );
      case 'image':
        return SafeImageBlock(
          url: value.toString(),
          caption: block['caption']?.toString(),
        );
      case 'quiz':
        return QuizBlock(data: block);
      case 'divider':
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CupertinoDivider(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComparison(String wrong, String right, String reason) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _codeLabel("SAI ❌", wrong, CupertinoColors.systemRed),
          const SizedBox(height: 8),
          _codeLabel("ĐÚNG ✅", right, CupertinoColors.systemGreen),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "💡 Giải thích: $reason",
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeLabel(String label, String code, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: const TextStyle(fontFamily: 'MyCodeFont', fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalogy(String concept, String realWorld) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemIndigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemIndigo.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.lightbulb_fill,
                color: CupertinoColors.systemYellow,
              ),
              const SizedBox(width: 8),
              Text(
                "Liên tưởng thực tế: $concept",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemIndigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            realWorld,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallout(String text, String style) {
    final Color color;
    final IconData icon;

    switch (style) {
      case 'warning':
        color = CupertinoColors.systemOrange;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case 'tip':
        color = CupertinoColors.systemGreen;
        icon = CupertinoIcons.lightbulb_fill;
        break;
      default:
        color = CupertinoColors.activeBlue;
        icon = CupertinoIcons.info_circle_fill;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBlock(String url, String? caption) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (_, _) => Container(
              height: 200,
              color: CupertinoColors.systemGrey6,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              caption,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildList(List items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      " • ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(fontSize: 17, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 1.5,
          color: CupertinoColors.label,
        ),
      ),
    );
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
                  onTap: () => showExplanation(
                    context,
                    info['title']?.toString() ?? '',
                    info['content']?.toString() ?? '',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: CupertinoColors.activeBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      key.toString(),
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
