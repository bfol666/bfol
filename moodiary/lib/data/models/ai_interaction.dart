import 'package:equatable/equatable.dart';

enum AIInteractionType { sentimentAnalysis, reply, suggestion }

class AIInteraction extends Equatable {
  final String id;
  final String entryId;
  final String userId;
  final AIInteractionType type;
  final String response;
  final DateTime createdAt;

  const AIInteraction({
    required this.id,
    required this.entryId,
    required this.userId,
    required this.type,
    required this.response,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entry_id': entryId,
        'user_id': userId,
        'type': type.name,
        'response': response,
        'created_at': createdAt.toIso8601String(),
      };

  factory AIInteraction.fromJson(Map<String, dynamic> json) => AIInteraction(
        id: json['id'],
        entryId: json['entry_id'],
        userId: json['user_id'],
        type: AIInteractionType.values.byName(json['type']),
        response: json['response'],
        createdAt: DateTime.parse(json['created_at']),
      );

  @override
  List<Object> get props => [id, entryId, type, response, createdAt];
}
