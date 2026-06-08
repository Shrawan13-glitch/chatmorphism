import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/tool_call.dart';

class ToolCallCard extends StatefulWidget {
  final ToolCall toolCall;

  const ToolCallCard({super.key, required this.toolCall});

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.toolCall;
    final icon = _iconFor(tool.name);
    final label = _labelFor(tool.name, tool.args);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: tool.result != null || tool.error != null
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tool.isRunning)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (tool.error != null)
                      const Icon(Icons.error_outline,
                          size: 16, color: AppColors.error)
                    else if (tool.result != null)
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 16,
                        color: AppColors.textSecondary(context),
                      ),
                  ],
                ),
              ),
            ),
            if (_expanded && tool.result != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  tool.result!,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'websearch':
        return Icons.language_rounded;
      case 'sysinfo':
        return Icons.phone_android_rounded;
      case 'calc':
        return Icons.calculate_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  String _labelFor(String name, String args) {
    switch (name) {
      case 'websearch':
        return 'Search: $args';
      case 'sysinfo':
        return 'System info: $args';
      case 'calc':
        return 'Calculate: $args';
      default:
        return '$name: $args';
    }
  }
}
