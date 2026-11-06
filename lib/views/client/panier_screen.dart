// lib/views/client/panier_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/article_panier.dart';
import '../../providers/panier_provider.dart';
import '../../utils/formatage.dart';
import '../../widgets/ligne_montant.dart';
import '../../widgets/produit_image.dart';
import 'paiement_screen.dart';

class PanierScreen extends StatefulWidget {
  /// Appelé après une commande réussie (pour ouvrir l'onglet « Commandes »).
  final VoidCallback onCommandeValidee;

  const PanierScreen({super.key, required this.onCommandeValidee});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final _couponCtrl = TextEditingController();
  bool _verificationCoupon = false;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _appliquerCoupon() async {
    setState(() => _verificationCoupon = true);
    final erreur = await context.read<PanierProvider>().appliquerCoupon(_couponCtrl.text);
    if (!mounted) return;
    setState(() => _verificationCoupon = false);
    if (erreur == null) _couponCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erreur ?? 'Code promo appliqué ✅')),
    );
  }

  Future<void> _commander() async {
    final reussi = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaiementScreen()),
    );
    if (reussi == true) widget.onCommandeValidee();
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final theme = Theme.of(context);

    if (panier.estVide) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_shopping_cart_outlined, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('Votre panier est vide', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('Ajoutez des produits depuis la boutique.'),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: panier.articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _LignePanier(article: panier.articles[i]),
              ),
            ),

            // Résumé en bas : coupon + totaux + bouton commander
            Material(
              elevation: 8,
              color: theme.colorScheme.surfaceContainer,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (panier.coupon == null)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponCtrl,
                                textCapitalization: TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  hintText: 'Code promo',
                                  prefixIcon: Icon(Icons.local_offer_outlined),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _appliquerCoupon(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _verificationCoupon ? null : _appliquerCoupon,
                              child: const Text('Appliquer'),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const Icon(Icons.local_offer, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Code ${panier.coupon!.code} (-${panier.coupon!.pourcentage}%)',
                              ),
                            ),
                            TextButton(
                              onPressed: panier.retirerCoupon,
                              child: const Text('Retirer'),
                            ),
                          ],
                        ),
                      const Divider(height: 24),
                      LigneMontant(libelle: 'Sous-total', montant: formatPrix(panier.sousTotal)),
                      if (panier.remise > 0)
                        LigneMontant(
                          libelle: 'Remise',
                          montant: '- ${formatPrix(panier.remise)}',
                          couleur: Colors.green,
                        ),
                      LigneMontant(
                        libelle: 'Total',
                        montant: formatPrix(panier.total),
                        enGras: true,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.payment),
                          label: Text('Passer la commande (${panier.nombreArticles} articles)'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _commander,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LignePanier extends StatelessWidget {
  final ArticlePanier article;

  const _LignePanier({required this.article});

  @override
  Widget build(BuildContext context) {
    final panier = context.read<PanierProvider>();
    final theme = Theme.of(context);
    final produit = article.produit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: ProduitImage(produit: produit, tailleIcone: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${formatPrix(produit.prixFinal)} / unité',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    formatPrix(article.total),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => panier.diminuer(produit.id!),
            ),
            Text('${article.quantite}', style: theme.textTheme.titleMedium),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                if (!panier.ajouter(produit)) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Stock maximum atteint')));
                }
              },
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Retirer',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => panier.retirer(produit.id!),
            ),
          ],
        ),
      ),
    );
  }
}
