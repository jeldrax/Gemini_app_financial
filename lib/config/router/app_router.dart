import 'package:gemini_app/presentation/screens/dashboard/dashboard_creen.dart';
import 'package:gemini_app/presentation/screens/login/login_screen.dart';
import 'package:gemini_app/presentation/screens/transactions/transactions_screen.dart';
import 'package:gemini_app/presentation/screens/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:gemini_app/presentation/screens/home/home_screen.dart';
import 'package:gemini_app/presentation/screens/basic_prompt/basic_prompt_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/basic-prompt',
      builder: (context, state) => const BasicPromptScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardCreen(),
    ),

    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
