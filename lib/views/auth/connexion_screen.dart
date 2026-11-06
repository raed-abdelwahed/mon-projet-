// lib/views/auth/connexion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/bouton_theme.dart';
import 'inscription_screen.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();
  bool _masquer = true;
  bool _chargement = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _chargement = true);

    final erreur = await context
        .read<AuthProvider>()
        .connecter(_emailCtrl.text, _motDePasseCtrl.text);

    if (!mounted) return;
    setState(() => _chargement = false);
    if (erreur != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur)));
    }
    // Si la connexion réussit, main.dart affiche automatiquement le bon espace.
  }

  /// Remplit le formulaire avec un compte de démonstration.
  void _remplir(String email, String motDePasse) {
    _emailCtrl.text = email;
    _motDePasseCtrl.text = motDePasse;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(actions: const [BoutonTheme()]),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'SUP4 DEV E-Commerce',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Connectez-vous pour continuer', textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Entrez votre email';
                      if (!v.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motDePasseCtrl,
                    obscureText: _masquer,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_masquer ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _masquer = !_masquer),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Entrez votre mot de passe' : null,
                    onFieldSubmitted: (_) => _seConnecter(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _chargement ? null : _seConnecter,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _chargement
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InscriptionScreen()),
                    ),
                    child: const Text('Pas encore de compte ? Créer un compte'),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comptes de démonstration', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.person_outline, size: 18),
                                label: const Text('Client'),
                                onPressed: () => _remplir('client@sup4.tn', 'client123'),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                                label: const Text('Admin'),
                                onPressed: () => _remplir('admin@sup4.tn', 'admin123'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
