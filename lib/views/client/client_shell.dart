// lib/views/client/client_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/commande_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/produit_provider.dart';
import '../../widgets/bouton_theme.dart';
import 'accueil_screen.dart';
import 'historique_screen.dart';
import 'panier_screen.dart';

/// Squelette de l'espace client : barre du haut + 3 onglets en bas.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;
  static const _titres = ['Boutique', 'Mon panier', 'Mes commandes'];

  @override
  void initState() {
    super.initState();
    // On charge les données juste après le premier affichage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProduitProvider>().charger();
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (utilisateur != null) {
        context.read<CommandeProvider>().charger(utilisateur.id!);
      }
    });
  }

  Future<void> _deconnecter() async {
    context.read<PanierProvider>().vider();
    context.read<CommandeProvider>().vider();
    await context.read<AuthProvider>().deconnecter();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<PanierProvider>().nombreArticles;
    final nom = context.watch<AuthProvider>().utilisateur?.nom ?? '';

    final pages = [
      const AccueilScreen(),
      PanierScreen(onCommandeValidee: () => setState(() => _index = 2)),
      const HistoriqueScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titres[_index]),
        actions: [
          if (nom.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text('Bonjour, ${nom.split(' ').first}')),
            ),
          const BoutonTheme(),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: _deconnecter,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Boutique',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: nombre > 0,
              label: Text('$nombre'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: nombre > 0,
              label: Text('$nombre'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Panier',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
        ],
      ),
    );
  }
}
