import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/ai_model.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  ThemeMode _themeMode = ThemeMode.dark;
  String _apiKey = '';
  String _defaultModel = '';
  String _appPrompt = defaultAppPrompt;
  String _userPrompt = '';
  List<String> _favoriteModelIds = [];
  List<AiModel> _availableModels = [];
  bool _modelsLoaded = false;

  ThemeMode get themeMode => _themeMode;
  String get apiKey => _apiKey;
  String get defaultModel => _defaultModel;
  String get appPrompt => _appPrompt;
  String get userPrompt => _userPrompt;
  String get systemPrompt {
    if (_userPrompt.trim().isEmpty) return _appPrompt;
    return '$_appPrompt\n\n$_userPrompt';
  }
  List<String> get favoriteModelIds => _favoriteModelIds;
  List<AiModel> get availableModels => _availableModels;
  bool get modelsLoaded => _modelsLoaded;
  bool get hasApiKey => _apiKey.isNotEmpty;

  static const String defaultAppPrompt = '''You are ChatMorphism, a helpful AI assistant.

Always think step-by-step before answering every question, no matter how simple. Show your internal reasoning inside <thinking> tags:

<thinking>Your step-by-step reasoning here</thinking>

Then write your response. You can think multiple times during a response — think, respond, think again, respond.

Examples:
- For "What is 2+2?" → <thinking>2+2 is a basic addition. 2 plus 2 equals 4.</thinking>The answer is 4.
- For "Explain gravity" → <thinking>The user wants an explanation of gravity. I should cover Newton's law, Einstein's general relativity, and everyday examples.</thinking>Gravity is a fundamental force...

Always use <thinking> tags. Be thorough in your reasoning.''';

  List<AiModel> get favoriteModels {
    if (_favoriteModelIds.isEmpty) return [];
    return _availableModels
        .where((m) => _favoriteModelIds.contains(m.id))
        .toList();
  }

  AiModel? getModelById(String id) {
    try {
      return _availableModels.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    final theme = await _db.getSetting('theme_mode');
    if (theme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == theme,
        orElse: () => ThemeMode.dark,
      );
    }

    _apiKey = (await _db.getSetting('api_key')) ?? '';
    _defaultModel = (await _db.getSetting('default_model')) ?? '';
    _appPrompt = (await _db.getSetting('app_prompt')) ??
        (await _db.getSetting('system_prompt')) ??
        defaultAppPrompt;
    await _db.deleteSetting('system_prompt');
    _userPrompt = (await _db.getSetting('user_prompt')) ?? '';

    final favIds = await _db.getSetting('favorite_models');
    if (favIds != null && favIds.isNotEmpty) {
      _favoriteModelIds = (jsonDecode(favIds) as List)
          .map((e) => e.toString())
          .toList();
    }

    final cached = await _db.getSetting('cached_models');
    if (cached != null && cached.isNotEmpty) {
      final list = jsonDecode(cached) as List;
      _availableModels = list.map((e) => AiModel.fromJson(e)).toList();
      _modelsLoaded = true;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _db.setSetting('theme_mode', mode.name);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _db.setSetting('api_key', key);
    notifyListeners();
  }

  Future<void> setDefaultModel(String modelId) async {
    _defaultModel = modelId;
    await _db.setSetting('default_model', modelId);
    notifyListeners();
  }

  Future<void> setAppPrompt(String prompt) async {
    _appPrompt = prompt;
    await _db.setSetting('app_prompt', prompt);
    notifyListeners();
  }

  Future<void> setUserPrompt(String prompt) async {
    _userPrompt = prompt;
    await _db.setSetting('user_prompt', prompt);
    notifyListeners();
  }

  Future<void> setAvailableModels(List<AiModel> models) async {
    _availableModels = models;
    _modelsLoaded = true;
    await _db.setSetting('cached_models', jsonEncode(models.map((m) => m.toJson()).toList()));
    notifyListeners();
  }

  Future<void> toggleFavoriteModel(String modelId) async {
    if (_favoriteModelIds.contains(modelId)) {
      _favoriteModelIds.remove(modelId);
    } else {
      _favoriteModelIds.add(modelId);
    }

    if (_defaultModel.isEmpty || !_favoriteModelIds.contains(_defaultModel)) {
      _defaultModel =
          _favoriteModelIds.isNotEmpty ? _favoriteModelIds.first : '';
      await _db.setSetting('default_model', _defaultModel);
    }

    await _db.setSetting('favorite_models', jsonEncode(_favoriteModelIds));
    notifyListeners();
  }

  bool isFavorite(String modelId) => _favoriteModelIds.contains(modelId);

  Future<void> clearApiKey() async {
    _apiKey = '';
    _availableModels = [];
    _favoriteModelIds = [];
    _defaultModel = '';
    _modelsLoaded = false;
    await _db.setSetting('api_key', '');
    await _db.setSetting('favorite_models', jsonEncode([]));
    await _db.setSetting('default_model', '');
    await _db.setSetting('cached_models', '');
    notifyListeners();
  }
}
