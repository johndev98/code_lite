import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import '../providers/lesson_providers.dart';
import '../utils/dialogs.dart';
import '../widgets/safe_image_block.dart';
import '../widgets/quiz_block.dart';
import '../widgets/cupertino_divider.dart';
import '../widgets/key_concepts_block.dart';
import '../widgets/step_by_step_block.dart';
import '../widgets/practice_block.dart';
import '../widgets/summary_block.dart';
import '../widgets/checkpoint_block.dart';

class LessonReadingScreen extends ConsumerWidget {
  final String title;
  final String path;
  final String languageId;

  const LessonReadingScreen({
    super.key,
    required this.title,
    required this.path,
    required this.languageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonParams = LessonParams(path: path, languageId: languageId);
    final lessonDataAsync = ref.watch(lessonDataProvider(lessonParams));

    // Tối ưu: chỉ watch dictionary cache khi cần, tránh rebuild không cần thiết
    final activeDictPath =
        lessonDataAsync.value?['active_dict_path'] as String?;
    final dict = activeDictPath != null
        ? ref.watch(
            dictionaryCacheProvider.select((cache) => cache[activeDictPath]),
          )
        : null;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: lessonDataAsync.when(
          data: (data) {
            final lesson = data['lesson'] as Map<String, dynamic>;
            final List blocks = lesson['blocks'] ?? [];
            final Map<String, dynamic>? courseIndex =
                data['course_index'] as Map<String, dynamic>?;
            String? nextPath;
            String? nextTitle;
            bool isLastLesson = false;

            if (courseIndex != null) {
              final List items = courseIndex['items'] as List? ?? [];
              final String currentPath = path;
              int currentIndex = items.indexWhere((item) {
                final map = item as Map<String, dynamic>;
                return map['path'] == currentPath;
              });
              if (currentIndex != -1 && currentIndex + 1 < items.length) {
                final next = items[currentIndex + 1] as Map<String, dynamic>;
                nextPath = next['path'] as String?;
                nextTitle = next['title']?.toString();
              } else {
                isLastLesson = true;
              }
            }

            if (blocks.isEmpty) {
              return const Center(child: Text("Không có nội dung"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: blocks.length + 1, // +1 cho button tiếp tục
              itemBuilder: (context, index) {
                // Nếu là item cuối cùng, render button tiếp tục
                if (index == blocks.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: _buildNextLessonButton(
                      context,
                      nextPath: nextPath,
                      nextTitle: nextTitle,
                      isLastLesson: isLastLesson,
                    ),
                  );
                }
                // Render block bình thường
                return _buildBlock(
                  context,
                  blocks[index] as Map<String, dynamic>,
                  dict,
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) =>
              const Center(child: Text("Lỗi tải nội dung")),
        ),
      ),
    );
  }

  Widget _buildNextLessonButton(
    BuildContext context, {
    required String? nextPath,
    required String? nextTitle,
    required bool isLastLesson,
  }) {
    final bool hasNext = nextPath != null && nextPath.isNotEmpty;
    final String buttonText = hasNext && !isLastLesson
        ? "Tiếp tục: ${nextTitle ?? 'Bài tiếp theo'}"
        : "Hoàn thành khoá học";

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(vertical: 14),
          borderRadius: BorderRadius.circular(12),
          onPressed: () {
            if (!hasNext || isLastLesson) {
              _showCourseCompletedDialog(context);
            } else {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (_) => LessonReadingScreen(
                    title: nextTitle ?? "Bài tiếp theo",
                    path: nextPath,
                    languageId: languageId,
                  ),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasNext && !isLastLesson) ...[
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.arrow_right, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseCompletedDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Chúc mừng!"),
        content: const Text("Bạn đã hoàn thành khoá học này 🎉"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Đóng"),
            onPressed: () {
              Navigator.of(context).pop(); // đóng dialog
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context,
    Map<String, dynamic> block,
    Map<String, dynamic>? dict,
  ) {
    final type = block['type'] as String?;
    final value = block['value'] ?? '';

    switch (type) {
      case 'heading':
        return _buildHeading(value.toString());
      case 'text':
        return _buildText(value.toString());
      case 'analogy':
        return _buildAnalogy(
          block['concept']?.toString() ?? 'Khái niệm',
          value.toString(),
        );
      case 'comparison':
        return _buildComparison(
          block['wrong']?.toString() ?? '',
          block['right']?.toString() ?? '',
          block['reason']?.toString() ?? '',
        );
      case 'callout':
        return _buildCallout(
          value.toString(),
          block['style']?.toString() ?? 'info',
        );
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
      case 'key_concepts':
        return KeyConceptsBlock(concepts: block['concepts'] as List? ?? []);
      case 'step_by_step':
        return StepByStepBlock(
          steps: block['steps'] as List? ?? [],
          title: block['title']?.toString(),
        );
      case 'practice':
        return PracticeBlock(data: block);
      case 'summary':
        return SummaryBlock(
          content: value.toString(),
          keyPoints: block['key_points'] as List?,
        );
      case 'checkpoint':
        return CheckpointBlock(
          question: block['question']?.toString() ?? '',
          options: block['options'] as List? ?? [],
          correctAnswer: block['correct_answer'] as int? ?? 0,
          explanation: block['explanation']?.toString(),
        );
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
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemRed.withValues(alpha: 0.05),
            CupertinoColors.activeGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.arrow_left_right,
                  color: CupertinoColors.systemOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "So sánh đúng/sai",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _codeLabel("SAI ❌", wrong, CupertinoColors.systemRed),
          const SizedBox(height: 12),
          _codeLabel("ĐÚNG ✅", right, CupertinoColors.systemGreen),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.lightbulb_fill,
                    color: CupertinoColors.systemYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.label,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _codeLabel(String label, String code, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff282c34),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'MyCodeFont',
                fontSize: 14,
                color: CupertinoColors.white,
                height: 1.5,
              ),
            ),
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
        border: Border.all(
          color: CupertinoColors.systemIndigo.withValues(alpha: 0.2),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < items.length - 1 ? 12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "${entry.key + 1}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: CupertinoColors.label,
                        ),
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
    return Container(
      margin: const EdgeInsets.only(top: 28, bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: CupertinoColors.activeBlue, width: 4),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 1.6,
          color: CupertinoColors.label,
          letterSpacing: 0.2,
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
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xff282c34),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.doc_text_fill,
                color: CupertinoColors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                lang.toUpperCase(),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xff282c34),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: HighlightView(
              code,
              language: lang,
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(
                fontFamily: 'MyCodeFont',
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
        if (keywords != null && dict != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.systemBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      CupertinoIcons.book_fill,
                      color: CupertinoColors.systemBlue,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Từ khóa quan trọng:",
                      style: TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CupertinoColors.activeBlue.withValues(
                              alpha: 0.4,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              key.toString(),
                              style: const TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              CupertinoIcons.info,
                              color: CupertinoColors.activeBlue,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
