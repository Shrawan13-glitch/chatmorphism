import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          splashRadius: 20,
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'API Configuration'),
          const SizedBox(height: 8),
          _buildApiUrlField(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Data'),
          const SizedBox(height: 8),
          _buildDataOptions(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRadioTile(
            context,
            title: 'Dark',
            subtitle: 'Dark mode throughout',
            icon: Icons.dark_mode_rounded,
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _buildRadioTile(
            context,
            title: 'Light',
            subtitle: 'Light mode throughout',
            icon: Icons.light_mode_rounded,
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _buildRadioTile(
            context,
            title: 'System',
            subtitle: 'Follow system settings',
            icon: Icons.settings_suggest_rounded,
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiUrlField(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.apiBaseUrl);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            hintText: 'https://api.example.com/v1',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
          onChanged: (value) => settings.setApiBaseUrl(value),
        ),
      ),
    );
  }

  Widget _buildDataOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildDataTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup data',
            subtitle: 'Export all conversations as JSON',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Backup feature coming soon'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _buildDataTile(
            context,
            icon: Icons.restore_outlined,
            title: 'Restore data',
            subtitle: 'Import conversations from backup',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Restore feature coming soon'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _buildDataTile(
            context,
            icon: Icons.delete_sweep_outlined,
            title: 'Clear all chats',
            subtitle: 'Permanently delete all conversations',
            isDestructive: true,
            onTap: () => _showClearConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoTile(context, 'Version', '1.0.0'),
          const Divider(height: 0.5, color: AppColors.border),
          _buildInfoTile(context, 'App', 'ChatMorphism'),
          const Divider(height: 0.5, color: AppColors.border),
          _buildInfoTile(context, 'Database', 'SQLite (backup-ready)'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear all chats?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete all conversations. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().clearAllChats();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
