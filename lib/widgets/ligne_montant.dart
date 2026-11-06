// lib/widgets/ligne_montant.dart
import 'package:flutter/material.dart';

/// Une ligne « libellé ........ montant » (sous-total, remise, total).
class LigneMontant extends StatelessWidget {
  final String libelle;
  final String montant;
  final bool enGras;
  final Color? couleur;

  const LigneMontant({
    super.key,
    required this.libelle,
    required this.montant,
    this.enGras = false,
    this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    final style = (enGras
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(
      fontWeight: enGras ? FontWeight.bold : null,
      color: couleur,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(libelle, style: style)),
          Text(montant, style: style),
        ],
      ),
    );
  }
}
