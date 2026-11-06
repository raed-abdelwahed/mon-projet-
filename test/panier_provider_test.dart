// test/panier_provider_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:sup4_dev_ecommerce/models/produit.dart';
import 'package:sup4_dev_ecommerce/providers/panier_provider.dart';

void main() {
  const produit = Produit(
    id: 1,
    nom: 'Écouteurs',
    description: '',
    prix: 100,
    prixPromo: 80,
    stock: 3,
    categorie: 'Électronique',
  );

  test('le panier utilise le prix promo', () {
    final panier = PanierProvider();
    panier.ajouter(produit);
    panier.ajouter(produit);
    expect(panier.nombreArticles, 2);
    expect(panier.sousTotal, 160);
    expect(panier.total, 160);
  });

  test('impossible de dépasser le stock', () {
    final panier = PanierProvider();
    expect(panier.ajouter(produit, quantite: 3), isTrue);
    expect(panier.ajouter(produit), isFalse);
    expect(panier.nombreArticles, 3);
  });

  test('diminuer puis retirer un article', () {
    final panier = PanierProvider();
    panier.ajouter(produit, quantite: 2);
    panier.diminuer(1);
    expect(panier.quantiteDe(1), 1);
    panier.diminuer(1);
    expect(panier.estVide, isTrue);
  });

  test('vider remet le panier à zéro', () {
    final panier = PanierProvider();
    panier.ajouter(produit);
    panier.vider();
    expect(panier.estVide, isTrue);
    expect(panier.total, 0);
  });
}
