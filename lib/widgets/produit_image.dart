// lib/widgets/produit_image.dart
import 'package:flutter/material.dart';

import '../models/produit.dart';

/// Illustration du produit selon sa catégorie
/// (l'upload de vraies photos pourra être ajouté plus tard avec image_picker).
class ProduitImage extends StatelessWidget {
  final Produit produit;
  final double tailleIcone;

  const ProduitImage({super.key, required this.produit, this.tailleIcone = 56});

  static const Map<String, IconData> _icones = {
    'Électronique': Icons.headphones,
    'Mode': Icons.checkroom,
    'Maison': Icons.chair_outlined,
    'Sport': Icons.sports_soccer,
  };

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      color: couleurs.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        _icones[produit.categorie] ?? Icons.shopping_bag_outlined,
        size: tailleIcone,
        color: couleurs.onPrimaryContainer,
      ),
    );
  }
}
