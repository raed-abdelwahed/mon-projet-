// lib/services/commande_service.dart
import '../models/article_panier.dart';
import '../models/commande.dart';
import '../models/ligne_commande.dart';
import 'database_service.dart';

/// Erreur lisible renvoyée à l'écran (ex : stock insuffisant).
class CommandeException implements Exception {
  final String message;
  CommandeException(this.message);
}

class CommandeService {
  /// Vérifie que chaque produit du panier est encore disponible.
  Future<void> verifierStock(List<ArticlePanier> articles) async {
    final db = await DatabaseService.instance.database;
    for (final article in articles) {
      final lignes = await db.query(
        'produits',
        columns: ['nom', 'stock'],
        where: 'id = ?',
        whereArgs: [article.produit.id],
      );
      if (lignes.isEmpty) {
        throw CommandeException('Le produit « ${article.produit.nom} » n\'existe plus.');
      }
      final stock = lignes.first['stock'] as int;
      if (stock < article.quantite) {
        throw CommandeException(
          'Stock insuffisant pour « ${lignes.first['nom']} » (il en reste $stock).',
        );
      }
    }
  }

  /// Enregistre la commande, ses lignes, et diminue le stock.
  /// Tout se fait dans une TRANSACTION : si une étape échoue, rien n'est enregistré.
  Future<int> enregistrer({
    required int utilisateurId,
    required List<ArticlePanier> articles,
    required double sousTotal,
    required double remise,
    required double total,
    String? codeCoupon,
    required String adresse,
  }) async {
    final db = await DatabaseService.instance.database;

    return db.transaction<int>((txn) async {
      final commande = Commande(
        utilisateurId: utilisateurId,
        date: DateTime.now(),
        sousTotal: sousTotal,
        remise: remise,
        total: total,
        codeCoupon: codeCoupon,
        adresse: adresse,
      );
      final commandeId = await txn.insert('commandes', commande.toMap()..remove('id'));

      for (final article in articles) {
        final ligne = LigneCommande(
          commandeId: commandeId,
          produitId: article.produit.id!,
          nomProduit: article.produit.nom,
          prixUnitaire: article.produit.prixFinal,
          quantite: article.quantite,
        );
        await txn.insert('lignes_commande', ligne.toMap()..remove('id'));

        final modifies = await txn.rawUpdate(
          'UPDATE produits SET stock = stock - ? WHERE id = ? AND stock >= ?',
          [article.quantite, article.produit.id, article.quantite],
        );
        if (modifies == 0) {
          throw CommandeException('Stock insuffisant pour « ${article.produit.nom} ».');
        }
      }
      return commandeId;
    });
  }

  /// Toutes les commandes d'un client, de la plus récente à la plus ancienne.
  Future<List<Commande>> commandesDe(int utilisateurId) async {
    final db = await DatabaseService.instance.database;
    final lignesCommandes = await db.query(
      'commandes',
      where: 'utilisateur_id = ?',
      whereArgs: [utilisateurId],
      orderBy: 'date DESC',
    );

    final commandes = <Commande>[];
    for (final c in lignesCommandes) {
      final lignes = await db.query(
        'lignes_commande',
        where: 'commande_id = ?',
        whereArgs: [c['id']],
      );
      commandes.add(Commande.fromMap(
        c,
        lignes: lignes.map(LigneCommande.fromMap).toList(),
      ));
    }
    return commandes;
  }
}
