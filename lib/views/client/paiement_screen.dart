// lib/views/client/paiement_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/commande_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/produit_provider.dart';
import '../../utils/formatage.dart';
import '../../widgets/ligne_montant.dart';

/// Adresse de livraison + paiement SIMULÉ par carte bancaire.
class PaiementScreen extends StatefulWidget {
  const PaiementScreen({super.key});

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseCtrl = TextEditingController();
  final _titulaireCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _expirationCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _enCours = false;

  @override
  void dispose() {
    _adresseCtrl.dispose();
    _titulaireCtrl.dispose();
    _numeroCtrl.dispose();
    _expirationCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _payer() async {
    if (!_formKey.currentState!.validate()) return;

    final utilisateur = context.read<AuthProvider>().utilisateur!;
    final panier = context.read<PanierProvider>();
    final commandes = context.read<CommandeProvider>();
    final produits = context.read<ProduitProvider>();

    setState(() => _enCours = true);
    final erreur = await commandes.passerCommande(
      utilisateurId: utilisateur.id!,
      panier: panier,
      adresse: _adresseCtrl.text.trim(),
      numeroCarte: _numeroCtrl.text,
    );
    if (!mounted) return;
    setState(() => _enCours = false);

    if (erreur != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(erreur),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    panier.vider();
    produits.charger(); // le stock a changé

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Commande validée !'),
        content: const Text(
          'Merci pour votre achat. Vous pouvez suivre votre commande dans « Mes commandes ».',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Récapitulatif
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Récapitulatif', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final a in panier.articles)
                            LigneMontant(
                              libelle: '${a.quantite} × ${a.produit.nom}',
                              montant: formatPrix(a.total),
                            ),
                          const Divider(),
                          if (panier.remise > 0)
                            LigneMontant(
                              libelle: 'Remise (${panier.coupon!.code})',
                              montant: '- ${formatPrix(panier.remise)}',
                              couleur: Colors.green,
                            ),
                          LigneMontant(
                            libelle: 'Total à payer',
                            montant: formatPrix(panier.total),
                            enGras: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Livraison', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _adresseCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Adresse de livraison',
                      prefixIcon: Icon(Icons.home_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length < 8) ? 'Adresse trop courte' : null,
                  ),
                  const SizedBox(height: 20),

                  Text('Carte bancaire', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Paiement simulé : aucune vraie transaction. '
                      'Une carte qui se termine par 0000 sera refusée (pour tester).',
                      style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titulaireCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Titulaire de la carte',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _numeroCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Numéro de carte (16 chiffres)',
                      hintText: '4242424242424242',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.length != 16) ? 'Le numéro doit contenir 16 chiffres' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expirationCtrl,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Expiration',
                            hintText: 'MM/AA',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final ok = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(v ?? '');
                            return ok ? null : 'Format MM/AA';
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.length != 3) ? '3 chiffres' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _enCours
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(_enCours
                        ? 'Paiement en cours...'
                        : 'Payer ${formatPrix(panier.total)}'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _enCours || panier.estVide ? null : _payer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
