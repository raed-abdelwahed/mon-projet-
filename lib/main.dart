// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/commande_provider.dart';
import 'providers/panier_provider.dart';
import 'providers/produit_provider.dart';
import 'providers/theme_provider.dart';
import 'views/admin/admin_accueil_screen.dart';
import 'views/auth/connexion_screen.dart';
import 'views/client/client_shell.dart';

Future<void> main() async {
  // Obligatoire avant d'utiliser SharedPreferences / SQLite au démarrage
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.chargerTheme();

  final authProvider = AuthProvider();
  await authProvider.initialiser(); // ouvre la base et restaure la session

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProduitProvider()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) => CommandeProvider()),
      ],
      child: const MonApplication(),
    ),
  );
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SUP4 DEV E-Commerce',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.modeTheme,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const Aiguillage(),
    );
  }
}

/// Affiche le bon espace selon l'utilisateur connecté (séparation des rôles).
class Aiguillage extends StatelessWidget {
  const Aiguillage({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;

    if (utilisateur == null) return const ConnexionScreen();
    if (utilisateur.estAdmin) return const AdminAccueilScreen();
    return const ClientShell();
  }
}
