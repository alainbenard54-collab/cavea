// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers.dart';
import '../../../core/locale_formatting.dart';
import '../../../l10n/l10n.dart';

void showConsommerBatchSheet(
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
      child: _ConsommerBatchSheet(ids: ids, onDone: onDone),
    ),
  );
}

class _ConsommerBatchSheet extends ConsumerStatefulWidget {
  final List<String> ids;
  final VoidCallback onDone;

  const _ConsommerBatchSheet({required this.ids, required this.onDone});

  @override
  ConsumerState<_ConsommerBatchSheet> createState() =>
      _ConsommerBatchSheetState();
}

class _ConsommerBatchSheetState extends ConsumerState<_ConsommerBatchSheet> {
  late DateTime _date;
  bool _noterActive = false;
  double _note = 7;
  final _commentaireCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final dateSortie =
        '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    await ref.read(bouteillesDaoProvider).consommerBouteilles(
          widget.ids,
          dateSortie: dateSortie,
          noteDegus: _noterActive ? _note.roundToDouble() : null,
          commentaireDegus: _commentaireCtrl.text.trim().isNotEmpty
              ? _commentaireCtrl.text.trim()
              : null,
        );
    if (mounted) {
      Navigator.of(context).pop();
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateLabel = formatDate(_date, context);

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
              l10n.consommerBatchTitle(widget.ids.length),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(l10n.consommerDateLabel(dateLabel)),
              onPressed: _pickDate,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Switch(
                  value: _noterActive,
                  onChanged: (v) => setState(() => _noterActive = v),
                ),
                const SizedBox(width: 8),
                Text(l10n.consommerAjouterNote),
                if (_noterActive) ...[
                  const Spacer(),
                  Text(
                    '${_note.round()} / 10',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ],
            ),

            if (_noterActive) ...[
              Slider(
                value: _note.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: '${_note.round()}',
                onChanged: (v) => setState(() => _note = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentaireCtrl,
                decoration: InputDecoration(
                  labelText: l10n.consommerCommentaireHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
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
      ),
    );
  }
}
