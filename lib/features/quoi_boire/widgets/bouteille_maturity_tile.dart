// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../../data/database.dart';
import '../../../core/maturity/maturity_service.dart';
import '../../stock/bouteille_list_tile.dart';
import 'maturity_badge.dart';

class BouteilleMaturityTile extends StatelessWidget {
  final Bouteille bouteille;
  final MaturityLevel maturite;

  const BouteilleMaturityTile({
    super.key,
    required this.bouteille,
    required this.maturite,
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
      leading: Icon(
        Icons.wine_bar,
        color: couleurVin(bouteille.couleur),
        size: 28,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              bouteille.domaine,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          MaturityBadge(level: maturite),
        ],
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
