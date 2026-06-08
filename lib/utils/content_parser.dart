

class ContentSegment {
  final bool isThinking;
  final String content;
  const ContentSegment({required this.isThinking, required this.content});
}

class ParseResult {
  final List<ContentSegment> segments;
  final String? streamingThought;
  const ParseResult({required this.segments, this.streamingThought});
}

class ContentParser {
  ContentParser._();

  static final RegExp _thinkingOpen =
      RegExp(r'<think(?:ing)?\b[^>]*>', caseSensitive: false);
  static final RegExp _thinkingClose =
      RegExp(r'</think(?:ing)?\s*>', caseSensitive: false);

  /// Sanitizes raw model output before parsing.
  /// Fixes common formatting mistakes like unclosed code fences.
  static String sanitize(String content) {
    if (content.isEmpty) return content;

    // Auto-close unclosed ``` code fences
    final backtickCount =
        RegExp(r'^```', multiLine: true).allMatches(content).length;
    if (backtickCount.isOdd) {
      content += '\n```';
    }

    // Auto-close unclosed ~~~ code fences
    final tildeCount =
        RegExp(r'^~~~', multiLine: true).allMatches(content).length;
    if (tildeCount.isOdd) {
      content += '\n~~~';
    }

    return content;
  }

  /// Parses content into segments, handling:
  /// - Case-insensitive tag matching (`<thinking>`, `<THINKING>`, `<Thinking>`)
  /// - Tags with extra attributes (`<thinking class="hidden">`)
  /// - Nested thinking tags (inner tags become literal content)
  /// - Unclosed thinking tags (streaming detection)
  /// - Orphan closing tags (treated as regular text)
  /// - Partial/incomplete opening tags (no `>`, no word boundary)
  static ParseResult parse(String content) {
    final segments = <ContentSegment>[];
    int i = 0;
    int lastSegmentEnd = 0;
    int depth = 0;
    int thoughtContentStart = 0;

    while (i < content.length) {
      if (depth == 0) {
        final m = _thinkingOpen.matchAsPrefix(content, i);
        if (m != null) {
          if (i > lastSegmentEnd) {
            segments.add(ContentSegment(
              isThinking: false,
              content: content.substring(lastSegmentEnd, i),
            ));
          }
          depth = 1;
          thoughtContentStart = m.end;
          i = m.end;
          lastSegmentEnd = i;
          continue;
        }
      } else {
        final cm = _thinkingClose.matchAsPrefix(content, i);
        if (cm != null) {
          depth--;
          if (depth == 0) {
            segments.add(ContentSegment(
              isThinking: true,
              content: content.substring(thoughtContentStart, cm.start),
            ));
            i = cm.end;
            lastSegmentEnd = i;
            continue;
          }
          i = cm.end;
          continue;
        }

        final om = _thinkingOpen.matchAsPrefix(content, i);
        if (om != null) {
          depth++;
          i = om.end;
          continue;
        }
      }
      i++;
    }

    String? streamingThought;
    if (depth > 0) {
      streamingThought = content.substring(thoughtContentStart);
    }

    if (lastSegmentEnd < content.length && depth == 0) {
      segments.add(ContentSegment(
        isThinking: false,
        content: content.substring(lastSegmentEnd),
      ));
    }

    return ParseResult(segments: segments, streamingThought: streamingThought);
  }
}
