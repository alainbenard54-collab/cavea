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

  Future<String> _buildCsv() async {
    final dao = ref.read(bouteillesDaoProvider);
    final bouteilles = await dao.getBouteillesForExport(stockOnly: _stockOnly);
    return CsvExportService().buildCsv(bouteilles, separator: _separator);
  }

  Future<void> _exportWindows() async {
    setState(() => _exporting = true);
    try {
      final csv = await _buildCsv();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer le CSV',
        fileName: _suggestedFileName,
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      if (path == null || !mounted) return;
      await File(path).writeAsBytes(utf8.encode(csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fichier enregistré : ${path.split(Platform.pathSeparator).last}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAndroidSave() async {
    setState(() => _exporting = true);
    try {
      final csv = await _buildCsv();
      // Sur Android, FilePicker.saveFile() exige les bytes et écrit lui-même le fichier.
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer le CSV',
        fileName: _suggestedFileName,
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: bytes,
      );
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier enregistré')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAndroidShare() async {
    setState(() => _exporting = true);
    try {
      final csv = await _buildCsv();
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
          SnackBar(content: Text('Erreur lors de l\'export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Scope', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Stock uniquement')),
            ButtonSegment(value: false, label: Text('Tout (stock + consommées)')),
          ],
          selected: {_stockOnly},
          onSelectionChanged: _exporting
              ? null
              : (v) => setState(() => _stockOnly = v.first),
        ),
        const SizedBox(height: 20),
        Text('Séparateur', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: ';', label: Text('Point-virgule  ;')),
            ButtonSegment(value: ',', label: Text('Virgule  ,')),
            ButtonSegment(value: '\t', label: Text('Tabulation')),
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
            label: Text(_exporting ? 'Export en cours…' : 'Exporter…'),
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
                  label: Text(_exporting ? '…' : 'Enregistrer'),
                  onPressed: _exporting ? null : _exportAndroidSave,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Partager…'),
                  onPressed: _exporting ? null : _exportAndroidShare,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
