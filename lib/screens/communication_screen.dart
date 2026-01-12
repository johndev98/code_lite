import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab: 0 - Bảng tin, 1 - Hỏi đáp, 2 - Thông báo
final communicationTabIndexProvider = StateProvider<int>((ref) => 0);

class CommunicationScreen extends ConsumerWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(communicationTabIndexProvider);

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          largeTitle: Text('Cộng đồng'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderIntro(),
                const SizedBox(height: 16),
                _buildSegmentTabs(ref, selectedTab),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: _buildTabContent(selectedTab),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            CupertinoIcons.chat_bubble_2_fill,
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
                'Trao đổi & hỏi đáp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Nơi bạn có thể đặt câu hỏi, chia sẻ kinh nghiệm và cập nhật thông báo mới nhất.',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTabs(WidgetRef ref, int selectedTab) {
    return CupertinoSegmentedControl<int>(
      groupValue: selectedTab,
      padding: EdgeInsets.zero,
      children: const {
        0: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'Bảng tin',
            style: TextStyle(fontSize: 13),
          ),
        ),
        1: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'Hỏi đáp',
            style: TextStyle(fontSize: 13),
          ),
        ),
        2: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'Thông báo',
            style: TextStyle(fontSize: 13),
          ),
        ),
      },
      onValueChanged: (value) {
        ref.read(communicationTabIndexProvider.notifier).state = value;
      },
    );
  }

  Widget _buildTabContent(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return _buildFeedTab();
      case 1:
        return _buildQnATab();
      case 2:
        return _buildNotificationTab();
      default:
        return _buildFeedTab();
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color iconColor = CupertinoColors.activeBlue,
    String? trailingLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (trailingLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingLabel,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Hoạt động gần đây'),
        _buildCard(
          title: 'Bài viết mới: Làm quen với Dart',
          subtitle: 'Giải thích dễ hiểu về biến, kiểu dữ liệu và hàm trong Dart.',
          icon: CupertinoIcons.doc_text_fill,
          iconColor: CupertinoColors.activeBlue,
          trailingLabel: '3 phút trước',
        ),
        _buildCard(
          title: 'Tổng hợp 10 lỗi hay gặp khi học Flutter',
          subtitle: 'Xem nhanh những lỗi phổ biến và cách khắc phục.',
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          iconColor: CupertinoColors.systemOrange,
          trailingLabel: '1 giờ trước',
        ),
        _buildSectionLabel('Đề xuất cho bạn'),
        _buildCard(
          title: 'Tham gia nhóm học Flutter cơ bản',
          subtitle: 'Cùng những người mới như bạn trao đổi mỗi ngày.',
          icon: CupertinoIcons.person_2_fill,
          iconColor: CupertinoColors.systemGreen,
        ),
      ],
    );
  }

  Widget _buildQnATab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Câu hỏi nổi bật'),
        _buildCard(
          title: '[Dart] Khác nhau giữa var, final và const?',
          subtitle: '3 câu trả lời • 2 người đã vote là hữu ích',
          icon: CupertinoIcons.question_circle_fill,
          iconColor: CupertinoColors.activeBlue,
        ),
        _buildCard(
          title: '[Flutter] Khi nào nên dùng Stateless vs StatefulWidget?',
          subtitle: '2 câu trả lời • 1 câu trả lời được đánh dấu đúng',
          icon: CupertinoIcons.layers_alt,
          iconColor: CupertinoColors.systemIndigo,
        ),
        _buildSectionLabel('Hoạt động của bạn'),
        _buildCard(
          title: 'Bạn chưa đặt câu hỏi nào',
          subtitle: 'Hãy mạnh dạn hỏi điều bạn chưa rõ, cộng đồng sẽ hỗ trợ bạn.',
          icon: CupertinoIcons.bubble_middle_bottom,
          iconColor: CupertinoColors.systemGrey,
        ),
      ],
    );
  }

  Widget _buildNotificationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Mới'),
        _buildCard(
          title: 'Bạn đã mở khoá huy hiệu “Bền bỉ”',
          subtitle: 'Hoàn thành học trong 3 ngày liên tiếp. Tiếp tục duy trì nhé!',
          icon: CupertinoIcons.rosette,
          iconColor: CupertinoColors.systemYellow,
          trailingLabel: 'Hôm nay',
        ),
        _buildSectionLabel('Trước đó'),
        _buildCard(
          title: 'Khoá học mới: Flutter cơ bản',
          subtitle: 'Khám phá cách xây dựng giao diện đẹp với widget Cupertino.',
          icon: CupertinoIcons.sparkles,
          iconColor: CupertinoColors.systemPurple,
          trailingLabel: '2 ngày trước',
        ),
      ],
    );
  }
}
