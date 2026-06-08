import 'dart:async';
import 'dart:convert';

/// Unified streaming event model — mirrors Agora's `Flow<StreamEvent>`.
sealed class StreamEvent {}

class TextChunk extends StreamEvent {
  final String text;
  TextChunk(this.text);
}

class ThoughtChunk extends StreamEvent {
  final String thought;
  final String? title;
  ThoughtChunk(this.thought, {this.title});
}

class ToolCallRequest extends StreamEvent {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  ToolCallRequest(this.id, this.name, this.arguments);
}

class ToolCallsRequest extends StreamEvent {
  final List<ToolCallInfo> calls;
  ToolCallsRequest(this.calls);
}

class ToolCallInfo {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  ToolCallInfo(this.id, this.name, this.arguments);
}

class UsageUpdate extends StreamEvent {
  final int promptTokens;
  final int completionTokens;
  UsageUpdate(this.promptTokens, this.completionTokens);
}

class StreamError extends StreamEvent {
  final String message;
  final bool retryable;
  StreamError(this.message, {this.retryable = false});
}

class StreamDone extends StreamEvent {
  final String finishReason;
  StreamDone(this.finishReason);
}

/// Lightweight cancellation token.
class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
  void reset() => _cancelled = false;
}

/// Tool definition builder (OpenAI-compatible format).
class ToolDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'type': 'function',
        'function': {
          'name': name,
          'description': description,
          'parameters': parameters,
        },
      };
}

/// Abstract provider interface — all LLM backends implement this.
abstract class LlmProvider {
  Stream<StreamEvent> sendMessageStream({
    required String apiKey,
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
    Map<String, dynamic>? toolChoice,
    CancellationToken? cancelToken,
    Duration timeout = const Duration(minutes: 5),
  });
}

/// Deterministic tool call ID (SHA-256 style without external dep).
/// Hash of toolName + sorted JSON arguments ensures same call = same ID.
String buildToolCallId(String name, Map<String, dynamic> arguments) {
  final sorted = _sortedJsonString(arguments);
  final key = '$name:$sorted';
  final bytes = utf8.encode(key);
  return base64Url.encode(bytes).replaceAll('=', '').substring(0, 16);
}

String _sortedJsonString(Map<String, dynamic> map) {
  final sortedKeys = map.keys.toList()..sort();
  final parts = sortedKeys.map((k) {
    final v = map[k];
    if (v is Map<String, dynamic>) return '"$k":${_sortedJsonString(v)}';
    return '"$k":${jsonEncode(v)}';
  });
  return '{${parts.join(',')}}';
}
