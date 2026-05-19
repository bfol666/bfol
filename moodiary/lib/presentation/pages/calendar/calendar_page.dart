import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_container.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
      ),
      body: Column(
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2026年 5月',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    _iconButton(Icons.chevron_left),
                    const SizedBox(width: 16),
                    _iconButton(Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['一', '二', '三', '四', '五', '六', '日']
                  .map((d) => SizedBox(
                        width: 32,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Calendar grid (TODO: implement actual calendar)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
              ),
              itemCount: 35, // 5 weeks
              itemBuilder: (context, index) {
                final day = index - 3; // offset for May 2026
                if (day < 1 || day > 31) {
                  return const SizedBox.shrink();
                }

                final hasEntry = day % 3 == 0; // Mock: some days have entries
                final isToday = day == 14;

                return GestureDetector(
                  onTap: () {
                    // TODO: Show entries for this day
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (hasEntry)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.coral,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Entries for selected date (mock)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '5月14日 周四',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dayEntry('😊 今天天气很好，去公园散了步', '开心'),
                  const Divider(height: 16, color: AppColors.textHint),
                  _dayEntry('☕ 下午和朋友喝了咖啡，聊了很多', '愉快'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayEntry(String content, String mood) {
    return Row(
      children: [
        Text(
          '·',
          style: TextStyle(
            fontSize: 28,
            color: AppColors.primary.withValues(alpha: 0.5),
            height: 0.8,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: AppColors.textSecondary),
    );
  }
}
