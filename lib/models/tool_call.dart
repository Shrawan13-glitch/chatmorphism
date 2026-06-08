class ToolCall {
  final String name;
  final String args;
  String? result;
  String? error;
  bool isRunning;

  ToolCall({
    required this.name,
    required this.args,
    this.result,
    this.error,
    this.isRunning = false,
  });

  String get displayStatus {
    if (isRunning) return 'running';
    if (error != null) return 'error';
    if (result != null) return 'done';
    return 'pending';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'args': args,
        'result': result ?? '',
        'error': error,
      };

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        name: json['name'] as String,
        args: json['args'] as String,
        result: json['result'] as String?,
        error: json['error'] as String?,
      );
}
