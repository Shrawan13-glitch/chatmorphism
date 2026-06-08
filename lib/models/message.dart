import 'dart:convert';

class ToolCall {
  final String id;
  final String name;
  Map<String, dynamic> arguments;
  String? result;
  bool completed;
  bool error;

  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.result,
    this.completed = false,
    this.error = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arguments': arguments,
        'result': result,
        'completed': completed,
        'error': error,
      };

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        id: json['id'] as String,
        name: json['name'] as String,
        arguments: (json['arguments'] as Map<String, dynamic>?) ?? {},
        result: json['result'] as String?,
        completed: json['completed'] as bool? ?? false,
        error: json['error'] as bool? ?? false,
      );
}

class Message {
  final String id;
  final String chatId;
  final String role;
  String content;
  String? reasoning;
  final DateTime createdAt;
  Map<String, dynamic>? metadata;

  /// Tool calls attached to this assistant message.
  /// Persisted inside [metadata] as JSON.
  List<ToolCall>? toolCalls;

  Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    this.reasoning,
    required this.createdAt,
    this.metadata,
    this.toolCalls,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toMap() {
    final meta = <String, dynamic>{
      ...?metadata,
    };
    if (toolCalls != null && toolCalls!.isNotEmpty) {
      meta['tool_calls'] = toolCalls!.map((tc) => tc.toJson()).toList();
    }
    return {
      'id': id,
      'chat_id': chatId,
      'role': role,
      'content': content,
      'reasoning': reasoning,
      'created_at': createdAt.toIso8601String(),
      'metadata': meta.isNotEmpty ? jsonEncode(meta) : null,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    List<ToolCall>? toolCalls;
    final meta = map['metadata'] != null
        ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
        : null;
    if (meta != null && meta['tool_calls'] is List) {
      toolCalls = (meta['tool_calls'] as List)
          .map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Message(
      id: map['id'] as String,
      chatId: map['chat_id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      reasoning: map['reasoning'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      metadata: meta,
      toolCalls: toolCalls,
    );
  }
}
