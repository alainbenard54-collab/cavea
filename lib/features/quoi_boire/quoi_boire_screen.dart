// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/quoi_boire_provider.dart';
import 'widgets/bouteille_maturity_tile.dart';

class QuoiBoireScreen extends ConsumerWidget {
  const QuoiBoireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couleur = ref.watch(quoiBoireFilterProvider);
    final couleursAsync = ref.watch(quoiBoireCouleursProvider);
    final listAsync = ref.watch(quoiBoireProvider);

    return Column(
      children: [
        // Barre de filtre couleur
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: couleursAsync.maybeWhen(
            data: (couleurs) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CouleurChip(
                    label: 'Toutes',
                    selected: couleur == null,
                    onTap: () => ref
                        .read(quoiBoireFilterProvider.notifier)
                        .setCouleur(null),
                  ),
                  ...couleurs.map(
                    (c) => _CouleurChip(
                      label: c,
                      selected: couleur == c,
                      onTap: () => ref
                          .read(quoiBoireFilterProvider.notifier)
                          .setCouleur(c),
                    ),
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
        // Liste avec badges de maturité
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur : $e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wine_bar_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune bouteille en stock',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => BouteilleMaturityTile(
                  bouteille: items[i].bouteille,
                  maturite: items[i].maturite,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CouleurChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CouleurChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
