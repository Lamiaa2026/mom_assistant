enum AIMessageType {
  parentingAdvice,
  bedtimeStory,
  fridgeRecipe,
  generalChat,
}

class AIMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AIMessageType type;
  final String? title;
  final Map<String, dynamic>? metadata;

  AIMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = AIMessageType.generalChat,
    this.title,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'title': title,
      'metadata': metadata,
    };
  }

  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: AIMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AIMessageType.generalChat,
      ),
      title: json['title'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
