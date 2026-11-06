// lib/services/payment_service.dart

/// Paiement SIMULÉ : aucune vraie transaction bancaire.
/// Pour tester un refus, utilisez une carte qui se termine par 0000.
class PaymentService {
  Future<bool> payer({
    required String numeroCarte,
    required double montant,
  }) async {
    // On simule le temps de réponse de la banque
    await Future.delayed(const Duration(seconds: 2));
    final numero = numeroCarte.replaceAll(' ', '');
    if (montant <= 0) return false;
    return !numero.endsWith('0000');
  }
}
