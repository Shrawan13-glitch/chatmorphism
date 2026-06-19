import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../constants.dart';
import '../utils/table_builder.dart';
import '../utils/blockquote_component.dart';

class ThinkingBlock extends StatefulWidget {
  final String content;
  final bool isStreaming;

  const ThinkingBlock({
    super.key,
    required this.content,
    this.isStreaming = false,
  });

  @override
  State<ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<ThinkingBlock>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isStreaming) {
      _glowController.repeat();
    }
  }

  @override
  void didUpdateWidget(ThinkingBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _glowController.repeat();
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceLight(context).withValues(alpha: 0.08),
            border: Border.all(
              color: widget.isStreaming
                  ? AppColors.accent.withValues(alpha: 0.25)
                  : AppColors.border(context).withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: widget.isStreaming
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            gradient: widget.isStreaming
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0),
                      AppColors.accent.withValues(
                        alpha: 0.06 * (_glowAnimation.value.clamp(0.0, 1.0)),
                      ),
                      AppColors.accent.withValues(alpha: 0),
                    ],
                    stops: [
                      0.0,
                      _glowAnimation.value.clamp(0.0, 1.0),
                      1.0,
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated brain/thinking icon
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(
                                alpha: widget.isStreaming ? 0.15 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: widget.isStreaming
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              widget.isStreaming
                                  ? Icons.psychology_rounded
                                  : Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: AppColors.accent.withValues(
                                alpha: widget.isStreaming
                                    ? 0.5 + 0.5 * (_glowAnimation.value.clamp(0.0, 1.0))
                                    : 0.7,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      // Thinking label
                      Text(
                        'Thinking',
                        style: TextStyle(
                          color: widget.isStreaming
                              ? AppColors.accent.withValues(alpha: 0.9)
                              : AppColors.textSecondary(context).withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.isStreaming) ...[
                        const SizedBox(width: 6),
                        _buildStreamingDots(),
                      ],
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _expanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: widget.isStreaming
                      ? Text(
                          widget.content.isNotEmpty
                              ? '${widget.content} ...'
                              : 'Processing thoughts ...',
                          style: TextStyle(
                            color: AppColors.textSecondary(context).withValues(alpha: 0.8),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background(context).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border(context).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: GptMarkdown(
                            widget.content,
                            tableBuilder: tableWidget,
                            components: [
                              ...MarkdownComponent.globalComponents.where((c) => c is! BlockQuote),
                              BeautifulBlockQuote(),
                            ],
                          ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreamingDots() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final phase = (_glowController.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final active = i <= phase;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                '·',
                style: TextStyle(
                  color: AppColors.accent.withValues(alpha: active ? 0.8 : 0.3),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
