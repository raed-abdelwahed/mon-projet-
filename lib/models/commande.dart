// lib/models/commande.dart
import 'ligne_commande.dart';

/// Une commande passée par un client.
class Commande {
  final int? id;
  final int utilisateurId;
  final DateTime date;
  final double sousTotal;
  final double remise;
  final double total;
  final String statut; // En préparation, Expédiée, Livrée...
  final String? codeCoupon;
  final String adresse;
  final List<LigneCommande> lignes;

  const Commande({
    this.id,
    required this.utilisateurId,
    required this.date,
    required this.sousTotal,
    required this.remise,
    required this.total,
    this.statut = 'En préparation',
    this.codeCoupon,
    required this.adresse,
    this.lignes = const [],
  });

  int get nombreArticles => lignes.fold<int>(0, (s, l) => s + l.quantite);

  Map<String, Object?> toMap() => {
        'id': id,
        'utilisateur_id': utilisateurId,
        'date': date.toIso8601String(),
        'sous_total': sousTotal,
        'remise': remise,
        'total': total,
        'statut': statut,
        'code_coupon': codeCoupon,
        'adresse': adresse,
      };

  factory Commande.fromMap(
    Map<String, Object?> map, {
    List<LigneCommande> lignes = const [],
  }) =>
      Commande(
        id: map['id'] as int?,
        utilisateurId: map['utilisateur_id'] as int,
        date: DateTime.parse(map['date'] as String),
        sousTotal: (map['sous_total'] as num).toDouble(),
        remise: (map['remise'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
        statut: map['statut'] as String,
        codeCoupon: map['code_coupon'] as String?,
        adresse: map['adresse'] as String,
        lignes: lignes,
      );
}
