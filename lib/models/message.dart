import 'dart:convert';
import 'thread_entry.dart';

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

  /// Ordered thread entries for UI rendering.
  /// Persisted inside [metadata] as JSON.
  List<ThreadEntry> entries = [];

  Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    this.reasoning,
    required this.createdAt,
    this.metadata,
    this.toolCalls,
    List<ThreadEntry>? entries,
  }) : entries = entries ?? [];

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toMap() {
    final meta = <String, dynamic>{
      ...?metadata,
    };
    if (toolCalls != null && toolCalls!.isNotEmpty) {
      meta['tool_calls'] = toolCalls!.map((tc) => tc.toJson()).toList();
    }
    if (entries.isNotEmpty) {
      meta['entries'] = ThreadEntry.listToJson(entries);
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
    List<ThreadEntry> entries = [];
    final meta = map['metadata'] != null
        ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
        : null;
    if (meta != null && meta['tool_calls'] is List) {
      toolCalls = (meta['tool_calls'] as List)
          .map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (meta != null && meta['entries'] is List) {
      entries = ThreadEntry.listFromJson(meta['entries'] as List);
    } else {
      entries = buildLegacyEntries(
        reasoning: map['reasoning'] as String?,
        content: map['content'] as String,
        toolCalls: toolCalls,
      );
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
      entries: entries,
    );
  }

  static List<ThreadEntry> buildLegacyEntries({
    String? reasoning,
    required String content,
    List<ToolCall>? toolCalls,
  }) {
    final entries = <ThreadEntry>[];
    if (reasoning != null && reasoning.isNotEmpty) {
      entries.add(ThinkingEntry(reasoning));
    }
    if (content.isNotEmpty) {
      entries.add(TextEntry(content));
    }
    if (toolCalls != null) {
      for (final tc in toolCalls) {
        entries.add(ToolCallEntry(
          toolCallId: tc.id,
          toolName: tc.name,
          toolArguments: tc.arguments,
          completed: tc.completed,
          error: tc.error,
          result: tc.result,
        ));
      }
    }
    return entries;
  }
}
