// lib/views/client/accueil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/produit_provider.dart';
import '../../widgets/produit_card.dart';

/// Boutique : recherche, catégories, produits vedettes et grille de produits.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProduitProvider>();
    final theme = Theme.of(context);

    if (p.chargement && p.produits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final produits = p.produitsFiltres;
    final afficherVedettes =
        p.vedettes.isNotEmpty && p.recherche.isEmpty && p.categorie == null;

    return RefreshIndicator(
      onRefresh: p.charger,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Barre de recherche
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: p.rechercher,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  isDense: true,
                ),
              ),
            ),
          ),

          // Catégories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  ChoiceChip(
                    label: const Text('Tous'),
                    selected: p.categorie == null,
                    onSelected: (_) => p.choisirCategorie(null),
                  ),
                  for (final c in p.categories)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: p.categorie == c,
                        onSelected: (_) => p.choisirCategorie(c),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Produits vedettes
          if (afficherVedettes) ...[
            _Titre(texte: 'Produits vedettes', icone: Icons.star_rounded, couleur: Colors.amber),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: p.vedettes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 170,
                    child: ProduitCard(produit: p.vedettes[i]),
                  ),
                ),
              ),
            ),
          ],

          // Tous les produits
          _Titre(
            texte: 'Tous les produits (${produits.length})',
            icone: Icons.grid_view_rounded,
            couleur: theme.colorScheme.primary,
          ),
          if (produits.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Aucun produit trouvé.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProduitCard(produit: produits[i]),
                  childCount: produits.length,
                ),
                // Responsive : le nombre de colonnes s'adapte à la largeur
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Titre extends StatelessWidget {
  final String texte;
  final IconData icone;
  final Color couleur;

  const _Titre({required this.texte, required this.icone, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Icon(icone, color: couleur),
            const SizedBox(width: 6),
            Text(
              texte,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
