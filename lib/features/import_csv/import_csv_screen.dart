// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../l10n/l10n.dart';
import '../stock/stock_controller.dart';
import 'csv_parser.dart';
import 'import_service.dart';

// Widget intégrable sans Scaffold (utilisé depuis ImportExportScreen).
class ImportCsvContent extends ConsumerStatefulWidget {
  final bool isReadOnly;

  const ImportCsvContent({super.key, this.isReadOnly = false});

  @override
  ConsumerState<ImportCsvContent> createState() => _ImportCsvContentState();
}

class _ImportCsvContentState extends ConsumerState<ImportCsvContent> {
  String? _filePath;
  bool _overwrite = false;
  bool _importing = false;
  String _separator = ';';
  ImportResult? _result;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final dialogTitle = context.l10n.importPickFileDialog;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: dialogTitle,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _result = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _runImport() async {
    if (_filePath == null) return;
    setState(() {
      _importing = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final content = await File(_filePath!).readAsString();
      final parsed = parseCsv(content, separator: _separator);
      final dao = ref.read(bouteillesDaoProvider);
      final service = ImportService(dao);
      final parseErrorDetails = parsed.errors
          .map((e) => 'Ligne ${e.lineNumber} — ${e.reason} : ${e.rawLine}')
          .toList();
      final result = await service.run(
        parsed.companions,
        overwrite: _overwrite,
        parseErrorDetails: parseErrorDetails,
      );
      setState(() {
        _result = result;
        _importing = false;
      });
      if (result.inserted > 0 || result.updated > 0) {
        ref.invalidate(couleursProvider);
        ref.invalidate(appellationsProvider);
        ref.invalidate(millesimesProvider);
        ref.read(stockFilterProvider.notifier).reset();
      }
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.importFileError(e.toString());
        _importing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.isReadOnly) {
      return Row(
        children: [
          Icon(Icons.lock, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.importReadOnly,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      );
    }

    final blocked = _importing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.importFormatInfo),
        const SizedBox(height: 16),
        Text(l10n.exportSeparateur, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: ';', label: Text(l10n.exportSeparateurPointVirgule)),
            ButtonSegment(value: ',', label: Text(l10n.exportSeparateurVirgule)),
            ButtonSegment(value: '\t', label: Text(l10n.exportSeparateurTabulation)),
          ],
          selected: {_separator},
          onSelectionChanged: blocked
              ? null
              : (v) => setState(() => _separator = v.first),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text(
            _filePath != null
                ? _filePath!.split(Platform.pathSeparator).last
                : l10n.importChoisirFichier,
          ),
          onPressed: blocked ? null : _pickFile,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: Text(l10n.importEcraser),
          subtitle: Text(l10n.importEcraserSubtitle),
          value: _overwrite,
          onChanged: blocked ? null : (v) => setState(() => _overwrite = v!),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: _importing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_importing ? l10n.importEnCours : l10n.importButton),
          onPressed: (_filePath == null || blocked) ? null : _runImport,
        ),
        if (_result != null) ...[
          const SizedBox(height: 24),
          _ResultCard(result: _result!),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Écran standalone (conservé pour compatibilité).
class ImportCsvScreen extends ConsumerWidget {
  const ImportCsvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importSectionTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: ImportCsvContent(),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatefulWidget {
  final ImportResult result;
  const _ResultCard({required this.result});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _showErrors = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importTermine,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _Stat(icon: Icons.add_circle_outline, label: l10n.importInserted,
                value: widget.result.inserted, color: Colors.green),
            _Stat(icon: Icons.edit_outlined, label: l10n.importUpdated,
                value: widget.result.updated, color: Colors.blue),
            _Stat(icon: Icons.remove_circle_outline, label: l10n.importIgnored,
                value: widget.result.skipped, color: Colors.grey),
            _Stat(icon: Icons.error_outline, label: l10n.importErrors,
                value: widget.result.errors, color: Colors.red),
            if (widget.result.errorDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _showErrors = !_showErrors),
                child: Row(children: [
                  Icon(_showErrors ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(_showErrors ? l10n.importMasquerDetail : l10n.importVoirDetail,
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                ]),
              ),
              if (_showErrors) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectionArea(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.result.errorDetails.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          widget.result.errorDetails[i],
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '$value',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
