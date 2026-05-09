// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../data/database.dart';

Color couleurVin(String couleur) {
  final c = couleur.toLowerCase().trim();
  if (c.contains('rouge')) return const Color(0xFF722F37);
  // moelleux/liquoreux avant blanc (ex: "Blanc moelleux" doit matcher ici)
  if (c.contains('moelleux') || c.contains('liquoreux') || c.contains('doux')) {
    return const Color(0xFFD4AF37);
  }
  if (c.contains('blanc')) return const Color(0xFFF5F0A8);
  if (c.contains('ros')) return const Color(0xFFE8829A);
  if (c.contains('effervescent') ||
      c.contains('champagne') ||
      c.contains('pétillant') ||
      c.contains('petillant') ||
      c.contains('crémant') ||
      c.contains('cremant')) {
    return const Color(0xFF90CAF9);
  }
  return Colors.grey.shade400;
}

class BouteilleListTile extends StatelessWidget {
  final Bouteille bouteille;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelectMode;
  final bool isSelected;

  const BouteilleListTile({
    super.key,
    required this.bouteille,
    this.onTap,
    this.onLongPress,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final millesime = bouteille.millesime;
    final appellation = bouteille.appellation;
    final cru = bouteille.cru;
    final emplacement = bouteille.emplacement;

    final subtitleParts = [
      if (appellation.isNotEmpty) appellation,
      if (millesime > 0) millesime.toString(),
      if (cru != null && cru.isNotEmpty) cru,
    ];

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      leading: isSelectMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap?.call(),
            )
          : Icon(
              Icons.wine_bar,
              color: couleurVin(bouteille.couleur),
              size: 28,
            ),
      title: Text(
        bouteille.domaine,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitleParts.isNotEmpty
          ? Text(
              subtitleParts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: emplacement.isNotEmpty
          ? Text(
              emplacement,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }
}
