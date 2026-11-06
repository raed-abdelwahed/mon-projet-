// lib/providers/commande_provider.dart
import 'package:flutter/material.dart';

import '../models/commande.dart';
import '../services/commande_service.dart';
import '../services/payment_service.dart';
import 'panier_provider.dart';

/// Passage de commande (paiement simulé) et historique du client.
class CommandeProvider extends ChangeNotifier {
  final CommandeService _service = CommandeService();
  final PaymentService _paiement = PaymentService();

  List<Commande> _commandes = [];
  bool _chargement = false;

  List<Commande> get commandes => _commandes;
  bool get chargement => _chargement;

  Future<void> charger(int utilisateurId) async {
    _chargement = true;
    notifyListeners();
    _commandes = await _service.commandesDe(utilisateurId);
    _chargement = false;
    notifyListeners();
  }

  /// 1. vérifie le stock  2. paie  3. enregistre la commande.
  /// Renvoie null si tout va bien, sinon un message d'erreur.
  Future<String?> passerCommande({
    required int utilisateurId,
    required PanierProvider panier,
    required String adresse,
    required String numeroCarte,
  }) async {
    try {
      await _service.verifierStock(panier.articles);

      final paye = await _paiement.payer(
        numeroCarte: numeroCarte,
        montant: panier.total,
      );
      if (!paye) {
        return 'Paiement refusé par la banque (simulation). Essayez une autre carte.';
      }

      await _service.enregistrer(
        utilisateurId: utilisateurId,
        articles: panier.articles,
        sousTotal: panier.sousTotal,
        remise: panier.remise,
        total: panier.total,
        codeCoupon: panier.coupon?.code,
        adresse: adresse,
      );
    } on CommandeException catch (e) {
      return e.message;
    }

    await charger(utilisateurId);
    return null;
  }

  void vider() {
    _commandes = [];
    notifyListeners();
  }
}
