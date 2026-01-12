import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          largeTitle: Text('Hồ sơ'),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 8),
              _buildLearningSettingsSection(),
              const SizedBox(height: 8),
              _buildAppSettingsSection(),
              const SizedBox(height: 8),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                size: 40,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Người dùng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 14,
                        color: CupertinoColors.systemYellow,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Thành viên từ tháng 1/2024',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // Chỉnh sửa profile
              },
              child: const Icon(
                CupertinoIcons.pencil,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THỐNG KÊ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.book_fill,
                  label: 'Bài học',
                  value: '24',
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.check_mark_circled_solid,
                  label: 'Đã hoàn thành',
                  value: '18',
                  color: CupertinoColors.activeGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: CupertinoIcons.flame_fill,
                  label: 'Chuỗi ngày',
                  value: '7',
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return CupertinoListSection(
      header: const Text('THÔNG TIN CÁ NHÂN'),
      children: [
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.person, color: CupertinoColors.activeBlue),
          title: const Text('Họ và tên'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Chỉnh sửa tên
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.mail, color: CupertinoColors.activeBlue),
          title: const Text('Email'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Chỉnh sửa email
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.phone, color: CupertinoColors.activeBlue),
          title: const Text('Số điện thoại'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Chỉnh sửa số điện thoại
          },
        ),
      ],
    );
  }

  Widget _buildLearningSettingsSection() {
    return CupertinoListSection(
      header: const Text('CÀI ĐẶT HỌC TẬP'),
      children: [
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.bell, color: CupertinoColors.systemOrange),
          title: const Text('Thông báo học tập'),
          trailing: CupertinoSwitch(
            value: true,
            onChanged: (value) {
              // Bật/tắt thông báo
            },
          ),
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.clock, color: CupertinoColors.systemPurple),
          title: const Text('Nhắc nhở học hàng ngày'),
          trailing: const Text(
            '20:00',
            style: TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          onTap: () {
            // Chỉnh sửa thời gian nhắc nhở
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.chart_bar, color: CupertinoColors.activeGreen),
          title: const Text('Mục tiêu hàng ngày'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Chỉnh sửa mục tiêu
          },
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return CupertinoListSection(
      header: const Text('CÀI ĐẶT ỨNG DỤNG'),
      children: [
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.moon, color: CupertinoColors.systemIndigo),
          title: const Text('Chế độ tối'),
          trailing: CupertinoSwitch(
            value: false,
            onChanged: (value) {
              // Bật/tắt chế độ tối
            },
          ),
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.globe, color: CupertinoColors.activeBlue),
          title: const Text('Ngôn ngữ'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tiếng Việt',
                style: TextStyle(color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(width: 4),
              const CupertinoListTileChevron(),
            ],
          ),
          onTap: () {
            // Chọn ngôn ngữ
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.cloud_download, color: CupertinoColors.systemTeal),
          title: const Text('Tải xuống để học offline'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Quản lý tải xuống
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.trash, color: CupertinoColors.systemRed),
          title: const Text('Xóa cache'),
          trailing: const Text(
            '125 MB',
            style: TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          onTap: () {
            // Xóa cache
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return CupertinoListSection(
      header: const Text('VỀ ỨNG DỤNG'),
      children: [
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.info_circle, color: CupertinoColors.activeBlue),
          title: const Text('Phiên bản'),
          trailing: const Text(
            '1.0.0',
            style: TextStyle(color: CupertinoColors.secondaryLabel),
          ),
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.doc_text, color: CupertinoColors.systemGrey),
          title: const Text('Điều khoản sử dụng'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Xem điều khoản
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
          title: const Text('Chính sách bảo mật'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Xem chính sách
          },
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.heart, color: CupertinoColors.systemRed),
          title: const Text('Đánh giá ứng dụng'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // Mở App Store/Play Store
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton.filled(
        onPressed: () {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('Đăng xuất'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Xử lý đăng xuất
                  },
                ),
              ],
            ),
          );
        },
        child: const Text('Đăng xuất'),
      ),
    );
  }
}
