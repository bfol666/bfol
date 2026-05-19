import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final String subscriptionTier;
  final int totalEntries;
  final int streakDays;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.avatarUrl,
    required this.createdAt,
    this.subscriptionTier = 'free',
    this.totalEntries = 0,
    this.streakDays = 0,
  });

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
    String? subscriptionTier,
    int? totalEntries,
    int? streakDays,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      totalEntries: totalEntries ?? this.totalEntries,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
        'subscription_tier': subscriptionTier,
        'total_entries': totalEntries,
        'streak_days': streakDays,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        nickname: json['nickname'],
        avatarUrl: json['avatar_url'],
        createdAt: DateTime.parse(json['created_at']),
        subscriptionTier: json['subscription_tier'] ?? 'free',
        totalEntries: json['total_entries'] ?? 0,
        streakDays: json['streak_days'] ?? 0,
      );

  @override
  List<Object?> get props => [id, email, nickname, subscriptionTier, totalEntries];
}
