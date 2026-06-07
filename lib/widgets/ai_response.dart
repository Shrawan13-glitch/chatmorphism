import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants.dart';

class AiResponse extends StatelessWidget {
  final String content;

  const AiResponse({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.92,
        ),
        padding: const EdgeInsets.only(right: 24),
        child: MarkdownBody(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            h2: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            h3: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            p: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.6,
            ),
            strong: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            em: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
            code: TextStyle(
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.accent,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            codeblockPadding: const EdgeInsets.all(16),
            blockquoteDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            listBullet: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
            ),
            tableHead: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            tableBody: const TextStyle(
              color: AppColors.textSecondary,
            ),
            tableBorder: TableBorder.all(
              color: AppColors.border,
              width: 0.5,
            ),
            tableCellsPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
