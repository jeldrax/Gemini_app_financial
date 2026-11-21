import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gemini_app/config/router/app_router.dart';
import 'package:gemini_app/config/theme/app_theme.dart';
import 'package:gemini_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // debugPrint(dotenv.env['ENDPOINT_API']);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized: ${Firebase.app().name}');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
  }

  AppTheme.setSystemUIOverlayStyle(isDarkMode: true);

  runApp(const ProviderScope(child: GeminiApp()));
}

class GeminiApp extends ConsumerWidget {
  const GeminiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme(isDarkMode: true).getTheme(),
    );
  }
}
