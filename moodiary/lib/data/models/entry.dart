import 'package:equatable/equatable.dart';

enum EntryMediaType { image, voice, link }

class EntryMedia extends Equatable {
  final EntryMediaType type;
  final String url;
  final Map<String, dynamic>? metadata;

  const EntryMedia({
    required this.type,
    required this.url,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'url': url,
        'metadata': metadata,
      };

  factory EntryMedia.fromJson(Map<String, dynamic> json) => EntryMedia(
        type: EntryMediaType.values.byName(json['type']),
        url: json['url'],
        metadata: json['metadata'],
      );

  @override
  List<Object?> get props => [type, url];
}

class Mood extends Equatable {
  final String emoji;
  final int score; // 1-5
  final String label;

  const Mood({
    required this.emoji,
    required this.score,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'score': score,
        'label': label,
      };

  factory Mood.fromJson(Map<String, dynamic> json) => Mood(
        emoji: json['emoji'],
        score: json['score'],
        label: json['label'],
      );

  @override
  List<Object> get props => [emoji, score, label];
}

class Entry extends Equatable {
  final String id;
  final String userId;
  final String? content;
  final Mood mood;
  final List<EntryMedia> media;
  final List<String> tags;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Entry({
    required this.id,
    required this.userId,
    this.content,
    required this.mood,
    this.media = const [],
    this.tags = const [],
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Entry copyWith({
    String? id,
    String? userId,
    String? content,
    Mood? mood,
    List<EntryMedia>? media,
    List<String>? tags,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      media: media ?? this.media,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'content': content,
        'mood': mood.toJson(),
        'media': media.map((m) => m.toJson()).toList(),
        'tags': tags,
        'is_private': isPrivate,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'],
        userId: json['user_id'],
        content: json['content'],
        mood: Mood.fromJson(json['mood']),
        media: (json['media'] as List?)
                ?.map((m) => EntryMedia.fromJson(m))
                .toList() ??
            [],
        tags: List<String>.from(json['tags'] ?? []),
        isPrivate: json['is_private'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  @override
  List<Object?> get props => [id, userId, content, mood, media, tags, updatedAt];
}
