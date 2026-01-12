import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_providers.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          largeTitle: Text('Học lập trình'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildContinueLearningCard(context),
                const SizedBox(height: 24),
                const Text(
                  'TỔNG QUAN HOẠT ĐỘNG',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStreakAndProgress(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khoá học nổi bật',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Danh sách khoá học (lấy từ coursesProvider)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: coursesAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Chưa có khoá học nào')),
                );
              }

              final featured = items.take(5).toList();

              return SliverList.builder(
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  final item = featured[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == featured.length - 1 ? 0 : 12),
                    child: CourseCard(
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
                    ),
                  );
                },
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Không thể tải khoá học, thử lại sau'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8AF5),
            Color(0xFF5B8CFF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Xin chào, coder 👋',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tiếp tục hành trình trở thành lập trình viên chuyên nghiệp mỗi ngày.',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAndProgress() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.flame_fill,
                  color: CupertinoColors.systemOrange,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chuỗi ngày học',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3 ngày liên tiếp',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: CupertinoColors.activeGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tiến độ tuần này',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 6,
                    backgroundColor:
                        CupertinoColors.systemGreen.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CupertinoColors.activeGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '60% mục tiêu đã hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bắt đầu nhanh',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickActionChip(
              icon: CupertinoIcons.play_circle_fill,
              label: 'Tiếp tục bài gần nhất',
              color: CupertinoColors.activeBlue,
            ),
            _buildQuickActionChip(
              icon: CupertinoIcons.doc_text_fill,
              label: 'Luyện bài tập',
              color: CupertinoColors.systemPurple,
            ),
            _buildQuickActionChip(
              icon: CupertinoIcons.clock_solid,
              label: 'Học nhanh 15 phút',
              color: CupertinoColors.systemOrange,
            ),
            _buildQuickActionChip(
              icon: CupertinoIcons.lightbulb_fill,
              label: 'Mẹo hay hôm nay',
              color: CupertinoColors.systemYellow,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.chevron_right_2,
              color: CupertinoColors.activeBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiếp tục học Dart cơ bản',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bạn còn 3 bài nữa để hoàn thành chương này.',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(999),
            color: CupertinoColors.activeBlue,
            onPressed: () {
              // Sau này có thể điều hướng tới bài học gần nhất
            },
            child: const Icon(
              CupertinoIcons.arrow_right,
              color: CupertinoColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
