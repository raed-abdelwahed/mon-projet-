// lib/views/admin/admin_accueil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/bouton_theme.dart';

/// Espace administrateur — sera complété à l'étape 5
/// (CRUD produits, stocks, produits vedettes, promotions).
class AdminAccueilScreen extends StatelessWidget {
  const AdminAccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AuthProvider>().utilisateur;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace administrateur'),
        actions: [
          const BoutonTheme(),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().deconnecter(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings_outlined, size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Bienvenue, ${admin?.nom ?? ''}', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'La gestion des produits, des stocks et des promotions arrive à l\'étape 5.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
