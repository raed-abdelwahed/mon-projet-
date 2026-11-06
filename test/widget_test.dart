// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sup4_dev_ecommerce/models/produit.dart';
import 'package:sup4_dev_ecommerce/providers/panier_provider.dart';
import 'package:sup4_dev_ecommerce/widgets/produit_card.dart';

void main() {
  testWidgets('La carte produit affiche le nom, la promo et ajoute au panier', (tester) async {
    const produit = Produit(
      id: 1,
      nom: 'Mug test',
      description: '',
      prix: 30,
      prixPromo: 24,
      stock: 5,
      categorie: 'Maison',
    );
    final panier = PanierProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<PanierProvider>.value(
        value: panier,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, height: 300, child: ProduitCard(produit: produit)),
          ),
        ),
      ),
    );

    expect(find.text('Mug test'), findsOneWidget);
    expect(find.text('-20%'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_shopping_cart));
    await tester.pump();
    expect(panier.nombreArticles, 1);
  });
}
