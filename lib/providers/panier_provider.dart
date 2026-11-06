// lib/providers/panier_provider.dart
import 'package:flutter/material.dart';

import '../models/article_panier.dart';
import '../models/coupon.dart';
import '../models/produit.dart';
import '../services/coupon_service.dart';

/// Le panier du client : articles, quantités, coupon et totaux.
class PanierProvider extends ChangeNotifier {
  final CouponService _couponService = CouponService();

  final Map<int, ArticlePanier> _articles = {}; // clé = id du produit
  Coupon? _coupon;

  List<ArticlePanier> get articles => _articles.values.toList();
  Coupon? get coupon => _coupon;
  bool get estVide => _articles.isEmpty;

  int get nombreArticles =>
      _articles.values.fold<int>(0, (somme, a) => somme + a.quantite);

  double get sousTotal =>
      _articles.values.fold<double>(0, (somme, a) => somme + a.total);

  double get remise =>
      _coupon == null ? 0 : sousTotal * _coupon!.pourcentage / 100;

  double get total => sousTotal - remise;

  int quantiteDe(int produitId) => _articles[produitId]?.quantite ?? 0;

  /// Ajoute au panier. Renvoie false si le stock ne suffit pas.
  bool ajouter(Produit produit, {int quantite = 1}) {
    final id = produit.id!;
    if (quantiteDe(id) + quantite > produit.stock) return false;

    if (_articles.containsKey(id)) {
      _articles[id]!.quantite += quantite;
    } else {
      _articles[id] = ArticlePanier(produit: produit, quantite: quantite);
    }
    notifyListeners();
    return true;
  }

  /// Enlève 1 exemplaire (et retire la ligne si la quantité tombe à 0).
  void diminuer(int produitId) {
    final article = _articles[produitId];
    if (article == null) return;
    if (article.quantite <= 1) {
      _articles.remove(produitId);
    } else {
      article.quantite--;
    }
    notifyListeners();
  }

  void retirer(int produitId) {
    _articles.remove(produitId);
    notifyListeners();
  }

  /// Renvoie null si le coupon est appliqué, sinon un message d'erreur.
  Future<String?> appliquerCoupon(String code) async {
    final coupon = await _couponService.trouverActif(code);
    if (coupon == null) return 'Code promo invalide ou expiré.';
    _coupon = coupon;
    notifyListeners();
    return null;
  }

  void retirerCoupon() {
    _coupon = null;
    notifyListeners();
  }

  void vider() {
    _articles.clear();
    _coupon = null;
    notifyListeners();
  }
}
