import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/weekly_report.dart';
import '../../providers/providers.dart';
import '../../widgets/surface_container.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  bool _isAiGenerating = false;
  WeeklyReport? _aiReport;

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(entryProvider);
    final entries = entryState.entries;

    if (entryState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('周报')),
        body: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    final thisWeekEntries = _filterThisWeek(entries);
    final localReport = _computeReport(thisWeekEntries);

    if (localReport == null && _aiReport == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('周报')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📋', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('本周还没有记录',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              SizedBox(height: 8),
              Text('记录心情后，每周日自动生成周报',
                  style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            ],
          ),
        ),
      );
    }

    final displayReport = _mergeReport(localReport, _aiReport);

    return Scaffold(
      appBar: AppBar(
        title: const Text('周报'),
        actions: [
          if (thisWeekEntries.isNotEmpty && !_isAiGenerating)
            _buildAiButton(thisWeekEntries),
          if (_isAiGenerating)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildReport(displayReport),
      ),
    );
  }

  Widget _buildAiButton(List<Entry> thisWeekEntries) {
    final ai = ref.read(aiProvider.notifier);
    if (!ai.isConfigured) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _generateAIReport(thisWeekEntries),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 4),
            Text('AI 生成',
                style: TextStyle(fontSize: 13, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAIReport(List<Entry> thisWeekEntries) async {
    setState(() => _isAiGenerating = true);

    final report = await ref.read(aiProvider.notifier).generateWeeklyReport(
      'local-user',
      _weekStart(),
      thisWeekEntries,
    );

    if (!mounted) return;

    setState(() => _isAiGenerating = false);

    if (report != null) {
      _aiReport = report;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI 生成失败，请检查网络后重试'),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<Entry> _filterThisWeek(List<Entry> entries) {
    final weekStart = _weekStart();
    return entries.where((e) {
      return !e.createdAt.isBefore(weekStart);
    }).toList();
  }

  DateTime _weekStart() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(start.year, start.month, start.day);
  }

  WeeklyReport _mergeReport(WeeklyReport? local, WeeklyReport? ai) {
    if (ai != null) return ai;
    return local!;
  }

  WeeklyReport? _computeReport(List<Entry> entries) {
    if (entries.isEmpty) return null;

    final weekStartDate = _weekStart();
    final now = DateTime.now();

    final moodByDay = <int, List<int>>{};
    for (final entry in entries) {
      final dayIdx = entry.createdAt.weekday - 1;
      moodByDay.putIfAbsent(dayIdx, () => []).add(entry.mood.score);
    }

    final moodCurve = <MoodPoint>[];
    for (int i = 0; i < 7; i++) {
      final scores = moodByDay[i] ?? [];
      final avg = scores.isEmpty ? 3.0 : scores.fold(0.0, (a, b) => a + b) / scores.length;
      moodCurve.add(MoodPoint(
        date: weekStartDate.add(Duration(days: i)),
        score: avg,
      ));
    }

    final tagCount = <String, int>{};
    for (final entry in entries) {
      for (final tag in entry.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    final maxCount = tagCount.values.fold<int>(0, (a, b) => a > b ? a : b);
    final keywords = tagCount.entries
        .map((e) => Keyword(
              word: e.key,
              weight: maxCount > 0 ? e.value / maxCount : 0.5,
            ))
        .toList();

    if (keywords.isEmpty) {
      final moodLabels = <String, int>{};
      for (final entry in entries) {
        moodLabels[entry.mood.label] = (moodLabels[entry.mood.label] ?? 0) + 1;
      }
      for (final entry in moodLabels.entries) {
        keywords.add(Keyword(
          word: entry.key,
          weight: entry.value / entries.length,
        ));
      }
    }

    final dominantMood = _dominantMood(entries);
    final aiSummary = _generateSummary(dominantMood, entries.length, keywords);

    return WeeklyReport(
      id: 'local-report-${now.millisecondsSinceEpoch}',
      userId: 'local-user',
      weekStart: weekStartDate,
      weekEnd: now,
      keywords: keywords,
      moodCurve: moodCurve,
      aiSummary: aiSummary,
      entryCount: entries.length,
      generatedAt: now,
    );
  }

  String _dominantMood(List<Entry> entries) {
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.mood.label] = (counts[e.mood.label] ?? 0) + 1;
    }
    return counts.entries
        .fold<MapEntry<String, int>>(
            const MapEntry('', 0), (a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _generateSummary(
      String mood, int count, List<Keyword> keywords) {
    final phrases = {
      '开心': '你的这一周充满了快乐的时刻！',
      '平静': '这一周你找到了内心的平静。',
      '难过': '这一周也许有些艰难，但你做到了。',
      '焦虑': '这一周你面对了不少压力。',
      '生气': '这一周你有过愤怒的时刻，那是你在乎的证明。',
      '感激': '这一周你的心中装满了感恩。',
      '期待': '这一周你拥抱了对未来的期待。',
    };
    final base = phrases[mood] ?? '这一周你经历了很多。';
    final keywordStr =
        keywords.take(3).map((k) => k.word).join('、');
    final extra = keywordStr.isNotEmpty ? '你的关键词是：$keywordStr。' : '';
    return '$base$extra本周记录了 $count 条心情，继续保持这个好习惯吧。每一天都值得被铭记 🌸';
  }

  Widget _buildReport(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleCard(report),
        const SizedBox(height: 20),
        _buildKeywordCloud(report),
        const SizedBox(height: 24),
        _buildMoodCurve(report),
        const SizedBox(height: 24),
        _buildAISummary(report),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTitleCard(WeeklyReport report) {
    return SurfaceContainer(
      borderRadius: 20,
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            '你的第 ${_weekNumber(report.weekStart)} 周',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('M月d日').format(report.weekStart)} — ${DateFormat('M月d日').format(report.weekEnd)}',
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '本周记录了 ${report.entryCount} 条心情',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordCloud(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('本周关键词',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ),
            if (_aiReport != null)
              const Icon(Icons.auto_awesome,
                  size: 14, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(18),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: report.keywords.map((kw) {
              final size = 13.0 + (kw.weight * 11);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
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
      ],
    );
  }

  Widget _buildMoodCurve(WeeklyReport report) {
    final points = report.moodCurve;
    if (points.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('情绪变化',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SurfaceContainer(
          borderRadius: 16,
          padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 1.0,
                maxY: 5.0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.textHint.withValues(alpha: 0.25),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        const emojis = {
                          1: '😢',
                          2: '😔',
                          3: '😐',
                          4: '😊',
                          5: '🥰'
                        };
                        return Text(emojis[value.toInt()] ?? '',
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final day =
                            DateFormat('E', 'zh_CN').format(points[idx].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(day,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItems: (spots) => spots.map((spot) {
                      final idx = spot.x.toInt();
                      final label = idx < points.length
                          ? DateFormat('M/d').format(points[idx].date)
                          : '';
                      return LineTooltipItem(
                        '$label\n${spot.y.toStringAsFixed(1)}分',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        points.length,
                        (i) =>
                            FlSpot(i.toDouble(), points[i].score)),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.surface,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAISummary(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('AI 周结',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ),
            if (_aiReport != null)
              const Icon(Icons.auto_awesome,
                  size: 14, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceContainer(
          borderRadius: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💭', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  report.aiSummary,
                  style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: AppColors.textPrimary),
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
}
