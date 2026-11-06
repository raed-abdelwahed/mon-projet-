// lib/models/ligne_commande.dart

/// Un produit acheté dans une commande (avec le prix au moment de l'achat).
class LigneCommande {
  final int? id;
  final int? commandeId;
  final int produitId;
  final String nomProduit;
  final double prixUnitaire;
  final int quantite;

  const LigneCommande({
    this.id,
    this.commandeId,
    required this.produitId,
    required this.nomProduit,
    required this.prixUnitaire,
    required this.quantite,
  });

  double get total => prixUnitaire * quantite;

  Map<String, Object?> toMap() => {
        'id': id,
        'commande_id': commandeId,
        'produit_id': produitId,
        'nom_produit': nomProduit,
        'prix_unitaire': prixUnitaire,
        'quantite': quantite,
      };

  factory LigneCommande.fromMap(Map<String, Object?> map) => LigneCommande(
        id: map['id'] as int?,
        commandeId: map['commande_id'] as int?,
        produitId: map['produit_id'] as int,
        nomProduit: map['nom_produit'] as String,
        prixUnitaire: (map['prix_unitaire'] as num).toDouble(),
        quantite: map['quantite'] as int,
      );
}
