import 'dart:io';
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

  bool get isConfigured => _aiService.apiKey.isNotEmpty;

  Future<String?> transcribeVoice(String filePath) async {
    if (!isConfigured) return null;
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final filename = filePath.split('/').last;
      return await _aiService.transcribeVoice(bytes, filename);
    } catch (_) {
      return null;
    }
  }

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
        weekEnd: DateTime.now(),
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
    final Map<int, List<double>> dayScores = {};
    for (final entry in entries) {
      final dayIdx = entry.createdAt.weekday - 1; // 0=Mon
      dayScores.putIfAbsent(dayIdx, () => []).add(entry.mood.score.toDouble());
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final result = <MoodPoint>[];
    for (int i = 0; i < 7; i++) {
      final scores = dayScores[i] ?? [];
      final avg = scores.isEmpty ? 3.0 : scores.reduce((a, b) => a + b) / scores.length;
      result.add(MoodPoint(
        date: weekStartDate.add(Duration(days: i)),
        score: avg,
      ));
    }
    return result;
  }
}
