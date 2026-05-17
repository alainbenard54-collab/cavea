// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

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
  late final FocusNode _emplacementFocus;
  final _emplacementFieldKey = GlobalKey();
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
    _emplacementCtrl = TextEditingController(text: widget.groupe.emplacement);
    _emplacementFocus = FocusNode();
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
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _emplacementCtrl.dispose();
    _emplacementFocus.dispose();
    super.dispose();
  }

  void _onQtyChanged(String v) {
    final qty = int.tryParse(v) ?? 1;
    widget.onChanged(widget.groupe.copyWith(quantite: qty < 1 ? 1 : qty));
  }

  void _validateEmplacement() {
    final t = _emplacementCtrl.text.trim();
    if (t.isNotEmpty && !_levelRe.hasMatch(t)) {
      setState(() => _emplacementError = context.l10n.repartitionFormatError);
    } else {
      setState(() => _emplacementError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final openUp = Platform.isAndroid &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Row(
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
        // Emplacement avec RawAutocomplete (overlay flottant)
        Expanded(
          child: RawAutocomplete<String>(
            textEditingController: _emplacementCtrl,
            focusNode: _emplacementFocus,
            optionsViewOpenDirection: openUp
                ? OptionsViewOpenDirection.up
                : OptionsViewOpenDirection.down,
            optionsBuilder: (textEditingValue) {
              final q = textEditingValue.text.toLowerCase();
              return widget.emplacements.where(
                (e) =>
                    e.toLowerCase().contains(q) &&
                    e != textEditingValue.text,
              );
            },
            displayStringForOption: (s) => s,
            fieldViewBuilder: (_, __, ___, onFieldSubmitted) => TextField(
              key: _emplacementFieldKey,
              controller: _emplacementCtrl,
              focusNode: _emplacementFocus,
              decoration: InputDecoration(
                labelText: l10n.fieldEmplacement,
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _emplacementError,
                errorMaxLines: 2,
              ),
              onChanged: (v) {
                setState(() => _emplacementError = null);
                widget.onChanged(widget.groupe.copyWith(emplacement: v));
              },
              onEditingComplete: _validateEmplacement,
              onSubmitted: (_) => onFieldSubmitted(),
            ),
            optionsViewBuilder: (_, onSelected, options) {
              final fieldBox = _emplacementFieldKey.currentContext
                  ?.findRenderObject() as RenderBox?;
              final fieldWidth = fieldBox?.size.width ?? 200.0;
              return Align(
                alignment:
                    openUp ? Alignment.bottomLeft : Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: fieldWidth, maxHeight: 160),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final option = options.elementAt(i);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                            widget.onChanged(
                                widget.groupe.copyWith(emplacement: option));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(option,
                                style: theme.textTheme.bodyMedium),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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
    );
  }
}
