import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/note_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storageService = await StorageService.init();

  runApp(
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
}

class NoteinApp extends StatefulWidget {
  const NoteinApp({super.key});

  @override
  State<NoteinApp> createState() => _NoteinAppState();
}

class _NoteinAppState extends State<NoteinApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      Provider.of<AuthProvider>(context, listen: false).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (BuildContext context, SettingsProvider settings, Widget? child) {
        return MaterialApp(
          title: 'Notein Free',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.build(
            brightness: Brightness.light,
            fontOption: settings.fontOption,
            fontScale: settings.fontScale,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            fontOption: settings.fontOption,
            fontScale: settings.fontScale,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
