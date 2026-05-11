// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/sync_service.dart';
import '../import_csv/import_csv_screen.dart';
import 'export_csv_screen.dart';

class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;

    return Scaffold(
      appBar: AppBar(title: const Text('Données')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionCard(
                title: 'Importer un CSV',
                icon: Icons.upload_file_outlined,
                child: ImportCsvContent(isReadOnly: isReadOnly),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Exporter en CSV',
                icon: Icons.download_outlined,
                child: const ExportCsvScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
