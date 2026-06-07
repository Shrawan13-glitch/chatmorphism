import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chatmorphism/app.dart';
import 'package:chatmorphism/providers/chat_provider.dart';
import 'package:chatmorphism/providers/settings_provider.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const ChatmorphismApp(),
      ),
    );

    expect(find.text('ChatMorphism'), findsOneWidget);
  });
}
