// lib/models/article_panier.dart
import 'produit.dart';

/// Une ligne du panier : un produit et sa quantité.
class ArticlePanier {
  final Produit produit;
  int quantite;

  ArticlePanier({required this.produit, this.quantite = 1});

  double get total => produit.prixFinal * quantite;
}
