// lib/widgets/produit_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/produit.dart';
import '../providers/panier_provider.dart';
import '../views/client/detail_produit_screen.dart';
import 'prix_widget.dart';
import 'produit_image.dart';

/// Ajoute un produit au panier et affiche un message en bas de l'écran.
void ajouterAuPanier(BuildContext context, Produit produit, {int quantite = 1}) {
  final ok = context.read<PanierProvider>().ajouter(produit, quantite: quantite);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(ok
          ? '« ${produit.nom} » ajouté au panier'
          : 'Stock insuffisant pour « ${produit.nom} »'),
    ));
}

/// Carte d'un produit dans la grille de la boutique.
class ProduitCard extends StatelessWidget {
  final Produit produit;

  const ProduitCard({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailProduitScreen(produit: produit)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: ProduitImage(produit: produit)),
                  if (produit.enPromo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Etiquette(
                        texte: '-${produit.pourcentagePromo}%',
                        couleur: theme.colorScheme.error,
                        couleurTexte: theme.colorScheme.onError,
                      ),
                    ),
                  if (!produit.enStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: _Etiquette(
                        texte: 'Rupture de stock',
                        couleur: theme.colorScheme.inverseSurface,
                        couleurTexte: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(produit.categorie, style: theme.textTheme.bodySmall),
                  Row(
                    children: [
                      Expanded(child: PrixWidget(produit: produit)),
                      IconButton(
                        tooltip: 'Ajouter au panier',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: produit.enStock
                            ? () => ajouterAuPanier(context, produit)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  final String texte;
  final Color couleur;
  final Color couleurTexte;

  const _Etiquette({required this.texte, required this.couleur, required this.couleurTexte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
      child: Text(
        texte,
        style: TextStyle(color: couleurTexte, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
