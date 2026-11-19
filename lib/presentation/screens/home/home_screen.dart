import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    if (Firebase.apps.isEmpty) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);
    final firebaseUser =
        authAsync.asData?.value ??
        (Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null);
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = firebaseUser?.displayName?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GOOGLE GEMINI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person_outline),
            ),
            title: const Text('Prompt básico a Gemini'),
            subtitle: const Text('usando un modelo flash'),
            onTap: () => context.push('/basic-prompt'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.verified_user_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              (displayName != null && displayName.isNotEmpty)
                  ? displayName
                  : 'Sesión activa',
            ),
            subtitle: Text(
              firebaseUser?.email ?? 'Autenticado con Firebase',
            ),
            trailing: IconButton(
              icon: Icon(Icons.logout, color: colorScheme.error),
              tooltip: 'Cerrar sesión',
              onPressed: () => _signOut(context),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.dashboard_rounded),
            ),
            title: const Text('Dashboard'),
            subtitle: const Text('Dashboard para futuras integraciones'),
            onTap: () => context.push('/dashboard'),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.transfer_within_a_station),
            ),
            title: const Text('Movimientos'),
            subtitle: const Text(
              'Historial de transacciones para futuras integraciones',
            ),
            onTap: () => context.push('/transactions'),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.settings),
            ),
            title: const Text('Configuración y seguridad'),
            subtitle: const Text(
              'Ajustes de la aplicación para futuras integraciones',
            ),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
