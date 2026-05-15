// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/l10n.dart';

class DeplacerForm extends ConsumerStatefulWidget {
  final Bouteille bouteille;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const DeplacerForm({
    super.key,
    required this.bouteille,
    required this.onDone,
    required this.onCancel,
  });

  @override
  ConsumerState<DeplacerForm> createState() => _DeplacerFormState();
}

class _DeplacerFormState extends ConsumerState<DeplacerForm> {
  final _ctrl = TextEditingController();
  List<String> _allEmplacements = [];
  List<String> _suggestions = [];
  bool _loading = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.bouteille.emplacement;
    _ctrl.addListener(_onTextChanged);
    _loadEmplacements();
  }

  Future<void> _loadEmplacements() async {
    final list =
        await ref.read(bouteillesDaoProvider).getDistinctEmplacements();
    if (!mounted) return;
    setState(() {
      _allEmplacements = list;
      _updateSuggestions();
    });
  }

  void _onTextChanged() => setState(() {
        _validationError = null;
        _updateSuggestions();
      });

  void _updateSuggestions() {
    final q = _ctrl.text.toLowerCase();
    _suggestions = q.isEmpty
        ? List.of(_allEmplacements)
        : _allEmplacements
            .where((e) => e.toLowerCase().contains(q))
            .toList();
  }

  void _selectSuggestion(String value) {
    _ctrl.text = value;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: value.length));
    setState(() => _suggestions = []);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    _ctrl.dispose();
    super.dispose();
  }

  static final _levelRe = RegExp(r'^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*$');

  String? _validate(String value) {
    final l10n = context.l10n;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.deplacerEmplacementObligatoire;
    final levels = trimmed.split(' > ');
    if (levels.any((l) => !_levelRe.hasMatch(l.trim()))) {
      return l10n.deplacerFormatError;
    }
    return null;
  }

  Future<void> _confirm() async {
    final emplacement = _ctrl.text.trim();
    final error = _validate(emplacement);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }
    setState(() {
      _validationError = null;
      _loading = true;
    });
    await ref
        .read(bouteillesDaoProvider)
        .deplacerBouteille(widget.bouteille.id, emplacement);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deplacerTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.fieldEmplacement,
              border: const OutlineInputBorder(),
              isDense: true,
              errorText: _validationError,
              errorMaxLines: 2,
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, i) => InkWell(
                  onTap: () => _selectSuggestion(_suggestions[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      _suggestions[i],
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _loading ? null : widget.onCancel,
                child: Text(l10n.actionAnnuler),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _confirm,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.actionConfirmer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
