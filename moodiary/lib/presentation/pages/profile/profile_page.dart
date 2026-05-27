import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../providers/providers.dart';
import '../../widgets/surface_container.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryState = ref.watch(entryProvider);
    final authState = ref.watch(authProvider);
    final entries = entryState.entries;
    final nickname = authState.user?.nickname ?? '小叶子';

    final totalEntries = entries.length;
    final recordedDays = entries
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .length;
    final streak = _calculateStreak(entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: entryState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile card
            SurfaceContainer(
              borderRadius: 22,
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryMuted,
                    ),
                    child: const Center(
                        child: Text('🌱', style: TextStyle(fontSize: 38))),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Pro 会员',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('记录天数', '$recordedDays'),
                      _divider(),
                      _statItem('总条目', '$totalEntries'),
                      _divider(),
                      _statItem('连续记录', '$streak天'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Achievements
            _sectionTitle('成就徽章'),
            const SizedBox(height: 12),
            SurfaceContainer(
              borderRadius: 18,
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  _badge('🌱', '初来乍到', true),
                  _badge('🔥', '连续7天', streak >= 7),
                  _badge('⭐', '记录10条', totalEntries >= 10),
                  _badge('💪', '情绪稳定', totalEntries >= 5),
                  _badge('🎨', '图文并茂', totalEntries >= 3),
                  _badge('🎯', '满月', recordedDays >= 30),
                  _badge('📸', '摄影达人', totalEntries >= 20),
                  _badge('🌈', '情绪彩虹', totalEntries >= 50),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu
            _sectionTitle('设置'),
            const SizedBox(height: 12),
            SurfaceContainer(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                children: [
                  _menuItem(Icons.archive_outlined, '我的日记', () {
                    Navigator.pushNamed(context, '/home');
                  }),
                  _menuItem(Icons.bookmark_outlined, '收藏', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.palette_outlined, '主题皮肤', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.lock_outlined, '隐私与安全', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.cloud_outlined, '数据同步', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.analytics_outlined, '数据导出', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.help_outlined, '帮助与反馈', () {
                    _comingSoon(context);
                  }),
                  _menuItem(Icons.info_outlined, '关于 Moodiary', () {
                    _showAbout(context);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                      color: AppColors.textHint.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child:
                    const Text('退出登录', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(List<Entry> entries) {
    if (entries.isEmpty) return 0;
    final days = entries
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    var streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var check = todayDate;
    for (final day in days) {
      if (day == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (day.isBefore(check)) {
        break;
      }
    }
    return streak;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.surfaceMuted,
    );
  }

  Widget _badge(String emoji, String name, bool unlocked) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.35,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              color:
                  unlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('即将上线，敬请期待'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Moodiary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('v1.0.0',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('用 AI 读懂你的每一天',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title,
          style:
              const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right,
          size: 17, color: AppColors.textHint),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
