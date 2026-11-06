// lib/views/client/historique_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/commande.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commande_provider.dart';
import '../../utils/formatage.dart';
import '../../widgets/ligne_montant.dart';

/// Historique des commandes du client connecté.
class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CommandeProvider>();
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final theme = Theme.of(context);

    if (cp.chargement && cp.commandes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => cp.charger(utilisateur!.id!),
      child: cp.commandes.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Icon(Icons.receipt_long_outlined, size: 80, color: theme.colorScheme.outline),
                const SizedBox(height: 12),
                Text(
                  'Aucune commande pour le moment',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: cp.commandes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _CarteCommande(commande: cp.commandes[i]),
                ),
              ),
            ),
    );
  }
}

class _CarteCommande extends StatelessWidget {
  final Commande commande;

  const _CarteCommande({required this.commande});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(child: Text('#${commande.id}', style: const TextStyle(fontSize: 12))),
        title: Text(
          'Commande n°${commande.id} • ${formatPrix(commande.total)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${formatDate(commande.date)} • ${commande.nombreArticles} article(s)'),
              _BadgeStatut(statut: commande.statut),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          for (final l in commande.lignes)
            LigneMontant(
              libelle: '${l.quantite} × ${l.nomProduit}',
              montant: formatPrix(l.total),
            ),
          const Divider(),
          LigneMontant(libelle: 'Sous-total', montant: formatPrix(commande.sousTotal)),
          if (commande.remise > 0)
            LigneMontant(
              libelle: 'Remise (${commande.codeCoupon})',
              montant: '- ${formatPrix(commande.remise)}',
              couleur: Colors.green,
            ),
          LigneMontant(libelle: 'Total payé', montant: formatPrix(commande.total), enGras: true),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(child: Text(commande.adresse, style: theme.textTheme.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final String statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    final couleur = switch (statut) {
      'Livrée' => Colors.green,
      'Expédiée' => Colors.blue,
      'Annulée' => Colors.red,
      _ => Colors.orange, // En préparation
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut,
        style: TextStyle(color: couleur, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
