class Chat {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  String? model;
  String? systemPrompt;

  Chat({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.model,
    this.systemPrompt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'model': model,
      'system_prompt': systemPrompt,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      model: map['model'] as String?,
      systemPrompt: map['system_prompt'] as String?,
    );
  }

  Chat copyWith({
    String? title,
    DateTime? updatedAt,
    String? model,
    String? systemPrompt,
  }) {
    return Chat(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}
