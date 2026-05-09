// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers.dart';


void showDeplacerBatchSheet(
  BuildContext context,
  List<String> ids, {
  required VoidCallback onDone,
}) {
  if (ids.isEmpty) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _DeplacerBatchSheet(ids: ids, onDone: onDone),
    ),
  );
}

class _DeplacerBatchSheet extends ConsumerStatefulWidget {
  final List<String> ids;
  final VoidCallback onDone;

  const _DeplacerBatchSheet({required this.ids, required this.onDone});

  @override
  ConsumerState<_DeplacerBatchSheet> createState() =>
      _DeplacerBatchSheetState();
}

class _DeplacerBatchSheetState extends ConsumerState<_DeplacerBatchSheet> {
  final _ctrl = TextEditingController();
  List<String> _allEmplacements = [];
  List<String> _suggestions = [];
  bool _loading = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
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
        : _allEmplacements.where((e) => e.toLowerCase().contains(q)).toList();
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
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Emplacement obligatoire';
    final levels = trimmed.split(' > ');
    if (levels.any((l) => !_levelRe.hasMatch(l.trim()))) {
      return 'Format : "Niveau1" ou "Niveau1 > Niveau2 > …"\n(lettres, chiffres, espaces ; séparateur " > ")';
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
        .deplacerBouteilles(widget.ids, emplacement);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Déplacer ${widget.ids.length} bouteille${widget.ids.length > 1 ? 's' : ''}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Emplacement',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _validationError,
                errorMaxLines: 2,
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
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
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
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
                      : const Text('Confirmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
