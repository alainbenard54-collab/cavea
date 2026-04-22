// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';

class ConsommerForm extends ConsumerStatefulWidget {
  final Bouteille bouteille;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const ConsommerForm({
    super.key,
    required this.bouteille,
    required this.onDone,
    required this.onCancel,
  });

  @override
  ConsumerState<ConsommerForm> createState() => _ConsommerFormState();
}

class _ConsommerFormState extends ConsumerState<ConsommerForm> {
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
    await ref.read(bouteillesDaoProvider).consommerBouteille(
          widget.bouteille.id,
          dateSortie: dateSortie,
          noteDegus: _noterActive ? _note.roundToDouble() : null,
          commentaireDegus: _commentaireCtrl.text.trim().isNotEmpty
              ? _commentaireCtrl.text.trim()
              : null,
        );
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Consommer', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),

          // Sélecteur de date
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text('Date de consommation : $dateLabel'),
            onPressed: _pickDate,
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),

          // Switch "Noter"
          Row(
            children: [
              Switch(
                value: _noterActive,
                onChanged: (v) => setState(() => _noterActive = v),
              ),
              const SizedBox(width: 8),
              const Text('Ajouter une note'),
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
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(),
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
                onPressed: _loading ? null : widget.onCancel,
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
    );
  }
}
