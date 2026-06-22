import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';
import '../services/github/github_oauth_service.dart';
import 'models_screen.dart';
import 'system_prompt_screen.dart';
import 'app_prompt_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary(context)),
          splashRadius: 20,
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.border(context)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Configuration'),
          const SizedBox(height: 8),
          _buildSystemPromptTile(context),
          const SizedBox(height: 4),
          _buildAppPromptTile(context),
          const SizedBox(height: 4),
          _buildWebFetchTile(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Providers'),
          const SizedBox(height: 8),
          _buildProviderTile(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'GitHub Integration'),
          const SizedBox(height: 8),
          _buildGithubTile(context),
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
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
          Divider(height: 0.5, color: AppColors.border(context)),
          _buildRadioTile(
            context,
            title: 'Light',
            subtitle: 'Light mode throughout',
            icon: Icons.light_mode_rounded,
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          Divider(height: 0.5, color: AppColors.border(context)),
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
                color: isSelected ? AppColors.primary : AppColors.textSecondary(context),
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
                            ? AppColors.textPrimary(context)
                            : AppColors.textSecondary(context),
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
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
                    color:
                        isSelected ? AppColors.primary : AppColors.border(context),
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

  Widget _buildSystemPromptTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SystemPromptScreen()),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 22,
                    color: AppColors.textSecondary(context)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Prompt',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        'Controls model behavior and reasoning',
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppPromptTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _showAppPromptWarning(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.tune_rounded,
                  size: 14, color: AppColors.textSecondary(context).withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Text(
                'Behavior prompt',
                style: TextStyle(
                  color: AppColors.textSecondary(context).withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textSecondary(context).withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebFetchTile(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWebFetchTimeoutDialog(context, settings),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.public_rounded,
                    size: 22,
                    color: AppColors.textSecondary(context)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Web fetch timeout',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        'Power fetch (WebView) fallback timeout',
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${settings.webFetchTimeout}s',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWebFetchTimeoutDialog(
      BuildContext context, SettingsProvider settings) {
    var tempValue = settings.webFetchTimeout.toDouble();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Web fetch timeout',
              style: TextStyle(color: AppColors.textPrimary(ctx))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How long to wait for pages to load in the WebView fallback.',
                style: TextStyle(
                    color: AppColors.textSecondary(ctx), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Text(
                '${tempValue.round()} seconds',
                style: TextStyle(
                  color: AppColors.textPrimary(ctx),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: tempValue,
                min: 5,
                max: 120,
                divisions: 23,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border(context),
                onChanged: (v) => setState(() => tempValue = v),
              ),
              Text(
                'Range: 5–120 seconds',
                style: TextStyle(
                    color: AppColors.textSecondary(ctx), fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary(ctx))),
            ),
            TextButton(
              onPressed: () {
                settings.setWebFetchTimeout(tempValue.round());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppPromptWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text('App behavior prompt',
                  style: TextStyle(color: AppColors.textPrimary(ctx))),
            ),
          ],
        ),
        content: Text(
          'This prompt controls how the model thinks and structures its responses. '
          'Changing it may affect response quality. '
          'The app always prepends this to your custom instructions.',
          style: TextStyle(color: AppColors.textSecondary(ctx), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary(ctx))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppPromptScreen()),
              );
            },
            child: const Text('Edit anyway',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isConnected = settings.hasApiKey;
    final subtitle = isConnected
        ? '${settings.favoriteModelIds.length} models selected'
        : 'Tap to configure';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ModelsScreen()),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.key_rounded,
                    size: 22,
                    color: AppColors.textSecondary(context)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OpenRouter',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Setup',
                    style: TextStyle(
                      color:
                          isConnected ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGithubTile(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final isConnected = settings.isGithubConnected;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGithubDialog(context, settings, chatProvider),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.volume_up_rounded,
                    size: 22,
                    color: AppColors.textSecondary(context)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GitHub',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        isConnected
                            ? 'Connected as @${settings.githubUsername} · TTS + Agent tools'
                            : 'Connect GitHub for TTS, repo management, CI/CD, and more',
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isConnected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '@${settings.githubUsername}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Setup',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGithubDialog(BuildContext context, SettingsProvider settings,
      ChatProvider chatProvider) {
    if (settings.isGithubConnected) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('GitHub Integration',
              style: TextStyle(color: AppColors.textPrimary(ctx))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connected as @${settings.githubUsername}',
                style: TextStyle(
                    color: AppColors.textSecondary(ctx), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'The AI agent can manage repos, create branches and PRs, '
                'trigger Actions workflows, browse files, and more.',
                style: TextStyle(
                    color: AppColors.textSecondary(ctx), fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'TTS: generate_speech uses a GitHub Actions workflow '
                'to run ShryneTTS and produce high-quality speech.',
                style: TextStyle(
                    color: AppColors.textSecondary(ctx)
                        .withValues(alpha: 0.7),
                    fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                chatProvider.githubAuth.clear();
                settings.clearGithubCredentials();
                Navigator.of(ctx).pop();
              },
              child: Text('Disconnect',
                  style: TextStyle(color: AppColors.error)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Done',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _GithubLoginDialog(
        settings: settings,
        chatProvider: chatProvider,
      ),
    );
  }

  Widget _buildDataOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
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
                  backgroundColor: AppColors.surface(context),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Divider(height: 0.5, color: AppColors.border(context)),
          _buildDataTile(
            context,
            icon: Icons.restore_outlined,
            title: 'Restore data',
            subtitle: 'Import conversations from backup',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Restore feature coming soon'),
                  backgroundColor: AppColors.surface(context),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Divider(height: 0.5, color: AppColors.border(context)),
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
    final color =
        isDestructive ? AppColors.error : AppColors.textPrimary(context);
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
                    : AppColors.textSecondary(context),
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
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary(context).withValues(alpha: 0.5),
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '?';
              final build = snapshot.data?.buildNumber ?? '?';
              return _buildInfoTile(context, 'Version', '$version+$build');
            },
          ),
          Divider(height: 0.5, color: AppColors.border(context)),
          _buildInfoTile(context, 'App', 'Kino'),
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
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
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
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Clear all chats?',
            style: TextStyle(color: AppColors.textPrimary(ctx))),
        content: Text(
          'This will permanently delete all conversations. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary(ctx))),
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

enum _LoginMethod { oauth, pat }

class _GithubLoginDialog extends StatefulWidget {
  final SettingsProvider settings;
  final ChatProvider chatProvider;

  const _GithubLoginDialog({
    required this.settings,
    required this.chatProvider,
  });

  @override
  State<_GithubLoginDialog> createState() => _GithubLoginDialogState();
}

class _GithubLoginDialogState extends State<_GithubLoginDialog> {
  final _clientIdController = TextEditingController();
  final _patController = TextEditingController();
  _LoginMethod _method = _LoginMethod.oauth;
  bool _isLoggingIn = false;
  String? _userCode;
  String? _verificationUri;
  String? _statusMessage;
  Timer? _pollTimer;
  GithubOauthService? _oauth;

  @override
  void initState() {
    super.initState();
    _clientIdController.text = widget.settings.githubClientId;
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _patController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _startOauthLogin() async {
    final clientId = _clientIdController.text.trim();
    if (clientId.isEmpty) return;

    if (clientId != widget.settings.githubClientId) {
      await widget.settings.setGithubClientId(clientId);
    }

    setState(() {
      _isLoggingIn = true;
      _statusMessage = 'Requesting device code...';
    });

    try {
      _oauth = GithubOauthService(clientId: clientId);
      final deviceFlow = await _oauth!.requestDeviceCode();

      setState(() {
        _userCode = deviceFlow.userCode;
        _verificationUri = deviceFlow.verificationUri;
        _statusMessage = null;
      });

      _startPolling(deviceFlow.deviceCode, deviceFlow.interval);
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loginWithPat() async {
    final pat = _patController.text.trim();
    if (pat.isEmpty) return;

    setState(() {
      _isLoggingIn = true;
      _statusMessage = 'Validating token...';
    });

    try {
      final valid = await widget.chatProvider.githubAuth.validateToken(pat);
      if (!mounted) return;

      if (valid) {
        final username = widget.chatProvider.githubAuth.username;
        if (username != null) {
          await widget.settings.setGithubCredentials(pat, username);
          widget.chatProvider.initGithub();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected as @$username'),
                backgroundColor: AppColors.surface(context),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          setState(() {
            _isLoggingIn = false;
            _statusMessage = 'Failed to verify user. Try again.';
          });
        }
      } else {
        setState(() {
          _isLoggingIn = false;
          _statusMessage = 'Invalid token. Check your PAT and try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  String? _deviceCode;

  void _startPolling(String deviceCode, int interval) {
    _deviceCode = deviceCode;
    _pollNow();
    _pollTimer = Timer.periodic(Duration(seconds: interval), (_) async {
      await _pollNow();
    });
  }

  Future<void> _pollNow() async {
    if (!mounted || _oauth == null || !_isLoggingIn || _deviceCode == null) return;

    try {
      final result = await _oauth!.pollForToken(_deviceCode!);
      if (!mounted) return;

      if (result.isSuccess) {
        _pollTimer?.cancel();
        setState(() => _statusMessage = 'Verifying...');

        final username = await _oauth!.fetchUsername(result.accessToken!);
        if (!mounted) return;

        if (username != null) {
          widget.chatProvider.githubAuth.restore(result.accessToken!, username);
          await widget.settings.setGithubCredentials(result.accessToken!, username);
          widget.chatProvider.initGithub();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected as @$username'),
                backgroundColor: AppColors.surface(context),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          setState(() {
            _isLoggingIn = false;
            _statusMessage = 'Failed to verify user. Try again.';
          });
        }
      } else if (result.isSlowDown) {
        // poll interval was too fast — Timer.periodic handles the next tick
      } else if (!result.isPending) {
        _pollTimer?.cancel();
        setState(() {
          _isLoggingIn = false;
          _statusMessage = 'Error: ${result.errorDescription ?? result.error}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Still waiting...');
    }
  }

  void _manualCheck() {
    _pollNow();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _isLoggingIn ? 'Authorize GitHub Integration' : 'Connect GitHub',
        style: TextStyle(color: AppColors.textPrimary(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login with your GitHub account to enable AI-powered repo management, '
              'CI/CD, TTS generation, and more.',
              style: TextStyle(
                  color: AppColors.textSecondary(context), fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (!_isLoggingIn && _userCode == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMethodTab(_LoginMethod.oauth, 'OAuth'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMethodTab(_LoginMethod.pat, 'PAT'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (_method == _LoginMethod.oauth) ...[
              if (!widget.settings.hasGithubClientId && !_isLoggingIn) ...[
                Text(
                  'GitHub OAuth App Client ID:',
                  style: TextStyle(
                      color: AppColors.textPrimary(context), fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create one at: github.com/settings/developers',
                  style: TextStyle(
                      color: AppColors.primary, fontSize: 11),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _clientIdController,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Iv1...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(context)
                          .withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBg(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (!_isLoggingIn && _userCode == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startOauthLogin,
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Login with GitHub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              if (_userCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Enter this code on GitHub:',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        _userCode!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _verificationUri!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'After authorizing on GitHub, tap Check:',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _manualCheck,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("I've authorized — Check now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            if (_method == _LoginMethod.pat && !_isLoggingIn && _userCode == null) ...[
              Text(
                'Personal Access Token:',
                style: TextStyle(
                    color: AppColors.textPrimary(context), fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Create at: github.com/settings/tokens',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _patController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'ghp_...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary(context)
                        .withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBg(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loginWithPat,
                  icon: const Icon(Icons.key_rounded, size: 18),
                  label: const Text('Connect with PAT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The token needs repo, workflow, and admin:org scopes '
                'for full functionality.',
                style: TextStyle(
                    color: AppColors.textSecondary(context)
                        .withValues(alpha: 0.6),
                    fontSize: 11),
              ),
            ],

            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Error')
                      || _statusMessage!.contains('Invalid')
                      ? AppColors.error
                      : AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],

            if (_method == _LoginMethod.oauth && !_isLoggingIn && _userCode == null) ...[
              const SizedBox(height: 16),
              Text(
                'The AI agent will use your GitHub account to manage repositories, '
                'branches, PRs, Actions, and more. A public "tts-generator" repo '
                'will be created for TTS via GitHub Actions.',
                style: TextStyle(
                    color: AppColors.textSecondary(context)
                        .withValues(alpha: 0.6),
                    fontSize: 11),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _pollTimer?.cancel();
            Navigator.of(context).pop();
          },
          child: Text(
            _isLoggingIn ? 'Cancel' : 'Back',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTab(_LoginMethod method, String label) {
    final isSelected = _method == method;
    return GestureDetector(
      onTap: () => setState(() => _method = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border(context),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary(context),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
