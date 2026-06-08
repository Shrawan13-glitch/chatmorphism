import 'package:flutter/material.dart';
import 'streaming_markdown.dart';

class AiResponse extends StatelessWidget {
  final String content;
  final bool isStreaming;

  const AiResponse({super.key, required this.content, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    return StreamingMarkdown(
      content: content,
      isStreaming: isStreaming,
    );
  }
}
