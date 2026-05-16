// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../bulk_add_controller.dart';

class RepartitionRow extends ConsumerStatefulWidget {
  final int index;
  final RepartitionGroup groupe;
  final ValueChanged<RepartitionGroup> onChanged;
  final VoidCallback? onRemove;
  final List<String> emplacements;

  const RepartitionRow({
    super.key,
    required this.index,
    required this.groupe,
    required this.onChanged,
    required this.emplacements,
    this.onRemove,
  });

  @override
  ConsumerState<RepartitionRow> createState() => _RepartitionRowState();
}

class _RepartitionRowState extends ConsumerState<RepartitionRow> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _emplacementCtrl;
  String _emplacement = '';
  List<String> _suggestions = [];
  String? _emplacementError;

  static final _levelRe = RegExp(
    r'^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*( > [a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*)*$',
  );

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.groupe.quantite.toString(),
    );
    _emplacement = widget.groupe.emplacement;
    _emplacementCtrl = TextEditingController(text: _emplacement);
  }

  @override
  void didUpdateWidget(RepartitionRow old) {
    super.didUpdateWidget(old);
    if (old.groupe.quantite != widget.groupe.quantite) {
      final newText = widget.groupe.quantite.toString();
      if (_qtyCtrl.text != newText) {
        _qtyCtrl.text = newText;
      }
    }
    if (old.groupe.emplacement != widget.groupe.emplacement &&
        _emplacementCtrl.text != widget.groupe.emplacement) {
      _emplacementCtrl.text = widget.groupe.emplacement;
      _emplacement = widget.groupe.emplacement;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _emplacementCtrl.dispose();
    super.dispose();
  }

  void _onQtyChanged(String v) {
    final qty = int.tryParse(v) ?? 1;
    widget.onChanged(widget.groupe.copyWith(quantite: qty < 1 ? 1 : qty));
  }

  void _onEmplacementChanged(String v) {
    setState(() {
      _emplacement = v;
      _emplacementError = null;
      final q = v.toLowerCase();
      _suggestions = q.isEmpty
          ? List.of(widget.emplacements)
          : widget.emplacements
              .where((e) => e.toLowerCase().contains(q))
              .toList();
    });
    widget.onChanged(widget.groupe.copyWith(emplacement: v));
  }

  void _selectSuggestion(String value) {
    _emplacementCtrl.text = value;
    _emplacementCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: value.length));
    setState(() {
      _emplacement = value;
      _suggestions = [];
      _emplacementError = null;
    });
    widget.onChanged(widget.groupe.copyWith(emplacement: value));
  }

  void _validateEmplacement() {
    final t = _emplacement.trim();
    if (t.isNotEmpty && !_levelRe.hasMatch(t)) {
      setState(() => _emplacementError = context.l10n.repartitionFormatError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantité — TextField (pas FormField) pour éviter setState-during-build
            // quand setQuantiteTotal synchronise ce champ via didUpdateWidget
            SizedBox(
              width: 64,
              child: TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.repartitionQte,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _onQtyChanged,
              ),
            ),
            const SizedBox(width: 8),
            // Emplacement
            Expanded(
              child: TextField(
                controller: _emplacementCtrl,
                decoration: InputDecoration(
                  labelText: l10n.fieldEmplacement,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  errorText: _emplacementError,
                  errorMaxLines: 2,
                ),
                onChanged: _onEmplacementChanged,
                onEditingComplete: _validateEmplacement,
              ),
            ),
            // Bouton suppression
            if (widget.onRemove != null)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: theme.colorScheme.error,
                onPressed: widget.onRemove,
                tooltip: l10n.repartitionSupprimer,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 2),
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            margin: const EdgeInsets.only(left: 72, right: 48),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (_, i) => InkWell(
                onTap: () => _selectSuggestion(_suggestions[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(_suggestions[i], style: theme.textTheme.bodyMedium),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
