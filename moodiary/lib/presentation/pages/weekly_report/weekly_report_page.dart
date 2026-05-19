import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/weekly_report.dart';
import '../../widgets/glass_container.dart';

class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Load report from provider
    final report = _mockReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text('周报'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () {
              // TODO: Share report as image
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildReport(report),
      ),
    );
  }

  Widget _buildReport(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title card
        GlassContainer(
          child: Column(
            children: [
              const Text('📋', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                '你的第 ${_weekNumber(report.weekStart)} 周',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('M月d日').format(report.weekStart)} - ${DateFormat('M月d日').format(report.weekEnd)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '本周记录了 ${report.entryCount} 条心情',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Keywords cloud
        const Text(
          '本周关键词',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: report.keywords.map((kw) {
              final size = 13.0 + (kw.weight * 12);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kw.word,
                  style: TextStyle(
                    fontSize: size,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Mood curve
        const Text(
          '情绪变化',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '📈 情绪曲线图',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            // TODO: Implement with fl_chart
          ),
        ),

        const SizedBox(height: 24),

        // AI summary
        const Text(
          'AI 周结',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💭', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  report.aiSummary,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _weekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return ((date.difference(startOfYear).inDays) / 7).ceil();
  }

  WeeklyReport _mockReport() {
    return WeeklyReport(
      id: 'mock',
      userId: 'user1',
      weekStart: DateTime.now().subtract(Duration(days: DateTime.now().weekday)),
      weekEnd: DateTime.now(),
      keywords: [
        const Keyword(word: '工作', weight: 0.9),
        const Keyword(word: '咖啡', weight: 0.7),
        const Keyword(word: '朋友', weight: 0.65),
        const Keyword(word: '疲惫', weight: 0.6),
        const Keyword(word: '落日', weight: 0.55),
        const Keyword(word: '音乐', weight: 0.5),
        const Keyword(word: '散步', weight: 0.45),
        const Keyword(word: '期待', weight: 0.4),
      ],
      moodCurve: [
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 6)), score: 3.5),
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 5)), score: 4.0),
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 4)), score: 2.5),
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 3)), score: 3.0),
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 2)), score: 4.5),
        MoodPoint(date: DateTime.now().subtract(const Duration(days: 1)), score: 4.0),
        MoodPoint(date: DateTime.now(), score: 4.5),
      ],
      aiSummary: '本周你的情绪总体平稳，周四有一些低落但很快恢复了。工作是你本周的高频词，记得给自己一些休息的时间。周末的落日和散步让心情明显变好——生活中的小确幸最珍贵。下周也要好好照顾自己呀 🌸',
      entryCount: 5,
      generatedAt: DateTime.now(),
    );
  }
}
