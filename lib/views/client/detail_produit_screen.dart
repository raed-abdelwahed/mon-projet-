// lib/views/client/detail_produit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/produit.dart';
import '../../providers/panier_provider.dart';
import '../../widgets/prix_widget.dart';
import '../../widgets/produit_card.dart';
import '../../widgets/produit_image.dart';

class DetailProduitScreen extends StatefulWidget {
  final Produit produit;

  const DetailProduitScreen({super.key, required this.produit});

  @override
  State<DetailProduitScreen> createState() => _DetailProduitScreenState();
}

class _DetailProduitScreenState extends State<DetailProduitScreen> {
  int _quantite = 1;

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    final theme = Theme.of(context);
    final dejaDansPanier = context.watch<PanierProvider>().quantiteDe(produit.id!);
    final maximum = produit.stock - dejaDansPanier; // ce qu'on peut encore ajouter
    final int limite = maximum < 1 ? 1 : maximum;
    final int quantite = _quantite < 1 ? 1 : (_quantite > limite ? limite : _quantite);

    return Scaffold(
      appBar: AppBar(title: Text(produit.nom)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ProduitImage(produit: produit, tailleIcone: 110),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(produit.categorie)),
                          if (produit.vedette)
                            const Chip(
                              avatar: Icon(Icons.star_rounded, color: Colors.amber),
                              label: Text('Vedette'),
                            ),
                          if (produit.enPromo)
                            Chip(label: Text('Promo -${produit.pourcentagePromo}%')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        produit.nom,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      PrixWidget(produit: produit, grand: true),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            produit.enStock ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: produit.enStock ? Colors.green : theme.colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Text(produit.enStock
                              ? 'En stock (${produit.stock} disponibles)'
                              : 'Rupture de stock'),
                        ],
                      ),
                      if (dejaDansPanier > 0) ...[
                        const SizedBox(height: 4),
                        Text('Déjà $dejaDansPanier dans votre panier',
                            style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 20),
                      Text('Description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(produit.description),
                      const SizedBox(height: 28),
                      if (maximum > 0)
                        Row(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.remove),
                              onPressed: quantite > 1
                                  ? () => setState(() => _quantite = quantite - 1)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$quantite', style: theme.textTheme.titleLarge),
                            ),
                            IconButton.outlined(
                              icon: const Icon(Icons.add),
                              onPressed: quantite < maximum
                                  ? () => setState(() => _quantite = quantite + 1)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Ajouter au panier'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  ajouterAuPanier(context, produit, quantite: quantite);
                                  setState(() => _quantite = 1);
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          produit.enStock
                              ? 'Vous avez déjà tout le stock disponible dans votre panier.'
                              : 'Ce produit n\'est plus disponible pour le moment.',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
