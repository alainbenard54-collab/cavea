// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import 'widgets/deplacer_form.dart';
import 'widgets/consommer_form.dart';

enum _SheetView { menu, deplacer, consommer }

void showBottleActionsSheet(BuildContext context, Bouteille bouteille) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _BottleActionsSheet(bouteille: bouteille),
    ),
  );
}

class _BottleActionsSheet extends StatefulWidget {
  final Bouteille bouteille;

  const _BottleActionsSheet({required this.bouteille});

  @override
  State<_BottleActionsSheet> createState() => _BottleActionsSheetState();
}

class _BottleActionsSheetState extends State<_BottleActionsSheet> {
  _SheetView _view = _SheetView.menu;

  String get _title {
    final b = widget.bouteille;
    final millesime = b.millesime > 0 ? ' ${b.millesime}' : '';
    return '${b.domaine}$millesime';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Titre
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              _title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          // Contenu
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (_view) {
              _SheetView.menu => _Menu(
                  key: const ValueKey('menu'),
                  onDeplacer: () => setState(() => _view = _SheetView.deplacer),
                  onConsommer: () =>
                      setState(() => _view = _SheetView.consommer),
                  onModifierFiche: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                  onAnnuler: () => Navigator.of(context).pop(),
                ),
              _SheetView.deplacer => DeplacerForm(
                  key: const ValueKey('deplacer'),
                  bouteille: widget.bouteille,
                  onDone: () => Navigator.of(context).pop(),
                  onCancel: () => setState(() => _view = _SheetView.menu),
                ),
              _SheetView.consommer => ConsommerForm(
                  key: const ValueKey('consommer'),
                  bouteille: widget.bouteille,
                  onDone: () => Navigator.of(context).pop(),
                  onCancel: () => setState(() => _view = _SheetView.menu),
                ),
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final VoidCallback onDeplacer;
  final VoidCallback onConsommer;
  final VoidCallback onModifierFiche;
  final VoidCallback onAnnuler;

  const _Menu({
    super.key,
    required this.onDeplacer,
    required this.onConsommer,
    required this.onModifierFiche,
    required this.onAnnuler,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.move_down),
          title: const Text('Déplacer'),
          onTap: onDeplacer,
        ),
        ListTile(
          leading: const Icon(Icons.local_bar),
          title: const Text('Consommer'),
          onTap: onConsommer,
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Modifier la fiche'),
          onTap: onModifierFiche,
        ),
        ListTile(
          leading: const Icon(Icons.close),
          title: const Text('Annuler'),
          onTap: onAnnuler,
        ),
      ],
    );
  }
}
