// lib/widgets/bouton_theme.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Bouton soleil / lune pour passer du thème clair au thème sombre.
class BoutonTheme extends StatelessWidget {
  const BoutonTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return IconButton(
      tooltip: 'Changer de thème',
      icon: Icon(theme.estSombre ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => context.read<ThemeProvider>().basculerTheme(),
    );
  }
}
