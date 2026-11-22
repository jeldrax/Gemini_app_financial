import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/auth/auth_provider.dart';
import 'package:gemini_app/presentation/screens/basic_prompt/basic_prompt_screen.dart';
import 'package:gemini_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:gemini_app/presentation/screens/login/login_screen.dart';
import 'package:gemini_app/presentation/screens/login/signup_screen.dart';
import 'package:gemini_app/presentation/screens/settings/settings_screen.dart';
import 'package:gemini_app/presentation/screens/transactions/transactions_screen.dart';
import 'package:go_router/go_router.dart';

class _AuthRouterRefreshNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _authSubscription;

  _AuthRouterRefreshNotifier() {
    if (Firebase.apps.isNotEmpty) {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
        notifyListeners();
      });
    }
  }

  void triggerRefresh() => notifyListeners();

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefreshNotifier();

  ref.listen<bool>(
    authRedirectHoldProvider,
    (_, _) => refreshNotifier.triggerRefresh(),
  );

  final router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/signup';
      final isLoggedIn =
          Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;
      final holdRedirect = ref.read(authRedirectHoldProvider);

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && (isAuthRoute || location == '/') && !holdRedirect) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/basic-prompt',
        builder: (context, state) => const BasicPromptScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
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

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });

  return router;
});
