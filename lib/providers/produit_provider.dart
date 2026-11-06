// lib/providers/produit_provider.dart
import 'package:flutter/material.dart';

import '../models/produit.dart';
import '../services/produit_service.dart';

/// Liste des produits + recherche + filtre par catégorie.
class ProduitProvider extends ChangeNotifier {
  final ProduitService _service = ProduitService();

  List<Produit> _produits = [];
  bool _chargement = false;
  String _recherche = '';
  String? _categorie; // null = toutes les catégories

  List<Produit> get produits => _produits;
  bool get chargement => _chargement;
  String get recherche => _recherche;
  String? get categorie => _categorie;

  List<String> get categories =>
      _produits.map((p) => p.categorie).toSet().toList()..sort();

  List<Produit> get vedettes => _produits.where((p) => p.vedette).toList();

  List<Produit> get produitsFiltres => _produits.where((p) {
        final bonneCategorie = _categorie == null || p.categorie == _categorie;
        final bonneRecherche = _recherche.isEmpty ||
            p.nom.toLowerCase().contains(_recherche.toLowerCase());
        return bonneCategorie && bonneRecherche;
      }).toList();

  Future<void> charger() async {
    _chargement = true;
    notifyListeners();
    _produits = await _service.tous();
    _chargement = false;
    notifyListeners();
  }

  void rechercher(String texte) {
    _recherche = texte.trim();
    notifyListeners();
  }

  void choisirCategorie(String? categorie) {
    _categorie = categorie;
    notifyListeners();
  }
}
