// lib/widgets/prix_widget.dart
import 'package:flutter/material.dart';

import '../models/produit.dart';
import '../utils/formatage.dart';

/// Affiche le prix, avec l'ancien prix barré si le produit est en promotion.
class PrixWidget extends StatelessWidget {
  final Produit produit;
  final bool grand;

  const PrixWidget({super.key, required this.produit, this.grand = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stylePrix = (grand ? theme.textTheme.headlineSmall : theme.textTheme.titleSmall)
        ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold);

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(formatPrix(produit.prixFinal), style: stylePrix),
        if (produit.enPromo)
          Text(
            formatPrix(produit.prix),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }
}
