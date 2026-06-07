import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'database/database_helper.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const ChatmorphismApp(),
    ),
  );
}
