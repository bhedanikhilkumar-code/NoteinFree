import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notein_free/main.dart';
import 'package:notein_free/providers/auth_provider.dart';
import 'package:notein_free/providers/note_provider.dart';
import 'package:notein_free/providers/settings_provider.dart';
import 'package:notein_free/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows refreshed home experience', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(storageService),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(storageService),
          ),
          ChangeNotifierProvider<NoteProvider>(
            create: (_) => NoteProvider(storageService),
          ),
        ],
        child: const NoteinApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Notein'), findsOneWidget);
    expect(find.text('Create first note'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget);
  });
}
