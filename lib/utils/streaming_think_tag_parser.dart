/// Streaming-safe think tag parser with one-exit guard.
///
/// Mirrors Agora's approach:
/// - Only honors the first `think` or `thinking` block
/// - Once exited, never enters again (prevents swallowing literal tags in output)
/// - Handles partial tags at buffer boundaries
class StreamingThinkTagParser {
  static final RegExp _thinkOpen =
      RegExp(r'<think(?:ing)?\b[^>]*>', caseSensitive: false);

  String _buffer = '';
  bool _inThink = false;
  bool _exitedOnce = false;

  bool get isInThink => _inThink;
  bool get hasExited => _exitedOnce;

  /// Process a chunk and return any complete thought segment.
  String? process(String chunk) {
    if (_exitedOnce) return null;

    _buffer += chunk;

    if (!_inThink) {
      final openMatch = _thinkOpen.firstMatch(_buffer);
      if (openMatch != null) {
        _inThink = true;
        _buffer = _buffer.substring(openMatch.end);
      } else {
        _trimBuffer();
        return null;
      }
    }

    if (!_inThink) return null;

    // Look for closing tag
    const closePattern = '</think';
    final closeIdx = _buffer.indexOf(closePattern);
    if (closeIdx >= 0) {
      final endTagEnd = _buffer.indexOf('>', closeIdx);
      if (endTagEnd >= 0) {
        final thought = _buffer.substring(0, closeIdx);
        _buffer = _buffer.substring(endTagEnd + 1);
        _inThink = false;
        _exitedOnce = true;
        return thought;
      }
    }

    return null;
  }

  /// Flush any remaining thought content when stream ends.
  String? flush() {
    if (_inThink && _buffer.isNotEmpty) {
      _inThink = false;
      _exitedOnce = true;
      final thought = _buffer;
      _buffer = '';
      return thought;
    }
    return null;
  }

  void reset() {
    _buffer = '';
    _inThink = false;
    _exitedOnce = false;
  }

  void _trimBuffer() {
    // Keep up to last '<' in case it's the start of a think tag
    final lastOpen = _buffer.lastIndexOf('<');
    if (lastOpen >= 0) {
      _buffer = _buffer.substring(lastOpen);
    } else {
      _buffer = '';
    }
  }
}
