import 'package:equatable/equatable.dart';

class Keyword extends Equatable {
  final String word;
  final double weight;

  const Keyword({required this.word, required this.weight});

  Map<String, dynamic> toJson() => {
        'word': word,
        'weight': weight,
      };

  factory Keyword.fromJson(Map<String, dynamic> json) => Keyword(
        word: json['word'],
        weight: (json['weight'] as num).toDouble(),
      );

  @override
  List<Object> get props => [word, weight];
}

class MoodPoint extends Equatable {
  final DateTime date;
  final double score; // 1.0 - 5.0

  const MoodPoint({required this.date, required this.score});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'score': score,
      };

  factory MoodPoint.fromJson(Map<String, dynamic> json) => MoodPoint(
        date: DateTime.parse(json['date']),
        score: (json['score'] as num).toDouble(),
      );

  @override
  List<Object> get props => [date, score];
}

class WeeklyReport extends Equatable {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<Keyword> keywords;
  final List<MoodPoint> moodCurve;
  final String aiSummary;
  final int entryCount;
  final DateTime generatedAt;

  const WeeklyReport({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.keywords,
    required this.moodCurve,
    required this.aiSummary,
    required this.entryCount,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'week_start': weekStart.toIso8601String().split('T').first,
        'week_end': weekEnd.toIso8601String().split('T').first,
        'keywords': keywords.map((k) => k.toJson()).toList(),
        'mood_curve': moodCurve.map((m) => m.toJson()).toList(),
        'ai_summary': aiSummary,
        'entry_count': entryCount,
        'generated_at': generatedAt.toIso8601String(),
      };

  factory WeeklyReport.fromJson(Map<String, dynamic> json) => WeeklyReport(
        id: json['id'],
        userId: json['user_id'],
        weekStart: DateTime.parse(json['week_start']),
        weekEnd: DateTime.parse(json['week_end']),
        keywords: (json['keywords'] as List?)
                ?.map((k) => Keyword.fromJson(k))
                .toList() ??
            [],
        moodCurve: (json['mood_curve'] as List?)
                ?.map((m) => MoodPoint.fromJson(m))
                .toList() ??
            [],
        aiSummary: json['ai_summary'] ?? '',
        entryCount: json['entry_count'] ?? 0,
        generatedAt: DateTime.parse(json['generated_at']),
      );

  @override
  List<Object?> get props =>
      [id, userId, weekStart, weekEnd, keywords, moodCurve, entryCount];
}
