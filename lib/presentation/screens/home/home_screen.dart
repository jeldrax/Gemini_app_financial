import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GOOGLE GEMINI')),
      body: ListView(
        children: [
          //home_screen.dart
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person_outline),
            ),
            title: const Text('Prompt básico a Gemini'),
            subtitle: const Text('usando un modelo flash'),
            onTap: () => context.push('/basic-prompt'),
          ),
          //login_screen.dart
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.login_outlined),
            ),
            title: const Text('Login anticipado'),
            subtitle: const Text('login para futuras integraciones'),
            onTap: () => context.push('/login'),
          ),
          //dashboard_screen.dart
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.dashboard_rounded),
            ),
            title: const Text('Dashboard'),
            subtitle: const Text('Dashboard para futuras integraciones'),
            onTap: () => context.push('/dashboard'),
          ),
          //transactions_screen.dart
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
          //settings_screen.dart
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
