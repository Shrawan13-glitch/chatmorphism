import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/message.dart' show ToolCall;

class ToolCallBlock extends StatefulWidget {
  final ToolCall toolCall;
  final bool isStreaming;

  const ToolCallBlock({
    super.key,
    required this.toolCall,
    this.isStreaming = false,
  });

  @override
  State<ToolCallBlock> createState() => _ToolCallBlockState();
}

class _ToolCallBlockState extends State<ToolCallBlock>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isStreaming) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ToolCallBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _toolLabel(String name) {
    // Convert snake_case to Title Case
    final words = name.split('_');
    return words.map((w) => w.isNotEmpty 
        ? '${w[0].toUpperCase()}${w.substring(1)}' 
        : w
    ).join(' ');
  }

  IconData _toolIcon(String name) {
    return switch (name) {
      'read_file' || 'read_files' => Icons.description_outlined,
      'write_file' || 'fs_write' || 'fs_append' => Icons.edit_note_outlined,
      'execute_bash' || 'execute' => Icons.terminal_outlined,
      'search' || 'grep_search' || 'file_search' => Icons.search_outlined,
      'web_fetch' || 'remote_web_search' => Icons.language_outlined,
      'list_directory' => Icons.folder_outlined,
      'delete_file' => Icons.delete_outline,
      _ => Icons.extension_outlined,
    };
  }

  (String status, Color color, IconData icon) _getStatusInfo() {
    if (widget.toolCall.error) {
      return ('Error', AppColors.error, Icons.error_outline_rounded);
    }
    if (widget.toolCall.completed) {
      return ('Done', AppColors.success, Icons.check_circle_outline_rounded);
    }
    if (widget.isStreaming) {
      return ('Running', AppColors.accent, Icons.hourglass_empty_rounded);
    }
    return ('Pending', AppColors.textSecondary(context), Icons.schedule_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final (status, statusColor, statusIcon) = _getStatusInfo();
    final toolIcon = _toolIcon(widget.toolCall.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight(context).withValues(alpha: _expanded ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded 
              ? AppColors.border(context).withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Tool icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      toolIcon,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tool name
                  Expanded(
                    child: Text(
                      _toolLabel(widget.toolCall.name),
                      style: TextStyle(
                        color: AppColors.textPrimary(context).withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  // Status badge
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: widget.isStreaming ? 0.15 * _pulseAnimation.value : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 12,
                              color: statusColor.withValues(
                                alpha: widget.isStreaming ? _pulseAnimation.value : 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor.withValues(
                                  alpha: widget.isStreaming ? _pulseAnimation.value : 1.0,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Expand indicator
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arguments section
                  _buildSection(
                    context,
                    'Input',
                    Icons.input_outlined,
                    JsonEncoder.withIndent('  ').convert(widget.toolCall.arguments),
                  ),
                  // Result or Error section
                  if (widget.toolCall.result != null) ...[
                    const SizedBox(height: 10),
                    _buildSection(
                      context,
                      widget.toolCall.error ? 'Error' : 'Output',
                      widget.toolCall.error ? Icons.error_outline : Icons.output_outlined,
                      widget.toolCall.result!,
                      isError: widget.toolCall.error,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String label,
    IconData icon,
    String content, {
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isError
                  ? AppColors.error.withValues(alpha: 0.7)
                  : AppColors.textSecondary(context).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isError
                    ? AppColors.error.withValues(alpha: 0.7)
                    : AppColors.textSecondary(context).withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Content container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError
                ? AppColors.error.withValues(alpha: 0.06)
                : AppColors.background(context).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.border(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              color: isError
                  ? AppColors.error.withValues(alpha: 0.9)
                  : AppColors.textPrimary(context).withValues(alpha: 0.85),
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.5,
            ),
            maxLines: 30,
          ),
        ),
      ],
    );
  }
}
