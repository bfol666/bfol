import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../models/weekly_report.dart';

class AIService {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  AIService({required this.apiKey, this.baseUrl = 'https://api.openai.com/v1'})
      : _client = http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  /// Analyze sentiment from entry text
  Future<AIAnalysis> analyzeSentiment(String text) async {
    final prompt = _buildSentimentPrompt(text);
    final response = await _callGPT(prompt);
    return _parseSentimentResponse(response);
  }

  /// Generate a warm AI reply based on the entry
  Future<String> generateReply(String entryContent, String moodLabel) async {
    final prompt = _buildReplyPrompt(entryContent, moodLabel);
    return _callGPT(prompt);
  }

  /// Extract keywords from a list of entries
  Future<List<Keyword>> extractKeywords(List<Entry> entries) async {
    final content = entries
        .where((e) => e.content != null && e.content!.isNotEmpty)
        .map((e) => e.content!)
        .join('\n---\n');

    final prompt = _buildKeywordsPrompt(content);
    final response = await _callGPT(prompt);
    return _parseKeywordsResponse(response);
  }

  /// Generate weekly summary
  Future<String> generateWeeklySummary(
      List<Entry> entries, List<Keyword> keywords) async {
    final prompt = _buildWeeklySummaryPrompt(entries, keywords);
    return _callGPT(prompt);
  }

  /// Transcribe voice to text via Whisper
  Future<String> transcribeVoice(List<int> audioBytes, String filename) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['language'] = 'zh';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      audioBytes,
      filename: filename,
    ));

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['text'] ?? '';
  }

  Future<String> _callGPT(String prompt) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                '你是一个温暖、共情的AI手记助手。你的回复简短、温柔、有共鸣感，像朋友一样。字数控制在150字以内。'
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.8,
        'max_tokens': 300,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List;
    return choices.first['message']['content'] ?? '';
  }

  String _buildSentimentPrompt(String text) {
    return '''
分析以下日记内容的情感。返回JSON格式：
{
  "mood_label": "开心|平静|难过|焦虑|生气|感激|期待",
  "mood_emoji": "最合适的emoji",
  "score": 1-5的分数(5最积极),
  "tags": ["关键词1", "关键词2", "关键词3"]
}

日记内容：
$text
''';
  }

  String _buildReplyPrompt(String content, String moodLabel) {
    return '用户写了一篇心情日记，情绪是"$moodLabel"。内容：$content\n\n请用温暖、简短的话回复（100字内），像朋友一样共鸣和鼓励。';
  }

  String _buildKeywordsPrompt(String content) {
    return '从以下日记中提取5-10个关键词，返回JSON数组：[{"word": "关键词", "weight": 0.5-1.0}]。\n\n$content';
  }

  String _buildWeeklySummaryPrompt(List<Entry> entries, List<Keyword> keywords) {
    final entriesText = entries
        .where((e) => e.content != null)
        .map((e) => '[${e.mood.emoji}] ${e.content}')
        .join('\n');
    return '这是一位用户过去一周的日记。请用200字以内写一个温暖的周结，总结ta的情绪变化和值得关注的事。\n\n$entriesText';
  }

  AIAnalysis _parseSentimentResponse(String response) {
    try {
      final json = jsonDecode(response) as Map<String, dynamic>;
      return AIAnalysis(
        moodLabel: json['mood_label'] ?? '平静',
        moodEmoji: json['mood_emoji'] ?? '😊',
        score: (json['score'] as num?)?.toDouble() ?? 3.0,
        tags: List<String>.from(json['tags'] ?? []),
      );
    } catch (_) {
      return AIAnalysis(
        moodLabel: '平静',
        moodEmoji: '😊',
        score: 3.0,
        tags: [],
      );
    }
  }

  List<Keyword> _parseKeywordsResponse(String response) {
    try {
      final list = jsonDecode(response) as List;
      return list
          .map((item) => Keyword(
                word: item['word'],
                weight: (item['weight'] as num).toDouble(),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

class AIAnalysis {
  final String moodLabel;
  final String moodEmoji;
  final double score;
  final List<String> tags;

  const AIAnalysis({
    required this.moodLabel,
    required this.moodEmoji,
    required this.score,
    required this.tags,
  });
}
