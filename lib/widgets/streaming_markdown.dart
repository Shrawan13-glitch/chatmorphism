import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../constants.dart';

class StreamingMarkdown extends StatefulWidget {
  final String content;
  final bool isStreaming;

  const StreamingMarkdown({
    super.key,
    required this.content,
    this.isStreaming = false,
  });

  @override
  State<StreamingMarkdown> createState() => _StreamingMarkdownState();
}

class _StreamingMarkdownState extends State<StreamingMarkdown>
    with SingleTickerProviderStateMixin {
  String _displayContent = '';
  Timer? _debounceTimer;



  bool _fading = false;
  int _front = 0;
  String _buf0 = '', _buf1 = '';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _wasStreaming = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _applyContent(widget.content, widget.isStreaming);
  }

  @override
  void didUpdateWidget(StreamingMarkdown old) {
    super.didUpdateWidget(old);
    _applyContent(widget.content, widget.isStreaming);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _applyContent(String content, bool isStreaming) {
    if (content.isEmpty) {
      _debounceTimer?.cancel();
      _displayContent = '';
      _buf0 = '';
      _buf1 = '';
      _front = 0;
      return;
    }

    if (!isStreaming) {
      _debounceTimer?.cancel();
      if (_wasStreaming) {
        _scheduleCrossfade(content);
      } else {
        _displayContent = content;
        _buf0 = content;
        _buf1 = '';
        _front = 0;
      }
      _wasStreaming = false;
      return;
    }

    _wasStreaming = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _scheduleCrossfade(widget.content);
    });
  }

  void _scheduleCrossfade(String newContent) {
    if (_fading) {
      _buf0 = newContent;
      _buf1 = '';
      _front = 0;
      _displayContent = newContent;
      _fading = false;
      _fadeCtrl.reset();
      if (mounted) setState(() {});
      return;
    }

    final next = 1 - _front;
    if (next == 0) {
      _buf0 = newContent;
    } else {
      _buf1 = newContent;
    }
    _displayContent = newContent;
    _fading = true;
    _fadeCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      _fading = false;
      _front = next;
      if (_front == 0) {
        _buf1 = '';
      } else {
        _buf0 = '';
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.isEmpty) return const SizedBox.shrink();

    final theme = _buildTheme(context);

    Widget body;
    if (widget.isStreaming) {
      body = _buildStreaming(theme);
    } else {
      body = MarkdownBody(
        data: _displayContent,
        selectable: true,
        styleSheet: theme,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.92,
        ),
        padding: const EdgeInsets.only(right: 24),
        child: _wrapAntiShrink(body),
      ),
    );
  }

  Widget _wrapAntiShrink(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: child,
        );
      },
    );
  }

  Widget _buildStreaming(MarkdownStyleSheet theme) {
    final bothNonEmpty = _buf0.isNotEmpty && _buf1.isNotEmpty;
    final doFade = _fading && bothNonEmpty;

    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (context, _) {
        final alpha = _fadeAnim.value;
        return Stack(
          children: [
            if (_buf0.isNotEmpty)
              Opacity(
                opacity: _front == 0
                    ? (doFade ? 1.0 - alpha : 1.0)
                    : (doFade ? alpha : 0.0),
                child: MarkdownBody(data: _buf0, styleSheet: theme),
              ),
            if (_buf1.isNotEmpty)
              Opacity(
                opacity: _front == 1
                    ? (doFade ? 1.0 - alpha : 1.0)
                    : (doFade ? alpha : 0.0),
                child: MarkdownBody(data: _buf1, styleSheet: theme),
              ),
          ],
        );
      },
    );
  }

  MarkdownStyleSheet _buildTheme(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final surfaceLight = AppColors.surfaceLight(context);
    final border = AppColors.border(context);

    return MarkdownStyleSheet(
      h1: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: TextStyle(
        color: textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h3: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      h4: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h5: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h6: TextStyle(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      p: TextStyle(
        color: textPrimary,
        fontSize: 15,
        height: 1.65,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: textSecondary,
      ),
      del: TextStyle(
        decoration: TextDecoration.lineThrough,
        color: textSecondary,
      ),
      code: TextStyle(
        backgroundColor: Colors.transparent,
        color: AppColors.accent,
        fontSize: 13,
        fontFamily: 'monospace',
        height: 1.4,
      ),
      codeblockDecoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      listBullet: TextStyle(
        color: AppColors.primary,
        fontSize: 15,
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontSize: 14,
      ),
      tableBody: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
      tableBorder: TableBorder.all(
        color: border,
        width: 0.5,
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableColumnWidth: const FlexColumnWidth(),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: border, width: 0.5),
        ),
      ),
      checkbox: TextStyle(color: AppColors.primary),
    );
  }
}
