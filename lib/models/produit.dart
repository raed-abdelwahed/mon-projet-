// lib/models/produit.dart

/// Un produit vendu dans la boutique.
class Produit {
  final int? id;
  final String nom;
  final String description;
  final double prix;
  final double? prixPromo; // prix réduit (null = pas de promotion)
  final int stock;
  final String categorie;
  final bool vedette; // produit mis en avant sur l'accueil

  const Produit({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.prixPromo,
    required this.stock,
    required this.categorie,
    this.vedette = false,
  });

  bool get enPromo => prixPromo != null && prixPromo! < prix;

  /// Prix réellement payé par le client.
  double get prixFinal => enPromo ? prixPromo! : prix;

  /// Pourcentage de réduction arrondi (ex : 23).
  int get pourcentagePromo =>
      enPromo ? (((prix - prixPromo!) / prix) * 100).round() : 0;

  bool get enStock => stock > 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'nom': nom,
        'description': description,
        'prix': prix,
        'prix_promo': prixPromo,
        'stock': stock,
        'categorie': categorie,
        'vedette': vedette ? 1 : 0,
      };

  factory Produit.fromMap(Map<String, Object?> map) => Produit(
        id: map['id'] as int?,
        nom: map['nom'] as String,
        description: (map['description'] as String?) ?? '',
        prix: (map['prix'] as num).toDouble(),
        prixPromo: (map['prix_promo'] as num?)?.toDouble(),
        stock: map['stock'] as int,
        categorie: map['categorie'] as String,
        vedette: (map['vedette'] as int) == 1,
      );
}
