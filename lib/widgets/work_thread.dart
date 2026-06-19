import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/thread_entry.dart';
import '../models/message.dart' show ToolCall;
import 'thinking_block.dart';
import 'tool_call_block.dart';

class WorkThread extends StatefulWidget {
  final List<ThreadEntry> entries;

  const WorkThread({super.key, required this.entries});

  @override
  State<WorkThread> createState() => _WorkThreadState();
}

class _WorkThreadState extends State<WorkThread>
    with SingleTickerProviderStateMixin {
  bool _masterExpanded = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _checkAndStartGlow();
  }

  @override
  void didUpdateWidget(WorkThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndStartGlow();
  }

  void _checkAndStartGlow() {
    final isActive = widget.entries.any((e) => e.isStreaming);
    if (isActive) {
      _glowController.repeat();
    } else {
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
    final thinkingCount = widget.entries.whereType<ThinkingEntry>().length;
    final toolCount = widget.entries.whereType<ToolCallEntry>().length;
    final isActive = widget.entries.any((e) => e.isStreaming);
    final totalSteps = thinkingCount + toolCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isActive, totalSteps),
          if (_masterExpanded) ...[
            const SizedBox(height: 8),
            _buildTimeline(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(bool isActive, int totalSteps) {
    return InkWell(
      onTap: () => setState(() => _masterExpanded = !_masterExpanded),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceLight(context).withValues(alpha: 0.1),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border(context).withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0),
                        AppColors.primary.withValues(
                          alpha: 0.08 * (_glowAnimation.value.clamp(0.0, 1.0)),
                        ),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                      stops: [
                        0.0,
                        _glowAnimation.value.clamp(0.0, 1.0),
                        1.0,
                      ],
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated glow dot
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppColors.primary.withValues(
                                alpha: 0.5 + 0.5 * (_glowAnimation.value.clamp(0.0, 1.0)),
                              )
                            : AppColors.textSecondary(context).withValues(alpha: 0.4),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // Status text
                Text(
                  isActive ? 'Working' : 'Work',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : AppColors.textSecondary(context).withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                if (totalSteps > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalSteps step${totalSteps > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _masterExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final entries = widget.entries;
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.border(context).withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : 4,
                bottom: i == entries.length - 1 ? 0 : 4,
              ),
              child: _buildEntryContent(entries[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryContent(ThreadEntry entry) {
    switch (entry) {
      case ThinkingEntry(:final content, :final isStreaming):
        return ThinkingBlock(
          content: content,
          isStreaming: isStreaming,
        );

      case ToolCallEntry(
          :final toolCallId,
          :final toolName,
          :final toolArguments,
          :final completed,
          :final error,
          :final result,
          :final isExecuting,
        ):
        return ToolCallBlock(
          toolCall: ToolCall(
            id: toolCallId,
            name: toolName,
            arguments: toolArguments,
            completed: completed,
            error: error,
            result: result,
          ),
          isStreaming: isExecuting,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
