import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/entry.dart';
import '../../data/models/weekly_report.dart';
import '../../data/services/ai_service.dart';

class AIState {
  final bool isAnalyzing;
  final String? lastReply;
  final WeeklyReport? currentReport;
  final String? error;

  const AIState({
    this.isAnalyzing = false,
    this.lastReply,
    this.currentReport,
    this.error,
  });

  AIState copyWith({
    bool? isAnalyzing,
    String? lastReply,
    WeeklyReport? currentReport,
    String? error,
  }) {
    return AIState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      lastReply: lastReply ?? this.lastReply,
      currentReport: currentReport ?? this.currentReport,
      error: error,
    );
  }
}

class AINotifier extends StateNotifier<AIState> {
  final AIService _aiService;

  AINotifier(this._aiService) : super(const AIState());

  Future<String?> getAIReply(String content, String moodLabel) async {
    state = state.copyWith(isAnalyzing: true);
    try {
      final reply = await _aiService.generateReply(content, moodLabel);
      state = state.copyWith(isAnalyzing: false, lastReply: reply);
      return reply;
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
      return null;
    }
  }

  Future<AIAnalysis?> analyzeEntry(String content) async {
    try {
      return await _aiService.analyzeSentiment(content);
    } catch (_) {
      return null;
    }
  }

  Future<WeeklyReport?> generateWeeklyReport(
    String userId,
    DateTime weekStart,
    List<Entry> entries,
  ) async {
    state = state.copyWith(isAnalyzing: true);
    try {
      final keywords = await _aiService.extractKeywords(entries);
      final summary = await _aiService.generateWeeklySummary(entries, keywords);

      final report = WeeklyReport(
        id: '$userId-${weekStart.toIso8601String()}',
        userId: userId,
        weekStart: weekStart,
        weekEnd: weekStart.add(const Duration(days: 7)),
        keywords: keywords,
        moodCurve: buildMoodCurve(entries),
        aiSummary: summary,
        entryCount: entries.length,
        generatedAt: DateTime.now(),
      );

      state = state.copyWith(isAnalyzing: false, currentReport: report);
      return report;
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
      return null;
    }
  }

  List<MoodPoint> buildMoodCurve(List<Entry> entries) {
    final Map<String, List<double>> dayScores = {};
    for (final entry in entries) {
      final date = entry.createdAt
          .toIso8601String()
          .split('T')
          .first;
      final score = entry.mood.score.toDouble();
      dayScores.putIfAbsent(date, () => []).add(score);
    }

    return dayScores.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return MoodPoint(date: DateTime.parse(e.key), score: avg);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
