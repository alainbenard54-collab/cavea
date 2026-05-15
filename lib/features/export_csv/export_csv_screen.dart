// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/providers.dart';
import '../../l10n/l10n.dart';
import 'csv_export_service.dart';

class ExportCsvScreen extends ConsumerStatefulWidget {
  const ExportCsvScreen({super.key});

  @override
  ConsumerState<ExportCsvScreen> createState() => _ExportCsvScreenState();
}

class _ExportCsvScreenState extends ConsumerState<ExportCsvScreen> {
  bool _stockOnly = true;
  String _separator = ';';
  bool _exporting = false;

  String get _suggestedFileName {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return 'cave_$date.csv';
  }

  Future<String> _buildCsv(AppLocalizations l10n) async {
    final dao = ref.read(bouteillesDaoProvider);
    final bouteilles = await dao.getBouteillesForExport(stockOnly: _stockOnly);
    return CsvExportService().buildCsv(bouteilles, separator: _separator, l10n: l10n);
  }

  Future<void> _exportWindows() async {
    final l10n = context.l10n;
    setState(() => _exporting = true);
    try {
      final csv = await _buildCsv(l10n);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportDialogTitle,
        fileName: _suggestedFileName,
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      if (path == null || !mounted) return;
      await File(path).writeAsBytes(utf8.encode(csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportSaved(path.split(Platform.pathSeparator).last))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAndroidSave() async {
    final l10n = context.l10n;
    setState(() => _exporting = true);
    try {
      final csv = await _buildCsv(l10n);
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportDialogTitle,
        fileName: _suggestedFileName,
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: bytes,
      );
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportSavedAndroid)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAndroidShare() async {
    setState(() => _exporting = true);
    try {
      final l10n = context.l10n;
      final csv = await _buildCsv(l10n);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$_suggestedFileName');
      await tempFile.writeAsBytes(utf8.encode(csv));
      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(tempFile.path, mimeType: 'text/csv')],
        subject: _suggestedFileName,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAndroid = Platform.isAndroid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.exportScope, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l10n.exportStockOnly)),
            ButtonSegment(value: false, label: Text(l10n.exportTout)),
          ],
          selected: {_stockOnly},
          onSelectionChanged: _exporting
              ? null
              : (v) => setState(() => _stockOnly = v.first),
        ),
        const SizedBox(height: 20),
        Text(l10n.exportSeparateur, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: ';', label: Text(l10n.exportSeparateurPointVirgule)),
            ButtonSegment(value: ',', label: Text(l10n.exportSeparateurVirgule)),
            ButtonSegment(value: '\t', label: Text(l10n.exportSeparateurTabulation)),
          ],
          selected: {_separator},
          onSelectionChanged: _exporting
              ? null
              : (v) => setState(() => _separator = v.first),
        ),
        const SizedBox(height: 24),
        if (!isAndroid)
          FilledButton.icon(
            icon: _exporting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download),
            label: Text(_exporting ? l10n.exportEnCours : l10n.exportButton),
            onPressed: _exporting ? null : _exportWindows,
          )
        else
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: _exporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(_exporting ? '…' : l10n.exportEnregistrer),
                  onPressed: _exporting ? null : _exportAndroidSave,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l10n.exportPartager),
                  onPressed: _exporting ? null : _exportAndroidShare,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
